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

    # Account settings
    any [qw(GET)] => '/api/account' => sub {
        my $c = shift;
        
        my $user = rs('User')->find($c->stash('session')->{user_id});

        my $json = {};
        $json->{language} = $user->language;
        $json->{username} = $user->login;
        $json->{acls} = [];

        return $c->render_response(json => $json, code => 200);
    };
    
    any [qw(PUT)] => '/api/account' => sub {
        my $c = shift;

        my $parameters = { language => $c->params->{language} };
        
        my $user = rs('User')->find($c->stash('session')->{user_id});
        $user->update( { language => $parameters->{language} } );
        
        my $json = {};
        $json->{language} = $user->language;
        $json->{username} = $user->login;
        $json->{acls} = [];
        
        return $c->render_response(json => $json, code => 200);
    };

    any [qw(GET)] => '/api/account/last_connection' => sub {
        my $c = shift;

        my $json = {};
        $json->{location} = "location";
        $json->{datetime} = "datetime";
        $json->{browser} = "browser";
        $json->{os} = "os";
        $json->{device} = "device";

        return $c->render_response(json => $json, code => 200);
    };

        # Desktops
    any [qw(GET)] => '/api/desktops' => sub {
        my $c = shift;

        my $desktop_list = [ map {
                id => $_->id,
                blocked => $_->vm_runtime->blocked,
                name => $_->name,
                alias => $_->name,
                state => $_->vm_runtime->vm_state,
                disabled_settings => 1,
                settings => {},
            },
            rs( "VM" )->search( { user_id => $c->stash('session')->data('user_id') } )->all ];

        return $c->render_response(json => $desktop_list, code => 200);
    };

    any [qw(GET)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $vm_id = $c->param('id');
        my $user_id = $c->stash('session')->data('user_id');
        my $vm = rs( "VM" )->search( { id => $vm_id, user_id => $user_id } );
        return $c->render_response(message => "Invalid VM", code => 400) unless defined($vm);

        my $desktop = {
            id => $vm->id,
            blocked => $vm->vm_runtime->blocked,
            name => $vm->name,
            alias => $vm->name,
            state => $vm->vm_runtime->vm_state,
            disabled_settings => 1,
            settings => {},
        };
        
        return $c->render_response(json => $desktop, code => 200);
    };
    
    any [qw(PUT)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        return $c->render_response(message => "TODO", code => 200);
    };
    
    any [qw(DELETE)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        return $c->render_response(message => "TODO", code => 200);
    };

    any [qw(GET)] => '/api/desktops/:id/token' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $session_up = $c->stash->{session};

        my $vm_id = $c->param('id');
        my $user_id = $session_up->data->{user_id};

        my $vm = rs( "VM" )->search( { id => $vm_id, user_id => $user_id } )->first;
        return $c->render_response(message => "Invalid VM", code => 400) unless defined($vm);

        my $session_l7r = rs('User_Token')->create( { 
            token => generate_sid(),
            expiration => time + cfg('up-api.l7r.expiration'),
            user_id => $session_up->data->{user_id},
            vm_id =>  $vm_id
        } );
        my $token = encode_base64($session_l7r->token);
        chomp($token);
            
        return $c->render_response(json => { token => $token }, code => 200 );
    };

    # Workspaces
    any [qw(GET)] => '/api/workspaces' => sub {
        my $c = shift;

        my $user = rs('User')->find($c->stash('session')->data->{user_id});

        my $workspaces = [ map {
                id       => $_->id,
                name     => $_->name,
                active   => $_->active,
                fixed    => $_->fixed,
                settings => undef,
            },
            $user->workspaces // () ];
        
        return $c->render_response(json => $workspaces, code => 200);
    };

    any [qw(GET)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $vm_id = $c->param('id');

        my $workspace_settings = {
            id       => "$vm_id",
            name     => "name",
            active   => "1",
            fixed    => "1",
            settings => undef,
            };
        return $c->render_response(json => $workspace_settings, message => "TODO", code => 200);
    };

    any [qw(POST)] => '/api/workspaces/' => sub {
        my $c = shift;

        return $c->render_response(message => "TODO", code => 200);
    };

    any [qw(PUT)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        return $c->render_response(message => "TODO", code => 200);
    };

    any [qw(DELETE)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        return $c->render_response(message => "TODO", code => 200);
    };

    # Other
    any [qw(PUT)] => '/api/geo_locate' => sub {
        my $c = shift;
        
        return $c->render_response(message => "TODO", code => 200);
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
