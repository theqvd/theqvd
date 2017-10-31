#!/usr/bin/perl

BEGIN {
	$QVD::Config::USE_DB = 1;
	@QVD::Config::Core::FILES = (
		'/etc/qvd/node.conf',
		'/etc/qvd/api.conf',
		($ENV{HOME} || $ENV{APPDATA}).'/.qvd/api.conf',
		'qvd-api.conf',
	);
}

use Mojolicious::Lite;
use Mojo::JSON qw(encode_json decode_json j to_json);
use QVD::API::Exception;
use MojoX::Session;
use File::Copy qw(copy move);
use Mojo::IOLoop::ForkCall;
use Mojo::Log;
use Mojo::ByteStream 'b';
use Deep::Encode;
use File::Copy qw(copy move);
use QVD::Config;
use QVD::VMProxy;
use Try::Tiny;
use Data::Rmap qw(rmap_ref);

# This plugin is the class intended to manage the API queries.
# Almost all queries are processed by it

plugin 'QVD::API::REST';

# Plugin for dropping privileges

my $user = app->qvd_admin4_api->_cfg('api.user');
my $group = app->qvd_admin4_api->_cfg('api.group');
plugin SetUserGroup => {user => $user, group => $group}
    if $< == 0 or $> == 0;

# HELPERS

# General function to manage api calls and exceptions
helper (qvd_api_call => \&qvd_api_call);

# Log exception into QVD log
helper (log_qvd_exception => \&log_qvd_exception);

# Intended to check and encode the JSON that receives the API as iunput

helper (get_input_json => \&get_input_json); 

# Intended to get the JSON query that the API receives, process it and return a response

helper (process_api_query => \&process_api_query); 

# Every ACTION supported by the API can be related to one or more channels 
# in the database. These channels notify when something happens in the database
# that may change the output of the ACTION. 

helper (get_action_channels => \&get_action_channels);

# Helpers for authentication purposes.

helper (credentials_provided => \&credentials_provided);
helper (create_session => \&create_session);
helper (update_session => \&update_session);

# Reports problems with disk images upload/download/copy in log

helper (report_di_problem_in_log => \&report_di_problem_in_log);

# Download and publish an image from a url
helper (download_image_from_url => \&download_image_from_url);

# Intended to avoid a max size for file uploads. 
# Needed for disk images uploads.

$ENV{MOJO_MAX_MESSAGE_SIZE} = 0;

# This var sets the place where disk images will be uploaded
# It must be in the same filesystem that the storage/images directory
# in order to avoid problems while moving the disk images after the upload
# is accomplished.  

$ENV{MOJO_TMPDIR} = app->qvd_admin4_api->_cfg('path.storage.images');

# Intended to set the address where the app is supposed to listen with hypnotoad
# CONFIGURATION
my $api_url = app->qvd_admin4_api->_cfg('api.url');
my $cert_path = app->qvd_admin4_api->_cfg('path.api.ssl.cert');
my $key_path = app->qvd_admin4_api->_cfg('path.api.ssl.key');
my $pid_file = app->qvd_admin4_api->_cfg('path.api.pid_file');
my $path_run = app->qvd_admin4_api->_cfg('path.run');
# We suppose here pid_file resides in /var/run/qvd ...
unless ( -e $path_run and -d $path_run ) { mkdir $path_run; }
die "Directory $path_run can't be created by this process" unless (-e $path_run);
die "Certificate $cert_path file does not exist" unless (-e $cert_path);
die "Private key $key_path file does not exist" unless (-e $key_path);

app->config(
    hypnotoad => {
        listen => ["$api_url?cert=${cert_path}&key=${key_path}"],
        accepts => 1000,
        clients => 1000,
        workers => 4,
        pid_file => $pid_file
    }
);

# Static web data provider
my $wat_path = app->qvd_admin4_api->_cfg('path.wat');
app->static->paths->[0] = $wat_path;

get '/' => sub {
    shift->reply->static('index.html');
};

app->hook(after_render => sub {
    my ($c, $output, $format) = @_;
        
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
});

