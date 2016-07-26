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
use QVD::DB::Simple qw(db rs);

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

##### HELPERS #####

# Query finishes and returns a response with a message and httpcode
helper (render_response => \&render_response);

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

###### API ######

# Common actions to every API call

under sub {
    my $c = shift;

    open STDOUT, ">>", cfg('up-api.stdout.filename');
    open STDERR, ">>", cfg('up-api.stderr.filename');

    $c->inactivity_timeout(cfg('up-api.request.timeout'));
};

# This url retrieves general info about the API.
any [qw(GET)] => '/api/info' => sub {
    my $c = shift;

    my $json = {
        status => "up",
    };

    return $c->render_response(json => $json, status => 200);
};

# Generate session
any [ qw(POST) ] => '/api/login' => sub {
    my $c = shift;

    my $data = $c->req->params->to_hash;

    my $login = $data->{login};
    my $password = $data->{password} // "";
        
    if (!defined($login)){
        return $c->render_response(message => 'Query parameter <login> is missing', code => 400);
    }

    my ($user, $tenant);
    if (cfg('wat.multitenant')){
        for my $separator (split "", cfg('l7r.auth.plugin.default.separators')){
            ($user, $tenant) = split $separator, $login;
            last if (defined($user) && defined($tenant));
        }
    } else {
        $user = $login;
    }

    my $authorization = "Basic " . encode_base64($login . ":". $password);

    my $ua = Mojo::UserAgent->new;
    my $l7r_vm_list_url = (cfg('l7r.use_ssl') ? "https" : "http") . "://" . cfg('up-api.l7r.address') .
        ":" . cfg('l7r.port') . "/qvd/list_of_vm";
    my $auth_tx = $ua->cert( $cert_path )->key( $key_path )->
        get( $l7r_vm_list_url => { Authorization => $authorization } );

    my $http_code = $auth_tx->res->code // 502;
    my $http_message = $auth_tx->res->message // "Authentication server unavailable";

    return $c->render_response(message => $http_message, code => $http_code)
        unless $http_code == 200;

    my $user_rs = rs('User')->search( { login => $user, password => password_to_token($password) } );

    if (cfg( 'wat.multitenant' )) {
        my $tenant_obj = rs('Tenant')->search( { name => $tenant } )->first;
        my $tenant_id = defined($tenant_obj) ? $tenant_obj->id : undef;
        $user_rs = $user_rs->search( { tenant_id => $tenant_id } );
    }

    my $user_obj = $user_rs->first;

    return $c->render_response(message => "Unauthorized", code => 401)
        unless defined $user_obj;

    my $session = create_up_session_handler( $c->tx, db );

    $session->create;
    $session->data( user_name => $user );
    $session->data( tenant_name => $tenant );
    $session->data( login => $login );
    $session->data( user_id => $user_obj->id );
    $session->flush;

    my $json = { };
    $json->{sid} = $session->sid if defined($session);

    return $c->render_response(message => "Logged in correctly", code => 200, json => $json);
};

# Authenticated actions of the API
group {

    # Check credentials
    under sub {
        my $c = shift;

        my $session = create_up_session_handler($c->tx, db);

        my $is_logged = 0;
        my $message = "Incorrect credentials";
        if ($session->load){
            if($session->is_expired){
                $session->clear;
                $is_logged = 0;
                $message = "Session expired";
            }else{
                $session->extend_expires;
                $c->stash({session => $session});
                $is_logged = 1;
            }
            $session->flush;
        }
        
        if(!$is_logged){
            $c->render_response(message => $message, code => 401);
        }

        return $is_logged;
    };

        # Session logout
    any [ qw(POST) ] => '/api/logout' => sub {
        my $c = shift;

        my $session = $c->stash('session');
        $session->expire;
        $session->clear;
        $session->flush;
       
        return $c->render_response(message => "Logged out", code => 200);
    };

    any [qw(GET)] => '/api/vm' => sub {
        my $c = shift;

        my $vm_list = [];

        try {
            $vm_list = [ map { 
                    blocked => $_->vm_runtime->blocked, 
                    name => $_->name, 
                    id => $_->id, 
                    state => $_->vm_runtime->vm_state 
                },
                rs( "VM" )->search( { user_id => $c->stash('session')->data('user_id') } )->all ];
        } catch {
            print $_;
            return $c->render_respone(message => "Database related issue", code => 502);
        };

        my $json = {
            vms => $vm_list
        };

        return $c->render_response(code => 200, json => $json);
    };

    any [qw(GET)] => '/api/vm_connect/:vm_id' => [vm_id => qr/\d+/] => sub {
        my $c = shift;

        my $vm_id = $c->param('vm_id');
        my $session_up = $c->stash->{session};

        my $vm = rs( "VM" )->search( { id => $vm_id, user_id => $session_up->data->{user_id} } )->first;
        return $c->render_response(message => "Invalid VM", code => 400) unless defined($vm);

        my $session_l7r = rs('User_Token')->create( { 
            token => generate_sid(),
            expiration => time + cfg('up-api.l7r.expiration'),
            user_id => $session_up->data->{user_id},
            vm_id =>  $vm_id
        } );
            
        my $file_name = "desktop_${vm_id}.qvd";
        my $file_data = encode_base64($session_l7r->token);
        return $c->render_file(data => $file_data, filename => $file_name, format => 'qvd');
    };
};

app->start;

##### FUNCTIONS #####

sub generate_sid {
    return Session::Token->new(entropy => 256)->get;
}

sub create_up_session_handler {
    my ($tx, $dbi) = @_;
    
    my $session = MojoX::Session->new(
        tx            => $tx,
        store         => [dbi => {dbh => $dbi->storage->dbh, table => "session_up"}],
        transport     => MojoX::Session::Transport::Cookie->new(name => 'up-sid', httponly => 1, secure => 1),
        ip_match      => 1,
        expires_delta => cfg('up-api.session.timeout')
    );
    
    return $session;
}

sub render_response {
    my $c = shift;
    my %args = @_;

    my $json = $args{json} // {};
    my $message = $args{message};
    my $code = $args{code} // 200;
    
    $json->{message} = $message if defined($message);
    
    $c->render(json => $json, status => $code);
    
    return 1;
}

sub password_to_token
{
    my ($password) = @_;
    require Digest::SHA;
    return Digest::SHA::sha256_base64(cfg('l7r.auth.plugin.default.salt') . $password);
}
