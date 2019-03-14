#!/usr/lib/qvd/bin/perl
use strict;

BEGIN {
    $QVD::Config::USE_DB = 1;
    @QVD::Config::Core::FILES = (
        '/etc/qvd/up-api.conf',
        ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/up-api.conf',
        'qvd-up-api.conf',
    );
}

use QVD::UP::H5GW::SessionManager;
use QVD::UP::API;
use Mojolicious::Lite;
use MojoX::Session;
use Mojo::Pg;
use Mojo::JSON qw(encode_json);
use Mojo::ByteStream 'b';
use MIME::Base64 'encode_base64';
use Try::Tiny;
use HTTP::BrowserDetect;
use QVD::Config;
use QVD::DB::Simple qw(db rs);
use QVD::DB::Common qw(ENUMERATES);
use QVD::VMProxy;

##### GLOBAL VARIABLES #####
my $MOJO_DB;
my $UA = Mojo::UserAgent->new->inactivity_timeout(0);;

##### PLUGINS #####

# Plugin for dropping privileges
my $user = cfg('up.api.user');
my $group = cfg('up.api.group');
plugin SetUserGroup => {user => $user, group => $group}
    if $< == 0 or $> == 0;

# Static web data provider
my $up_path = cfg('path.up');
app->static->paths->[0] = $up_path;

get '/' => sub {
    shift->reply->static('index.html');
};

##### HELPERS #####

# Query finishes and returns a response with a httpcode
helper (render_response => \&render_response);

# Query finishes and returns an error with a message and httpcode
helper (render_error => \&render_error);

# Stores the active channels of the postgres database
helper (pool => \&pool);

# Register a callback function to several postgres channels
helper(register_channels => \&register_channels);

##### CONFIGURATION #####

# Intended to set the address where the app is supposed to listen with hypnotoad
my $api_url = cfg('up.api.url');
my $cert_path = cfg('path.up.api.ssl.cert');
my $key_path = cfg('path.up.api.ssl.key');
my $path_run = cfg('path.run');
unless ( -e $path_run and -d $path_run ) { mkdir $path_run; }
die "Certificate $cert_path file does not exist" unless (-e $cert_path);
die "Private key $key_path file does not exist" unless (-e $key_path);

app->config(
    hypnotoad => {
        listen => ["$api_url?cert=${cert_path}&key=${key_path}"],
        accepts => 1000,
        clients => 1000,
        workers => 4,
        pid_file => '/var/run/qvd/qvd-up-api.pid'
    }
);

# Intended to store log info about the API

app->log( Mojo::Log->new( path => cfg('log.up.api.filename'), level => 'debug' ) );

# Response hooks

app->hook(before_render => sub {
    my ($c, $args) = @_;

    # Control known exceptions and return readable messages
    if(defined($args->{template}) && $args->{template} eq 'exception') {

        my $error_messages = [
            {
                exception => 'duplicate key value violates unique constraint "(.*)"',
                message   => sub {
                    my $constraint = shift;
                    my $constraint_to_column = {
                        workspaces_user_id_name => 'name',
                    };
                    return sprintf( 'Another element with the same %s already exists',
                        $constraint_to_column->{$constraint} );
                }
            }
        ];

        for my $error (@$error_messages) {
            if (my @matches = ($args->{exception} =~ /$error->{exception}/)) {
                $args->{json} = { message => $error->{message}->(@matches) };
                $args->{status} = 400;
                last;
            }
        }
        
        return;
    }
});

app->hook(after_render => sub {
    my ($c, $output, $format) = @_;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
});

###### API ######

# Common actions to every API call

under sub {
    my $c = shift;

    open STDOUT, ">>", cfg('up.api.stdout.filename');
    open STDERR, ">>", cfg('up.api.stderr.filename');

    $c->inactivity_timeout(cfg('up.api.request.timeout'));
};

# This url retrieves general info about the API.
any [qw(GET)] => '/api/info' => sub {
    my $c = shift;

    my $json = {
        status => "up",
    };

    return $c->render_response(json => $json);
};