# Intended to store log info about the API

app->log( Mojo::Log->new( path => app->qvd_admin4_api->_cfg('log.api.filename'), level => 'debug' ) );

# Package that implements an ad hoc transport system for the sessions manager (MojoX::Session) 
# According to MojoX::Session specifications, it must provide methods intended to get the session
# id from the request and to set the session id in response.

package MojoX::Session::Transport::WAT
{
    use base qw(MojoX::Session::Transport);

    sub get {
        my ($self) = @_;
    
        my $sid = $self->tx->req->params->param('sid');
        
        unless (defined($sid)) {
            my $cookie = (grep { $_->name eq "sid" } @{$self->tx->req->cookies})[0];
            $sid = $cookie->value if defined($cookie);
        }
    
        return $sid;
    }
    
    sub set {
        my ($self, $sid, $expires) = @_;
        my $cookie = Mojo::Cookie::Response->new(name => 'sid', value => $sid, expires => $expires, httponly => 1, secure => 1);
        $self->tx->res->cookies($cookie);
        return 1;
    }
}

######################
######## URLS ########
######################

# Common 
under sub {
    my $c = shift;
        
    $c->app->log->debug("PARAMS: " . Mojo::JSON::to_json($c->get_input_json));

    my $stdout_file = $c->qvd_admin4_api->_cfg('api.stdout.filename');
    my $stderr_file = $c->qvd_admin4_api->_cfg('api.stderr.filename');
    open STDOUT, ">>", $stdout_file if defined($stdout_file);
    open STDERR, ">>", $stderr_file if defined($stderr_file);

    return 1;
};

# This url retrieves general info about the API.
# This url can be accessed without authentication

any [qw(POST GET)] => '/api/info' => sub {
  my $c = shift;

  QVD::Config::reload();
  my $utc_time = gmtime();

	my $json = {
		status => 0,
		server_datetime => $utc_time,
		multitenant => $c->qvd_admin4_api->_cfg('wat.multitenant'),
		version => { database => $c->qvd_admin4_api->database_version },
		public_configuration => cfg_tree('api.public'),
		auth => { separators => [ split('', cfg('l7r.auth.plugin.default.separators')) ] },
	};

  $c->render(json => $json );
};

any [qw(POST)] => '/api/di/notify' => sub { shift->qvd_api_call(\&update_di_status) };

