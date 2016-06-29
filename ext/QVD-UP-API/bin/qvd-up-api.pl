#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

BEGIN {
    $QVD::Config::USE_DB = 1;
    @QVD::Config::FILES = (
        '/etc/qvd/up-api.conf',
        ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/up-api.conf',
        'qvd-up-api.conf',
    );
}

use Mojolicious::Lite;
use MojoX::Session;
use MIME::Base64 'encode_base64';
use Try::Tiny;
use QVD::Config;

##### PLUGINS #####

# Plugin for dropping privileges
my $user = cfg('up-api.user');
my $group = cfg('up-api.group');
plugin SetUserGroup => {user => $user, group => $group}
    if $< == 0 or $> == 0;

# Static web data provider
my $up_path = cfg('path.up');

plugin 'Directory' => {
    root => $up_path,
    dir_index => [qw/index.html index.htm/],
};

# Plugin to render QVD Client configuration files
plugin 'RenderFile';

##### CONFIGURATION #####

# Intended to set the address where the app is supposed to listen with hypnotoad
my $api_url = cfg('up-api.url');
my $cert_path = cfg('path.api.ssl.cert');
my $key_path = cfg('path.api.ssl.key');
die "Certificate $cert_path file does not exist" unless (-e $cert_path);
die "Private key $key_path file does not exist" unless (-e $key_path);

app->config(
    hypnotoad => {
        listen => ["$api_url?cert=${cert_path}&key=${key_path}"],
        accepts => 1000,
        clients => 1000,
        workers => 4,
        pid_file => '/var/lib/qvd/qvd-up-api.pid'
    }
);

# Set custom MIME types for QVD Client

app->types->type(qvd => 'application/qvd');

# Intended to store log info about the API

app->log( Mojo::Log->new( path => cfg('log.up-api.filename'), level => 'debug' ) );

# Response hooks

app->hook(after_render => sub {
    my ($c, $output, $format) = @_;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
});

###### DB HANDLER ######

my $DB = QVD::DB::Simple::db();

###### API ######

# Common actions to every API call

under sub {
    my $c = shift;

    open STDOUT, ">>", cfg('up-api.stdout.filename');
    open STDERR, ">>", cfg('up-api.stderr.filename');

    $c->inactivity_timeout(30000);
};

# This url retrieves general info about the API.
any [qw(GET)] => '/info' => sub {
    my $c = shift;

    my $json = {
        status => "up",
    };

    $c->render(json => $json, status => 200);
};

# Generate session
any [ qw(POST) ] => '/login' => sub {
    my $c = shift;

    my $data = $c->req->params->to_hash;
        
    my $user = $data->{user} // "";
    my $password = $data->{password} // "";
    my $tenant = $data->{tenant};
    my $separator = substr(cfg('l7r.auth.plugin.default.separators'), 0, 1);
    my $login = $user . ($tenant ? "${separator}${tenant}" : "");
    my $authorization = "Basic " . encode_base64($login . ":". $password);

    my $ua = Mojo::UserAgent->new;
    my $l7r_vm_list_url = (cfg('l7r.use_ssl') ? "https" : "http") . "://" . cfg('up-api.l7r.address') .
        ":" . cfg('l7r.port') . "/qvd/list_of_vm";
    my $auth_tx = $ua->cert( $cert_path )->key( $key_path )->
        get( $l7r_vm_list_url => { Authorization => $authorization } );

    my $http_code = $auth_tx->res->code // 502;
    my $http_message = $auth_tx->res->message // "Authentication server unavailable";

    my $user_id;
    try {
        my $user_filter = {
            login => $user,
            password => $password
        };
        $user_filter->{ tenant_id } = $DB->resultset( "Tenant" )->search( { name => $tenant } )->first->id
            if cfg( 'wat.multitenant' );
        $user_id = $DB->resultset( "User" )->first( $user_filter )->id;
    } catch {
        $http_code = 502;
        $http_message = "Database unavailable";
    };

    if ($http_code == 200) {
        my $session = create_up_session_handler( $c->tx, $DB->storage->dbh );

        $session->create;
        $session->data( user_name => $user );
        $session->data( tenant_name => $tenant );
        $session->data( login => $login );
        $session->data( password => $password );
        $session->data( user_id => $user_id );
        $session->flush;

        $http_message = "Logged in correctly";
    }

my $json = {
    message => $http_message
};
    
$c->render(json => $json, status => $http_code);
};

# Authenticated actions of the API
group {

    # Check credentials
    under sub {
        my $c = shift;

        my $session = create_up_session_handler($c->tx, $DB->storage->dbh);

        my $is_logged = 0;
        my $message = "Incorrect credentials";
        if ($session->load){
            if($session->is_expired){
                $session->clear;
                $is_logged = 0;
                $message = "Session expired";
            }else{
                $c->stash({session => $session});
                $is_logged = 1;
            }
            $session->flush;
        }
        
        if(!$is_logged){
            $c->render(text => $message, status => 401);
        }

        return $is_logged;
    };

        # Session logout
    any [ qw(POST) ] => '/logout' => sub {
        my $c = shift;

        my $session = $c->stash('session');
        $session->expire;
        $session->clear;
        $session->flush;
        
        $c->render(text => "Logged out", status => 200);
    };

    any [qw(GET)] => '/vm_list' => sub {
        my $c = shift;

        my $http_code = 200;
        my $http_message = "OK";
        my $vm_list = [];

        try {
            $vm_list = [ map { 
                    blocked => $_->vm_runtime->blocked, 
                    name => $_->name, 
                    id => $_->id, 
                    state => $_->vm_runtime->vm_state 
                },
                $DB->resultset( "VM" )->search( { user_id => $c->stash('session')->data('user_id') } )->all ];
        } catch {
            $http_code = 502;
            $http_message = "Database unavailable";
        };

        my $json = {
            message => $http_message,
            vms => $vm_list
        };

        $c->render(json => $json, status => $http_code);
    };

    any [qw(POST)] => '/vm_connect' => sub {
    my $c = shift;

        my $data = $c->req->params->to_hash;
        my $vm_id = $data->{vm_id} // "";

        my $session_l7r = create_l7r_session_handler($DB->storage->dbh);
        my $session_up = $c->stash->{session};
        $session_l7r->create;
        $session_l7r->data->{vm_id} = $vm_id;
        $session_l7r->data->{login} = $session_up->data->{login};
        $session_l7r->data->{password} = $session_up->data->{password};
        $session_l7r->flush;

        my $file_name = $session_l7r->sid . ".qvd";
        my $file_data = $session_l7r->sid . "\n";
        print $file_data;
        $c->render_file(data => $file_data, filename => $file_name, format => 'qvd');
    };
};

app->start;

##### FUNCTIONS #####

sub create_l7r_session_handler {
    my ($dbh) = @_;

    my $session = MojoX::Session->new(
        store     => [dbi => {dbh => $dbh, table => "session_l7r"}],
        expires_delta => 3600
    );

    return $session;
}

sub create_up_session_handler {
    my ($tx, $dbh) = @_;
    
    my $session = MojoX::Session->new(
        tx        => $tx,
        store     => [dbi => {dbh => $dbh, table => "session_up"}],
        transport => MojoX::Session::Transport::Cookie->new(name => 'up-sid', httponly => 1, secure => 1),
        ip_match  => 1
    );
    
    return $session;
}