# Generate session
any [ qw(POST) ] => '/api/login' => sub {
    my $c = shift;

    my $input_json = $c->req->json;

    return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
        if $_ = find_invalid_parameter (
            $input_json,
            {
                login         => { mandatory => 1, type => 'STRING' },
                password      => { mandatory => 0, type => 'STRING' },
            }
        );

    my $login = $input_json->{login};
    my $password = $input_json->{password} // "";

    my ($user, $tenant);
    for my $separator (split "", cfg('l7r.auth.plugin.default.separators')){
        ($user, $tenant) = split $separator, $login;
        last if (defined($user) && defined($tenant));
    }
    $tenant //= cfg('l7r.auth.plugin.default.tenant');

    my $authorization = "Basic " . encode_base64($login . ":". $password);

    my $ua = Mojo::UserAgent->new;
    my $l7r_vm_list_url = (cfg('l7r.use_ssl') ? "https" : "http") . "://" . cfg('up.api.l7r.address') .
        ":" . cfg('l7r.port') . "/qvd/authenticate_user?store_auth=1";
    my $auth_tx = $ua->cert( $cert_path )->key( $key_path )->
        get( $l7r_vm_list_url => { Authorization => $authorization } );

    my $http_code = $auth_tx->res->code // 502;
    my $http_json = $auth_tx->res->json // {};
    my $http_message = $auth_tx->res->message // "Authentication server unavailable";

    return $c->render_error(message => $http_message, code => $http_code)
        unless $http_code == 200;

    my $user_rs = rs('User')->search( { login => $user, password => password_to_token($password) } );

    my $tenant_obj = rs('Tenant')->search( { name => $tenant } )->first;
    my $tenant_id = defined($tenant_obj) ? $tenant_obj->id : undef;
    $user_rs = $user_rs->search( { tenant_id => $tenant_id } );

    my $user_obj = $user_rs->first;

    return $c->render_error(message => "Unauthorized", code => 401)
        unless defined $user_obj;
        
    # Create default workspace if needed
    if(scalar @{get_workspaces($user_obj->id)} == 0) {
        my $default_settings = {
            audio => { value => 0 },
            client => { value => 'html5' },
            printers => { value => 0 },
            connection => { value => 'adsl' },
            share_usb => { value => 0 },
            share_folders => { value => 0 },
            fullscreen => { value => 0 },
            kb_layout => { value => 'auto' }
        };
        create_workspace($user_obj->id, 'Default', 1, $default_settings, 1)
    }

    my $session = create_up_session_handler( $c->tx, db );

    $session->create;
    $session->data( user_name => $user );
    $session->data( tenant_name => $tenant );
    $session->data( login => $login );
    $session->data( user_id => $user_obj->id );
    $session->data( auth_params_id => $http_json->{auth_params_id} );
    $session->flush;

    my $json = { };
    $json->{sid} = $session->sid if defined($session);

    return $c->render_response(json => $json);
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
            $c->render_error(message => $message, code => 401);
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
       
        return $c->render_response(json => {});
    };

    # Account settings
    any [qw(GET)] => '/api/account' => sub {
        my $c = shift;
        
        my $user = rs('User')->find($c->stash('session')->data('user_id'));

        my $json = {};
        $json->{language} = $user->language;
        $json->{username} = $user->login;
        $json->{acls} = [];

        return $c->render_response(json => $json);
    };
    
    any [qw(PUT)] => '/api/account' => sub {
        my $c = shift;

        my $input_json = $c->req->json;

        return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
            if $_ = find_invalid_parameter (
                $input_json,
                {
                    language         => { mandatory => 0, type => 'LANGUAGE' },
                }
            );

        my $parameters = { language => $input_json->{'language'} };
        
        my $user = rs('User')->find($c->stash('session')->data('user_id'));
        $user->update( { language => $parameters->{language} } );
        
        my $json = {};
        $json->{language} = $user->language;
        $json->{username} = $user->login;
        $json->{acls} = [];
        
        return $c->render_response(json => $json);
    };

    any [qw(GET)] => '/api/account/last_connection' => sub {
        my $c = shift;

        my $connection = rs('User_Connection')->find($c->stash('session')->data('user_id'));
        return $c->render_error(message => 'No registered connection', code => 200) unless defined($connection);

        my $json = {};
        $json->{location} = $connection->location;
        $json->{datetime} = $connection->datetime;
        $json->{browser} = $connection->browser;
        $json->{os} = $connection->os;
        $json->{device} = $connection->device;

        return $c->render_response(json => $json);
    };

        # Desktops
    any [qw(GET)] => '/api/desktops' => sub {
        my $c = shift;

        my $desktop_list = [ map vm_to_desktop_hash($_),
            rs( "VM" )->search( 
                { user_id => $c->stash('session')->data('user_id') },
                { order_by => { -asc => 'id' } } 
            )->all ];

        return $c->render_response(json => $desktop_list);
    };

    any [qw(GET)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $vm_id = $c->param('id');
        my $user_id = $c->stash('session')->data('user_id');
        my $vm = rs( "VM" )->single( { id => $vm_id, user_id => $user_id } );
        return $c->render_error(message => "Invalid Desktop", code => 400) unless defined($vm);

        my $desktop = vm_to_desktop_hash($vm);
        
        return $c->render_response(json => $desktop);
    };
    
    any [qw(PUT)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;
            
        my $vm_id = $c->param('id');
        my $user_id = $c->stash('session')->data('user_id');
        my $vm = rs( "VM" )->single( { id => $vm_id, user_id => $user_id } );
        return $c->render_error(message => "Invalid Desktop", code => 400) unless defined($vm);

        my $json = $c->req->json;

        my $desktop = $vm->desktop;
        my @settings = $desktop ? $desktop->settings->all : ();

        return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
            if $_ = find_invalid_parameter ( 
                $json,
                {
                    alias            => { mandatory => 0, type => 'STRING' },
                    settings_enabled => { mandatory => 0, type => 'BOOL' },
                    settings         => { mandatory => (@settings) ? 0 : 1, type => (@settings) ? 'SOME_PARAMETERS' : 'ALL_PARAMETERS'},
                }
            );
            
        my $args = {};
        $args->{alias} =  $_ if defined($_ = $json->{alias});
        $args->{active} = $_ if defined($_ = $json->{settings_enabled});

        if( $desktop ) {
            $desktop->update($args);
        } else {
            $desktop = rs('Desktop')->create({
                vm_id => $vm_id,
                %$args
            });
        }
            
        for my $param (keys %{$json->{settings}}) {
            my $setting = rs('Desktop_Setting')->single({
                    desktop_id => $desktop->id,
                    parameter => $param,
                });
            if ($setting) {
                $setting->update({ value => $_ }) if defined($_ = $json->{settings}->{$param}->{value});
                $setting->collection->delete();
            } else {
                $setting = rs('Desktop_Setting')->create({
                        desktop_id => $desktop->id,
                        parameter => $param,
                        value => $json->{settings}->{$param}->{value},
                    });
            }

            for my $item (@{$json->{settings}->{$param}->{list} // []}) {
                rs('Desktop_Setting_Collection')->create({
                        setting_id => $setting->id,
                        item_value => $item
                    });
            }
        }

        return $c->render_response(json => vm_to_desktop_hash($vm));
    };
    
    any [qw(DELETE)] => '/api/desktops/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $vm_id = $c->param('id');
        my $user_id = $c->stash('session')->data('user_id');
        my $vm = rs( "VM" )->single( { id => $vm_id, user_id => $user_id } );
        return $c->render_error(message => "Invalid Desktop", code => 400) unless defined($vm);

        my $json = $c->req->json;

        return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
            if $_ = find_invalid_parameter (
                $json,
                {
                    settings_only => { mandatory => 0, type => 'BOOL' },
                }
            );
    
        if( my $desktop = $vm->desktop ) {
            if($json->{settings_only}){
                $desktop->settings->delete();
            } else {
                $desktop->delete();
            }
        }

        return $c->render_response(json => {});
    };

    any [qw(GET)] => '/api/desktops/:id/token' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $session_up = $c->stash->{session};

        my $vm_id = $c->param('id');
        my $user_id = $session_up->data->{user_id};

        my $vm = rs( "VM" )->search( { id => $vm_id, user_id => $user_id } )->first;
        return $c->render_error(message => "Invalid Desktop", code => 400) unless defined($vm);

        my $session_l7r = rs('User_Token')->create( { 
            token => generate_sid(),
            expiration => time + cfg('up.api.l7r.session.expiration'),
            user_id => $session_up->data->{user_id},
            vm_id =>  $vm_id,
            auth_params_id => $session_up->data->{auth_params_id},
        } );
        my $token = encode_base64($session_l7r->token);
        chomp($token);

        register_user_connection($user_id, $c->tx);

        return $c->render_response(json => { token => $token });
    };

    any [qw(GET)] => '/api/desktops/:id/setup' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $session_up = $c->stash->{session};

        my $vm_id = $c->param('id');
        my $user_id = $session_up->data->{user_id};
        
        my $vm = rs( "VM" )->search( { id => $vm_id, user_id => $user_id } )->first;
        return $c->render_error(message => "Invalid Desktop", code => 400) unless defined($vm);

        my $element;
        if($vm->desktop && $vm->desktop->settings && $vm->desktop->active){
            $element = $vm->desktop;
        } else {
            my $ws = rs( "Workspace" )->single( { user_id => $user_id, active => 1 } );
            $element = $ws;
        }

        my $json = {};
        $json->{settings} = element_settings($element);
        $json->{hostname} = cfg('up.api.l7r.address');
        
        return $c->render_response(json => $json);
    };

    # Workspaces
    any [qw(GET)] => '/api/workspaces' => sub {
        my $c = shift;

        my $user_id = $c->stash('session')->data->{user_id};
        my $workspaces = get_workspaces($user_id);
        
        return $c->render_response(json => [ map { workspace_to_hash($_) } @{$workspaces} ] );
    };

    any [qw(GET)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $ws_id = $c->param('id');
        my $user_id = $c->stash->{session}->data->{user_id};

        my $workspace = get_workspace($user_id, $ws_id);
        return $c->render_error(message => "Invalid Workspace", code => 400) unless defined($workspace);

        return $c->render_response(json => workspace_to_hash($workspace));
    };

    any [qw(POST)] => '/api/workspaces/' => sub {
        my $c = shift;

        my $user_id = $c->stash->{session}->data->{user_id};

        my $json = $c->req->json;

        return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
            if $_ = find_invalid_parameter (
                $json,
                {
                    name       => { mandatory => 1, type => 'STRING' },
                    active     => { mandatory => 1, type => 'BOOL' },
                    settings   => { mandatory => 1, type => 'ALL_PARAMETERS' },
                }
            );

        return $c->render_error(message => "Cannot activate workspaces with no settings", code => 400)
            if $json->{active} && !defined($json->{settings});
            
        my $workspace = create_workspace($user_id, $json->{name}, $json->{active}, $json->{settings}, 0);

        return $c->render_response(json => workspace_to_hash($workspace));
    };

    any [qw(PUT)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;

        my $ws_id = $c->param('id');
        my $user_id = $c->stash->{session}->data->{user_id};

        my $workspace = rs('Workspace')->single({id => $ws_id, user_id => $user_id});
        return $c->render_error(message => "Invalid Workspace", code => 400) unless defined($workspace);
        my $settings = $workspace->settings->all;

        my $json = $c->req->json;

        return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
            if $_ = find_invalid_parameter (
                $json,
                {
                    name       => { mandatory => 0, type => 'STRING' },
                    active     => { mandatory => 0, type => 'FLAG' },
                    settings   => { mandatory => 0, type => ($settings) ? 'SOME_PARAMETERS' : 'ALL_PARAMETERS' },
                }
            );
            
        return $c->render_error(message => "Cannot activate workspaces with no settings", code => 400)
            if $json->{active} && !($settings || defined($json->{settings}));

        my $args = {};
        $args->{name} = $_ if defined($_ = $json->{name});
        $args->{active} = $_ if defined($_ = $json->{active});

        if($args->{active} && !$workspace->active){
            rs('Workspace')->search({active => 1})->update({active => 0});
        }

        $workspace->update({ %$args });

        for my $param (keys %{$json->{settings}}) {
            my $setting = rs( 'Workspace_Setting' )->single( {
                    workspace_id => $workspace->id,
                    parameter    => $param,
                } );

            if(!$setting){
                rs( 'Workspace_Setting' )->create( {
                        workspace_id => $workspace->id,
                        parameter    => $param,
                        value        => $json->{settings}->{$param}->{value},
                    } );
            } else {
                $setting->update({ value => $json->{settings}->{$param}->{value} });
                $setting->collection->delete();
            }

            for my $item (@{$json->{settings}->{$param}->{list} // [ ]}) {
                rs( 'Workspace_Setting_Collection' )->create( {
                        setting_id => $setting->id,
                        item_value => $item
                    } );
            }
        }

        return $c->render_response(json => workspace_to_hash($workspace));
    };

    any [qw(DELETE)] => '/api/workspaces/:id' => [id => qr/\d+/] => sub {
        my $c = shift;
            
        my $ws_id = $c->param('id');
        my $user_id = $c->stash->{session}->data->{user_id};

        my $workspace = rs( "Workspace" )->single( { id => $ws_id, user_id => $user_id } );
        return $c->render_error(message => "Invalid Workspace", code => 400) unless defined($workspace);

        return $c->render_error(message => "Fixed Workspace cannot be deleted", code => 400)
            if $workspace->fixed;

        my $name = $workspace->name;
            
        if($workspace->active){
            my $min_id = rs('Workspace')->search({user_id => $user_id})->get_column('id')->min;
            rs( "Workspace" )->find({id => $min_id})->update({active => 1})
        }

        $workspace->delete();

        return $c->render_response(json => {}, code => 200);
    };

    # Websockets
        
    group {
        
        under sub {
            my $c = shift;

            $c->inactivity_timeout(cfg('up.api.websocket.timeout'));
        };
                
        websocket '/api/ws/desktops' => sub {
            my $c = shift;

            my $user_id = $c->stash->{session}->data->{user_id};

            $c->register_channels(
                $user_id,
                [ 'desktop_changed' ],
                sub {
                    my $vm_id = shift;
                    my $vm = rs( 'VM' )->single( { id => $vm_id } );
                    return { id => $vm->id, user_state => $vm->vm_runtime->user_state, vm_state => $vm->vm_runtime->vm_state };
                }
            );
        };

        websocket '/api/desktops/:id/connect' => sub {
            my $c = shift;

            my $json = $c->req->params->to_hash;
            return $c->render_error(message => $_->{message}, parameters => $_->{parameters}, code => 400)
                if $_ = find_invalid_parameter (
                    $json,
                    {
                        token      => { mandatory => 1, type => 'STRING' },
                        resolution => { mandatory => 1, type => 'STRING' },
                        kb_layout => { mandatory => 1, type => 'STRING' },
                    }
                );

            $c->app->log->debug("VM Proxy WebSocket opened");
            $c->on(finish => sub { $c->app->log->debug( "VM Proxy WebSocket closed" ); } );

            my $l7r_address = cfg('up.api.l7r.address');
            my $l7r_port = cfg('l7r.port');
            my $broker = QVD::UP::H5GW::SessionManager->new( host => $l7r_address, port => $l7r_port );

            my $vm_id = $c->param('id');
            my $user_id = $c->stash('session')->data('user_id');
            my $vm = rs('VM')->find($vm_id);

            return $c->render_error(message => "Invalid Desktop", code => 400)
                unless (defined($vm) && ($vm->user_id == $user_id));

            my $vm_state = $vm->vm_runtime->vm_state;
            return $c->render_error(message => "Invalid Desktop state", code => 400)
                unless ($vm_state eq "stopped" || $vm_state eq "running");
            
            my $tx = $c->tx;
            $tx->with_protocols( 'binary' );

            $tx->on(finish => sub { $broker->stop_tunnel(); } );

            Mojo::IOLoop::singleton->delay(
                sub {
                    my ($delay) = @_;
                    my $end = $delay->begin;
                    $c->app->log->debug("Create tunnel to L7R $l7r_address:$l7r_port");
                    $c->app->log->debug("Keyboard layout: $json->{kb_layout}");
                    $broker->start_tunnel(
                        {
                            'vm_id' => $vm_id,
                            'token' => $json->{token},
                            'resolution' => $json->{resolution} // cfg('up.api.default.resolution'),
                            'kb_layout' => $json->{kb_layout} // cfg('up.api.default.kb_layout'),
                        },
                        sub { $end->(); }
                    );
                },
                sub {
                    my ($delay) = @_;
                    my $url = $broker->attach_url();
                    $c->app->log->debug("Create tunnel to H5GW $url");
                    my $proxy = QVD::VMProxy->new( 
                        url  => $url,
                    );

                    # NOTE: User Agent must be global because other way
                    # it is lost from current context
                    $proxy->open_ws($tx, $UA);
                }
            );

        };

    }

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
        expires_delta => cfg('up.api.session.expiration')
    );
    
    return $session;
}