group {

    # Mojolicious::Lite 'under' is intended to check authentication credentials
    # All urls written in this file after 'under' will be reached only after 
    # the 'under' function is executed and returns 'true'.

    under sub {

        my $c = shift;
        my $bool = 0;

        QVD::Config::reload(); # Needed to avoid QVD::Config refreshing problems

        my $json = $c->get_input_json;

        my %session_args = (
            store  => [dbi => {dbh => QVD::DB::Simple->db()->storage->dbh}],
            transport => MojoX::Session::Transport::WAT->new(),
            tx => $c->tx,
            ip_match => 1
        );

        my $session = MojoX::Session->new(%session_args);

        my $exception;
        try {
            $bool = $c->credentials_provided($json) ? $c->create_session($session, $json) : $c->update_session($session);
            $c->stash({session => $session});
        } catch {
            $exception = $_;
            $bool = 0;
            $c->render(json => $exception->json);
        };

        QVD::API::LogReport->new(
            action => { action => 'login', type_of_action => 'login' },
            qvd_object => 'administrator',
            tenant => {
                tenant_id => $session->data('tenant_id'),
                tenant_name => $session->data('tenant_name')
            },
            object => {
                object_id =>  $session->data('admin_id'),
                object_name =>  $session->data('admin_name')
            },
            administrator => {
                administrator_id =>  $session->data('admin_id'),
                administrator_name =>  $session->data('admin_name'),
                superadmin =>  $session->data('superadmin')
            },
            ip => $c->tx->remote_address,
            source => eval { $json->{parameters}->{source} } // undef,
            arguments => {},
            status => defined($exception) ? $exception->code : 0,
        )->report;

        return $bool;
    };


    # This is the main url in the API

    any [qw(POST GET)] => '/api' => sub {

        my $c = shift;

        $c->inactivity_timeout(30000);     
        my $json = $c->get_input_json;
        my $response = $c->process_api_query($json);
            
        if ($json->{action} eq "current_admin_setup") {
            $response->{sid} = $c->stash('session')->sid;
        }

        # Retrieving the right encode is tricky.
        # With this system accents and so on are supported.
        # WARNING: we're rendering in json text mode. The json mode break the accents
        # Maybe a problem in Mojo?

        deep_utf8_decode($response);
        $c->render(text => b(encode_json($response))->decode('UTF-8'));
    };

    # Log out url
    any [qw(POST GET)] => '/api/logout' => sub {
    
        my $c = shift;
    
        $c->inactivity_timeout(30000);
    
        my $session = $c->stash('session');
        $session->expire;
        $session->clear;
    
        my $code = $session->flush ? 0000 : 3600;
        my $exception = QVD::API::Exception->new(code => $code);
    
        my $response = {
            status => $exception->code,
            message => $exception->message
        };
    
        $c->render(text => b(encode_json($response))->decode('UTF-8'));
    };


    # This websocket is intended to report the current state of the system in real time
    # number of vms running, number vms in a host and so on.

    websocket '/api/ws' => sub {
        my $c = shift;
        $c->app->log->debug("WebSocket opened");
        $c->inactivity_timeout(30000);
        my $json = $c->get_input_json;
        my $notification = 0;
        my %payload_hash;

        my $res = $c->process_api_query($json);
        $c->send(b(encode_json($res))->decode('UTF-8'));

        # For every action requested to the API we can get 0, 1 or more channels to listen in the
        # database. When the database notifies in those channels, this ws executes the action again
        # and sends the updated info to the client

        for my $channel ($c->get_action_channels($json))
        {
            $c->qvd_admin4_api->pool->listen($channel => sub {
                my ($pool, $payload) = @_;
                %payload_hash = split(/[=;]/, $payload);
                $payload_hash{channel} = eval { "$channel" };
                $notification = 1;
            });
        }

        my $currentTenant = $c->qvd_admin4_api->{administrator}->tenant->id;
        my $recurring = Mojo::IOLoop->recurring(
            2 => sub {
                my $received_tenant_id = $payload_hash{tenant_id} // -1;
                if ($notification and (($currentTenant == 0) or
                    ($received_tenant_id == -1) or
                    ($received_tenant_id == $currentTenant))) {

                    $c->app->log->debug("WebSocket refreshing information");
                    my $res = $c->process_api_query($json);
                    $c->send(b(encode_json($res))->decode('UTF-8'));
                }

                $notification = 0;
                %payload_hash = ();

                return 1;
            }
        );

        my $timer;
        $c->on(message => sub {
            my ($c, $msg) = @_;
            $c->app->log->debug("WebSocket $msg signal received");
            Mojo::IOLoop->remove($timer) if $timer;
            $timer = Mojo::IOLoop->timer(25 => sub { $c->send('AKN'); } );
        });

        $c->on(finish => sub {
            my ($c, $code) = @_;
            Mojo::IOLoop->remove($timer) if $timer;
            Mojo::IOLoop->remove($recurring) if $recurring;
            $c->app->log->debug("WebSocket closed with status $code");
        });
    };


    # URLs intended to DI creation

    # CREATIION OF DISK IMAGES USING DIG
        
    any [qw(POST)] => '/api/di/generate' => sub { shift->qvd_api_call(\&generate_di) };

    # COPY OF DISK IMAGES FROM STAGING

    any [qw(POST)] => '/api/di/staging' => sub { shift->qvd_api_call(\&copy_image_from_staging) };

    # UPLOAD OF DISK IMAGES

    any [qw(POST)] => '/api/di/upload' => sub { shift->qvd_api_call(\&upload_image_from_local) };

    # DOWNLOAD OF DISK IMAGES

    any [qw(POST)] => '/api/di/download' => sub { shift->qvd_api_call(\&download_image_from_url_request) };
    
    # PUBLISH DISK IMAGE

    any [qw(POST)] => '/api/di/publish' => sub { shift->qvd_api_call(\&publish_disk_image_request) };

    # API PROXY
    
    any [] => '/api/proxy/:api_code/*params' => sub {
        my $c = shift;
        
        my $api_code = $c->param('api_code');
        my $params = $c->param('params');
        
        my $session = $c->stash('session');
        my $tenant_id = $session->data('tenant_id');
        my $api_url = $c->qvd_admin4_api->_cfg('api.proxy.' . $api_code . '.address', $tenant_id, 0);
        my $response_str;
        my $code;
        
        my $query_params = $c->tx->req->params->to_string;
        
        $params = $params . '?' . $query_params unless $query_params eq '';
        
        if (defined $api_url) {
            my $full_api_url = $api_url . "/" . $params;
            my $method = $c->tx->req->method;

            my $tx = $c->ua->build_tx($method => $full_api_url => $c->req->headers->to_hash => $c->req->build_body);
            $tx = $c->ua->start($tx);
            
            if (my $res = $tx->success) {
                $c->tx->{res} = $res;
                $c->rendered();
            }
            else {
                $c->render(json => QVD::API::Exception->new(code => 1100)->json);
            }
        }
        else {
            $c->render(json => QVD::API::Exception->new(code => 6620)->json);
        }
    };

    websocket '/vmproxy' => sub {
        my $c = shift;

        my $admin = $c->qvd_admin4_api->administrator;
        unless ($admin->re_is_allowed_to( qr/^vm\.spy\.$/ )) {
            die QVD::API::Exception->new(code => 4210)->message;
        }

        $c->inactivity_timeout(0);

        $c->app->log->debug("VM Proxy WebSocket opened");
        $c->render_later->on(finish => sub { $c->app->log->debug("VM Proxy WebSocket closed"); });

        my $json = $c->get_input_json;
        my $vm_id = $json->{arguments}->{vm_id};
        die QVD::API::Exception->new(code => 6240, object => "vm_id")->message unless (defined($vm_id));

        my $vm = $c->qvd_admin4_api->_db->resultset('VM_Runtime')->find($vm_id);
        if (defined($vm) && (my $vm_ip = $vm->vm_address) && (my $vm_port = $vm->vm_vma_port) 
            && ($vm->vm_state eq 'running')) 
        {
            my $tx = $c->tx;
            $tx->with_protocols( 'binary' );

            my $ws = QVD::VMProxy->new( url => "http://$vm_ip:$vm_port" );
            $ws->open($tx, 1);
        }
        else 
        {
            die QVD::API::Exception->new(code => 6310, object => $vm_id)->message;
        }
    };
};

app->start;

#### General API callbacks ####

sub qvd_api_call {
    my $controller = shift;
    my $call_back = shift;
    
    $controller->inactivity_timeout(3000);
    
    my $response = undef;
    try {
        $response = $call_back->($controller);
    } catch {
        my $exception = shift;
        $exception = $controller->log_qvd_exception($exception);
        $response = $exception->json;
    }
        
    deep_utf8_decode($response);
    $controller->render(text => b(encode_json($response))->decode('UTF-8'));
}

sub log_qvd_exception {
    my $controller = shift;
    my $exception = shift;
    if(ref($exception) eq "QVD::API::Exception") {
        $controller->app->log->debug($exception->stack_trace);
    } else {
        $controller->app->log->debug($exception);
        $exception = QVD::API::Exception->new(code => 1100);
    }
    $controller->app->log->error("Exception " . $exception->code . " : " . $exception->message);
    return $exception;
}

#### API callbacks ####

sub generate_di {
    my $c = shift;
    
    # Get JSON
    my $json = $c->get_input_json;
    
    # Get configuration parameters
    my $session = $c->stash('session');
    my $tenant_id = $session->data('tenant_id');
    my $api_url = $c->qvd_admin4_api->_cfg('api.proxy.dig.address', $tenant_id, 0);
    QVD::API::Exception->new(code => 3700, additional_info => 'api.proxy.dig.address')->throw
        unless defined($api_url);
    
    # Check the OSF is related to an OSD
    my $osf_id = $json->{arguments}->{osf_id};
    my $osf = $c->qvd_admin4_api->_db->resultset('OSF')->find({ id => $osf_id });
    QVD::API::Exception->new(code => 7500)->throw
        unless defined($osf) && defined($osf->osd_id);
    
    # Create image with JSON
    my $response = $c->process_api_query( $json );
    if ($response->{status} == 0) {
        # Get new DI parameters
        my $di_id = ${$response->{rows}}[0]->{id};
        my $di_obj = $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id });
        QVD::API::Exception->new(code => 1100)->throw
            unless defined($di_obj);
        
        my $osd_id = $di_obj->osf->osd_id;
        my $di_name = $di_obj->path;
        
        # Call DIG to generate image
        my $tx = $c->ua->build_tx(POST => $api_url . "/osd/$osd_id/image" => {Accept => '*/*'} => json => { name => "$di_name" });
        $tx = $c->ua->start($tx);
        
        if($tx->success) {
            # Update DI state to generating
            my $dig_id = $tx->res->json->{id};
            $c->qvd_admin4_api->_db->resultset('DI_Runtime')
                ->find({ di_id => $di_id })
                ->update({ foreign_id => $dig_id, percentage => 0 });
            $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'generating');
        } else {
            # Update DI state to fail
            my $message = $tx->res->json->{status} // "";
            $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'fail', $message);
            QVD::API::Exception->new(code => 2280)->throw;
        }
    }
    
    return $response;
};