sub password_to_token
{
    my ($password) = @_;
    require Digest::SHA;
    return Digest::SHA::sha256_base64(cfg('l7r.auth.plugin.default.salt') . $password);
}

sub find_invalid_parameter {
    my ($params, $syntax) = @_;

    my %union = map {$_ => 1} (keys %$params, keys %$syntax);
    for my $param (keys %union) {
        my $mandatory = $syntax->{$param}->{mandatory} // 1;
        my $type = $syntax->{$param}->{type} // 'STRING';
        
        if(!defined($params->{$param}) && $mandatory) {
            return { message => "Parameter __name__ is compulsory", parameters => { name => $param } };
        } elsif ( defined($params->{$param}) && !check_type($params->{$param}, $type) ) {
            return { message => "Parameter __name__ shall be of type __type__", parameters => { name => $param, type => $type } };
        }
    }

    return undef;
}

sub check_type {
    my ($value, $type) = @_;
    
    return 0 unless defined($value);

    my $is_correct = 0;

    if ($type eq 'FLAG') {
        $is_correct = $value == 1;
    } elsif ($type eq 'BOOL') {
        $is_correct = ($value == 1 || $value == 0);
    }
    elsif ($type eq 'INTEGER') {
        $is_correct = ($value =~ /^\d+$/);
    }
    elsif ($type eq 'DOUBLE') {
        $is_correct = ($value =~ /^\-?\d+(.\d+)?$/);
    }
    elsif ($type eq 'STRING') {
        $is_correct = ($value =~ /^.*$/);
    }
    elsif ($type eq 'ARRAY_OF_STRING') {
        $is_correct = ref($value) eq 'ARRAY' && ((@$value == 0) || !grep(0, map {check_type($_, 'STRING')} @$value));
    }
    elsif ($type eq 'LANGUAGE') {
        $is_correct = (grep { $_ eq $value } @{ENUMERATES()->{language_enum}}) ? 1 : 0;
    }
    elsif ($type eq 'SETTING') {
        $is_correct = ref($value) eq 'HASH' &&
            defined($value->{value}) &&
            check_type($value->{list} // [], 'ARRAY_OF_STRING');
    }
    elsif ($type eq 'ALL_PARAMETERS') {
        for my $param (@{ENUMERATES()->{user_portal_parameters_enum}}) {
            unless(defined($value->{$param}) and check_type($value->{$param}, 'SETTING')){
                $is_correct = 0;
                last;
            }
            $is_correct = 1;
        }
    }
    elsif ($type eq 'SOME_PARAMETERS') {
        for my $param (keys(%$value)) {
            unless (grep($param, @{ENUMERATES()->{user_portal_parameters_enum}}) and check_type($value->{$param}, 'SETTING')) {
                $is_correct = 0;
                last;
            }
            $is_correct = 1;
        }
    }
    else {
        $is_correct = 1;
    }

    return $is_correct;
}

sub vm_to_desktop_hash {
    my $vm = shift;
    my $desktop = $vm->desktop;
    my $hash = {
        id => $vm->id,
        blocked => $vm->vm_runtime->blocked || $vm->di->blocked,
        name => $vm->name,
        alias => defined($desktop) ? $desktop->alias : undef,
        state => $vm->vm_runtime->user_state,
        vm_state => $vm->vm_runtime->vm_state,
        settings_enabled => defined($desktop) ? $desktop->active : 0,
        settings => element_settings($desktop),
    };
    return $hash;
}

sub workspace_to_hash {
    my $ws = shift;
    my $hash = {
        id => $ws->id,
        fixed => $ws->fixed,
        name => $ws->name,
        active => $ws->active,
        settings => element_settings($ws),
    };
    return $hash;
}

sub element_settings {
    my $element = shift;
    my $settings = undef;

    if (defined($element) && $element->settings->all){
        $settings = { map { $_ => {} } @{ ENUMERATES()->{user_portal_parameters_enum} } };
        for my $enum (keys %$settings) {
            $settings->{$enum}->{value} = $element->settings->single({parameter => $enum})->value;
            $settings->{$enum}->{list} = [ map { $_->item_value } ($element->settings->single({parameter => $enum})->collection->all) ];
        }
    }
    return $settings;
}

sub register_user_connection {
    my ($user_id, $tx) = @_;
    
    my $user_agent = $tx->req->headers->user_agent;
    my $ip_address = $tx->remote_address;
    my $location = $tx->req->headers->header('Geo-Location');

    my $browser = HTTP::BrowserDetect->new($user_agent);
    
    my $connection = rs('User_Connection')->single({id => $user_id});
    $connection = rs('User_Connection')->create({id => $user_id}) unless ($connection);

    my $datestring = localtime();
    $connection->update({
            ip_address => $ip_address,
            location   => $location,
            datetime   => $datestring,
            browser    => sprintf("%s%s", $browser->browser_string // "Unknown", defined($_ = $browser->browser_version) ? " $_" : ""),
            os         => sprintf("%s%s", $browser->os_string // "Unknown", defined($_ = $browser->os_version) ? " $_" : ""),
            device     => ( $browser->mobile ? "Mobile" : ($browser->tablet ? "Tablet" : "Desktop") ),
        });
}
    
# Helpers

sub render_response {
    my $c = shift;
    my %args = @_;

    $c->render(json => $args{json} // {}, status => 200);

    return 1;
}

sub render_error {
    my $c = shift;
    my %args = @_;

    my $params = $args{parameters} // {};
    my $message = $args{message} // "";
    my $code = $args{code} // 400;

    $c->render(json => {message => $message, parameters => $params}, status => $code);

    return 1;
}
    
sub pool
{
    my $c = shift;

    unless($MOJO_DB){
        my $host     = cfg('database.host');
        my $dbname   = cfg('database.name');
        my $user     = cfg('database.user');
        my $password = cfg('database.password');
        $MOJO_DB = Mojo::Pg->new("postgresql://${user}:${password}\@${host}/${dbname}");
    }

    return $MOJO_DB->pubsub;
}

sub register_channels {
    my $c = shift;

    my $user_id = shift;
    my $channels = shift;
    my $function = shift;

    my @queue = ();

    for my $channel (@$channels)
    {
        $c->pool->listen($channel => sub {
                my ($pool, $payload) = @_;
                my %payload_hash = split(/[=;]/, $payload);
                $payload_hash{channel} = eval { "$channel" };
                push @queue, \%payload_hash;
            });
    }

    my $recurring = Mojo::IOLoop->recurring(
        2 => sub {
            while(@queue){
                my $payload = shift @queue;
                my $received_user_id = $payload->{user_id} // -1;
                if ($received_user_id == $user_id) {
                    $c->app->log->debug( "WebSocket refreshing information" );
                    my $res = $function->( $payload->{vm_id} );
                    $c->send( b( encode_json( $res ) )->decode( 'UTF-8' ) );
                }
            }
            return 1;
        }
    );

    $c->on(message => sub {
            my ($c, $msg) = @_;
            $c->app->log->debug("WebSocket $msg signal received");
        });

    $c->on(finish => sub {
            my ($c, $code) = @_;
            Mojo::IOLoop->remove($recurring) if $recurring;
            $c->app->log->debug("WebSocket closed with status $code");
        });
};

__END__

=pod

=head1 PURPOSE

Script intended to run an instance of the QVD UP API

=cut