sub copy_image_from_staging {
    my $c = shift;
    $c->inactivity_timeout(3000);
    $c->app->log->debug("Staging WebSocket opened");
    
    my $json = $c->get_input_json;
    $json->{sid} //= $c->tx->res->headers->header('sid');
    my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
    my $staging_path = $c->qvd_admin4_api->_cfg('path.storage.staging');
    my $staging_file = eval { $json->{arguments}->{disk_image} } // '';
    my $images_file = $staging_file . '-tmp'. rand;
    my $total_size = eval { -s "$staging_path/$staging_file" } // 0;
    
    # Create DI object in DB
    my $response = $c->process_api_query( $json );
    if ($response->{status} != 0) {
        QVD::API::Exception->new(code => $response->{status})->throw;
    }
    my $di_id = ${$response->{rows}}[0]->{id};
    
    # Get DI information
    my $di_obj = $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id });
    
    # Update status
    $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'uploading');
    $di_obj->di_runtime->update({ percentage => 0 });
    
    # Monitor size of the copied file
    my $update_interval = 2;
    my $timer = Mojo::IOLoop->timer($update_interval => 
        sub {
            my $current_size = eval { -s "$images_path/$images_file" } // 0;
            my $percentage = eval { ($current_size / $total_size) * 1.0 } // 1.0;
            if ($percentage == 1.0) {
                $di_obj->di_runtime->update({ percentage => $percentage });
            }
        }
    );
    
    my $fc = Mojo::IOLoop::ForkCall->new();
    $fc->run(
        sub {
            try {
                QVD::API::Exception->throw( code => '2220' )
                    unless -d $images_path;
                
                QVD::API::Exception->throw( code => '2230' )
                    unless -d $staging_path;
                
                QVD::API::Exception->throw( code => '2240' )
                    unless -e "$staging_path/$staging_file";
                
                if ($response->{status} == 0) {
                    $c->app->log->debug( "Starting copy" );
                    copy( "$staging_path/$staging_file", "$images_path/$images_file" )
                        or QVD::API::Exception->throw( code => 2210 );
                    move( "$images_path/$images_file", "$images_path/".$di_id.'-'.$staging_file )
                        or QVD::API::Exception->throw( code => 2261 );
    
                    $di_obj->di_runtime->update({ percentage => 1.0 });
    
                    $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'ready');
                    $c->qvd_admin4_api->qvd_api->di_publish($di_id);
                } else {
                    QVD::API::Exception->throw( code => $response->{status} );
                }
            } catch {
                my $exception = shift;
                $c->log_qvd_exception($exception);
                $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'fail');
            } finally {
                Mojo::IOLoop->remove($timer) if defined($timer);
            }
        }
    );
    
    return $response;
};

sub upload_image_from_local {
    
    my $c = shift;
    $c->inactivity_timeout(30000);
    my $response;
    
    if ($c->req->method eq 'POST') {
        my $json = $c->get_input_json;
        my $file = eval { $c->req->upload('file') };
        
        if ($file) {
            $response = $c->process_api_query($json);
            
            if ($response->{status} eq 0) {
                my $di_id = ${$response->{rows}}[0]->{id};
                my $disk_image = $json->{arguments}->{disk_image};
                my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
                
                eval { $file->move_to($images_path .'/'. $di_id . '-'. $disk_image) };
                
                if ($@) {
                    $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id })->delete;
                    $c->qvd_admin4_api->_db->resultset('Log')->find(
                        { object_id => $di_id, qvd_object => 'di' })->update(
                        { object_id => undef, object_name => undef, status => 2251});
                    $response = QVD::API::Exception->new(code => 2251)->json;
                } else {
                    $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'ready');
                    $c->qvd_admin4_api->qvd_api->di_publish($di_id);
                }
            }
        } else {
            $c->report_di_problem_in_log(json => $json, code => 2250);
            $response = QVD::API::Exception->new(code => 2250)->json;
        }
    } else {
        $response = {status => 0};
    }

    return $response;
};

sub download_image_from_url_request {
    my $controller = shift;
    $controller->inactivity_timeout(30000);
    my $json = $controller->get_input_json;
    
    # Get download parameters
    my $url = decode_json($json->{url});
    
    # Create DI object in DB
    my $response = $controller->process_api_query( $json );
    if ($response->{status} != 0) {
        QVD::API::Exception->new(code => $response->{status})->throw;
    }
    my $di_id = ${$response->{rows}}[0]->{id};
    
    my $update_interval = 5; # seconds
    my $autopublish = 1;
    
    $controller->download_image_from_url($url, $di_id, $autopublish, $update_interval);
    
    return $response;
};

sub download_image_from_url {
    my $c = shift;
    my $url = shift;
    my $di_id = shift;
    my $autopublish = shift // 0;
    my $update_interval = shift // 10;
    
    # Get DI information
    my $di_obj = $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id });
    
    # Update status
    $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'uploading');
    $di_obj->di_runtime->update({ percentage => 0 });
    
    # Local variables to store current status
    my $last_update = 0;
    my $size = 0;
    my $len = 0;
    
    # Generate download transaction that monitors the size of the downloaded file
    if($update_interval > 0) {
        $c->ua->on(start =>
            sub {
                my ($ua, $tx) = @_;
                $tx->req->once(finish =>
                    sub {
                        $tx->res->on(progress =>
                            sub {
                                my $msg = shift;
                                return unless $len = $msg->headers->content_length;
                            
                                $size = $msg->content->progress;
                                my $percentage = ($size / $len) * 1.0;
                                my $current_time = time;
                                if (($percentage == 1.0) || ($current_time - $last_update > $update_interval)) {
                                    $last_update = $current_time;
                                    $di_obj->di_runtime->update({ percentage => $percentage });
                                }
                            }
                        );
                    }
                );
            }
        );
    }
    
    # Start to download the file
    my $url_download_tx = $c->ua->build_tx(GET => $url);
    $c->ua->start(
        $url_download_tx,
        sub {
            my ($ua,$tx) = @_;
            
            try {
                if ($tx->success) {
                    my $image_name = $di_obj->path;
                    my $images_path = $c->qvd_admin4_api->_cfg('path.storage.images');
                    my $image_path = "$images_path/$image_name";
                    eval { $tx->res->content->asset->move_to($image_path) };
                    if ($@) {
                        $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'fail');
                        QVD::API::Exception->new(code => 2261)->throw;
                    } else {
                        $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'ready');
                        if ($autopublish) {
                            $c->qvd_admin4_api->qvd_api->di_publish($di_id);
                        }
                    }
                } else {
                    $c->qvd_admin4_api->qvd_api->di_state_update($di_id, 'fail');
                    QVD::API::Exception->new(code => 2260)->throw;
                }
            } catch {
                my $exception = shift;
                $c->log_qvd_exception($exception);
            }
        }
    );
}

sub update_di_status {
    my $c = shift;
    
    # Get JSON
    my $json = $c->get_input_json;
    
    # Get configuration parameters
    my $api_url = $c->qvd_admin4_api->_cfg('api.proxy.dig.address');
    QVD::API::Exception->new(code => 3700, additional_info => 'api.proxy.dig.address')->throw
        unless defined($api_url);
    
    # Check provided id corresponds to a valid DI
    my $foreign_id = $json->{id};
    QVD::API::Exception->new(code => 2290)->throw
        unless defined($foreign_id);
    my $di_runtime = $c->qvd_admin4_api->_db->resultset('DI_Runtime')->find({ foreign_id => $foreign_id });
    QVD::API::Exception->new(code => 2290)->throw
        unless defined($di_runtime);
    my $osd_id = $di_runtime->di->osf->osd_id;
    QVD::API::Exception->new(code => 2291)->throw
        unless defined($osd_id);
    
    # Call DIG to get image status
    my $tx = $c->ua->build_tx(GET => $api_url . "/osd/$osd_id/image/$foreign_id" => {Accept => '*/*'} => json => { });
    $tx = $c->ua->start($tx);
    
    if ($tx->success) {
        # Update DI state to generating
        my $percentage = $tx->res->json->{percent};
        my $elapsed_time = $tx->res->json->{elapsedTime};
        $di_runtime->update({ percentage => $percentage, elapsed_time => $elapsed_time });
        
        # Upload DI image file
        my $status = $tx->res->json->{status};
        if ($status eq 'COMPLETED' && $di_runtime->state eq 'generating') {
            my $file = $tx->res->json->{file};
            my $file_url = "$api_url/images/$file";
            my $update_time_in_seconds = 5;
            $c->download_image_from_url($file_url, $di_runtime->di_id, $di_runtime->auto_publish, $update_time_in_seconds);
        } elsif ($status eq 'ERROR') {
            my $message = $tx->res->json->{message};
            $c->qvd_admin4_api->qvd_api->di_state_update($di_runtime->di_id, 'fail', $message);
        }
    } else {
        # Update DI state to fail
        my $message = $tx->error->{message};
        $c->qvd_admin4_api->qvd_api->di_state_update($di_runtime->di_id, 'fail', $message);
        QVD::API::Exception->new(code => 2280)->throw;
    }
    
    return { status => 0 };
}

sub publish_disk_image_request {
    my $controller = shift;
    my $json = $controller->get_input_json;
    
    # Check provided id corresponds to a valid DI
    my $di_id = $json->{id};
    QVD::API::Exception->new(code => 2290)->throw
        unless defined($di_id);
    
    $controller->qvd_admin4_api->qvd_api->di_publish($di_id);
    
    return { status => 0 };
}

#################
### FUNCTIONS ###
#################

sub get_input_json
{
    my $c = shift;

    my $json = $c->req->json;
    if (defined $json) {
        # Create a copy of the body
        $json = {%$json};
        deep_utf8_decode($json);
    }
    else {
        $json =  { map { $_ => b($c->param($_))->encode('UTF-8')->to_string } keys($c->req->params->to_hash) };
        eval
        {
            convert_json_to_hash($json, "filters");
            convert_json_to_hash($json, "arguments");
            convert_json_to_hash($json, "order_by");
            convert_json_to_hash($json, "fields");
            convert_json_to_hash($json, "parameters");
        };

		$c->render(json => QVD::API::Exception->new(code => 6100)->json) if $@;
	}
	$json->{parameters}->{remote_address} = $c->tx->remote_address; # For Log purposes
	$json;
}

sub convert_json_to_hash {
    my $json = shift;
    my $key = shift;
    
    if (exists $json->{$key}){
        $json->{$key} = decode_json($json->{$key});
        rmap_ref { $_ = "$_" if ref($_) eq 'JSON::PP::Boolean' } $json->{$key};
    }
}

sub process_api_query
{
    my ($c,$json) = @_;

    my $response = $c->qvd_admin4_api->process_query($json);

    return $response;
}

sub get_action_channels
{
    my ($c,$json) = @_;

    my $channels = $c->qvd_admin4_api->get_channels($json->{action}) // [];

    @$channels;
}

sub credentials_provided
{
    my ($c,$json) = @_;

    if (defined $json->{login} && defined $json->{password}){
        return 1;
    } else {
        return 0;
    }
}

sub create_session
{
	my ($c, $session, $json) = @_;
    my %args = (login => $json->{login}, 
		password => $json->{password});
    $args{tenant} = $json->{tenant} if defined $json->{tenant};
    my $admin = $c->qvd_admin4_api->validate_user(%args);

	# Login credentials not found
	QVD::API::Exception->throw(code => 3200) unless (defined($admin));

	# Check if tenant is blocked
	QVD::API::Exception->throw(code => 3500) if (defined($admin) && $admin->is_blocked());

    $c->qvd_admin4_api->load_user($admin);
    $session->create;
    $session->data(admin_id => $admin->id);
    $session->data(admin_name => $admin->name);
    $session->data(tenant_id => $admin->tenant_id);
    $session->data(tenant_name => $admin->tenant_name);
    $session->data(superadmin => $admin->is_superadmin);
    $session->flush; 

    return 1;
}


sub update_session
{
    my ($c,$session) = @_;

	# Session exists
	QVD::API::Exception->throw(code => 3200) unless($session->load);

	# Session has not expired
	if (!$session->is_expired) {
		$session->extend_expires;
	} else {
		$session->flush;
		QVD::API::Exception->throw(code => 3300)
	}

	# Administrator is valid
	my $admin = $c->qvd_admin4_api->validate_user(id => $session->data('admin_id'));
	QVD::API::Exception->throw(code => 3200) unless $admin;
    
	# Check if tenant is blocked
	QVD::API::Exception->throw(code => 3500) if (defined($admin) && $admin->is_blocked());

	# Try to update session
	for (1 .. 5) {
		eval { $session->flush };
		last unless $@;
	}
	QVD::API::Exception->throw(code => 3400) if $@;

    $c->qvd_admin4_api->load_user($admin);

	return 1;
}

sub report_di_problem_in_log
{
    my ($c,%args) = @_;

    my ($json,$tx,$code) = @args{qw(json tx code)}; 

    my $sid = $c->tx ? $c->tx->res->headers->header('sid') :
	$tx->res->headers->header('sid');

    my $remote_address = $c->tx ? $c->tx->remote_address :
	$tx->remote_address;

    my %session_args = (
	store  => [dbi => {dbh => QVD::DB::Simple->db()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx);

    my $session = MojoX::Session->new(%session_args);


    $session->load($sid);

    QVD::API::LogReport->new(
	
	action => { action => 'di_create',
		    type_of_action => 'create' },
	qvd_object => 'di',
	tenant => { tenant_id => $session->data('tenant_id'), 
		    tenant_name => $session->data('tenant_name')  },
	object => undef,
	administrator => { administrator_id => $session->data('admin_id'), 
			   administrator_name => $session->data('admin_name'), 
			   superadmin => $session->data('superadmin')},
	ip => $c->tx->remote_address,
	source => eval { $json->{parameters}->{source} } // undef,
	arguments => eval { $json->{arguments} } // {},
	status => $code
	
	)->report;
}

__END__

=pod

=head1 PURPOSE

Script intended to run an instance of the QVD API

=cut
