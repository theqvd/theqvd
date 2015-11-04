#!/usr/bin/perl
use Mojolicious::Lite;
use Mojo::JSON qw(encode_json decode_json j);
use QVD::Admin4::Exception;
use MojoX::Session;
use File::Copy qw(copy move);
use Mojo::IOLoop::ForkCall;
use Mojo::Log;
use Mojo::ByteStream 'b';
use Deep::Encode;
use File::Copy qw(copy move);

# This plugin is the class intended to manage the API queries.
# Almost all queries are processed by it

plugin 'QVD::Admin4::REST';

# HELPERS

# Intended to check and encode the JSON that receives the API as iunput

helper (get_input_json => \&get_input_json); 

# Intended to get the JSON query that the API receives, process it and return a response

helper (process_api_query => \&process_api_query); 

# Every ACTION supported by the API can be related to one or more channels 
# in the database. These channels notify when something happens in the database
# that may change the output of the ACTION. 

helper (get_action_channels => \&get_action_channels);

# Helpers for authentication purposes.

helper (get_auth_method => \&get_auth_method);
helper (create_session => \&create_session);
helper (update_session => \&update_session);
helper (reject_access => \&reject_access);

# Reports problems with disk images upload/download/copy in log

helper (report_di_problem_in_log => \&report_di_problem_in_log);

# Intended to avoid a max size for file uploads. 
# Needed for disk images uploads.

$ENV{MOJO_MAX_MESSAGE_SIZE} = 0;

# This var sets the place where disk images will be uploaded
# It must be in the same filesystem that the storage/images directory
# in order to avoid problems while moving the disk images after the upload
# is accomplished.  

$ENV{MOJO_TMPDIR} = app->qvd_admin4_api->_cfg('path.storage.images');

# This hook prints upload progress of large files in console

app->hook(after_build_tx => sub {
    my ($tx, $app) = @_;

    $tx->req->on(progress => sub{
        my $message = shift;
        return unless my $len = $message->headers->content_length;
        my $size = $message->content->progress;
	my $percent = $size == $len ? 100 : int($size / ($len / 100));
        print 'Progress: ', $percent , '%', " size: $size","\r";
		 })
});

# Intended to store log info about the API

app->log( Mojo::Log->new( path => app->qvd_admin4_api->_cfg('wat.log.filename'), level => 'debug' ) );

# Intended to set the daddress where the app is supposed to listen with hypnotoad

app->config(hypnotoad => {listen => ['http://localhost:3000']});

# Package that implements an ad hoc transport system for the sessions manager (MojoX::Session) 
# According to MojoX::Session specifications, it must provide methods intended to get the session
# id from the request and to set the session id in response.

package MojoX::Session::Transport::WAT
{
    use base qw(MojoX::Session::Transport);

    sub get {
	my ($self) = @_;
	my $json = $self->tx->req->json;
	my $sid = $json ? $json->{sid} : $self->tx->req->params->param('sid');

	return $sid;
    }

    sub set {
	my ($self, $sid, $expires) = @_;
	$self->tx->res->headers->header('sid' => $sid);
	return 1;
    }
}

######################
######## URLS ########
######################

# This url retrieves general info about the API.
# This url can be accessed without authentication

any [qw(POST GET)] => '/info' => sub {
  my $c = shift;

  $c->res->headers->header('Access-Control-Allow-Origin' => '*');

  QVD::Config::reload();
  my $localtime = localtime();
  my $json = { status => 0,
               server_datetime => $localtime,
	       multitenant => $c->qvd_admin4_api->_cfg('wat.multitenant'),
               version => { database => $c->qvd_admin4_api->database_version }};

  $c->render(json => $json );
};

# Mojolicious::Lite 'under' is intended to check authentication credentials
# All urls written in this file after 'under' will be reached only after 
# the 'under' function is executed and returns 'true'.

under sub {

    my $c = shift;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*'); # WAT requirement
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid'); # WAT requirement
    QVD::Config::reload(); # Needed to avoid QVD::Config refreshing problems

    my $json = $c->get_input_json;
    
    my %session_args = (
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx);

    my $session = MojoX::Session->new(%session_args);

    my $auth_method = $c->get_auth_method($session,$json);

    my ($bool,$exception) = $c->$auth_method($session,$json);
    $c->render(json => $exception->json) if $exception;

    return $bool;
};


# This is the main url in the API

any [qw(POST GET)] => '/' => sub {

    my $c = shift;
    
    $c->inactivity_timeout(30000);     
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);

# Retrieving the right encode is tricky. 
# With this system accents and so on are supported. 
# WARNING: we're rendering in json text mode. The json mode break the accents
# Maybe a problem in Mojo?
 
    deep_utf8_decode($response);
    $c->render(text => b(encode_json($response))->decode('UTF-8'));
};


# This websocket is intended to report the current state of the system in real time
# number of vms running, number vms in a host and so on.

websocket '/ws' => sub {
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
		$c->qvd_admin4_api->_pool->listen($channel,on_notify => sub {
			my ($pg_pool, $channel, $pid, $payload) = @_;
			%payload_hash = split(/[=;]/, $payload);
			$payload_hash{channel} = $channel;
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
# Three systems supported:

# COPY OF DISK IMAGES FROM STAGING

websocket '/staging' => sub {
    my $c = shift;
    $c->inactivity_timeout(3000);
    $c->app->log->debug("Staging WebSocket opened");

    my $json = $c->get_input_json;
    $json->{sid} //= $c->tx->res->headers->header('sid');
    my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
    my $staging_path = $c->qvd_admin4_api->_cfg('path.storage.staging');
    my $staging_file = eval { $json->{arguments}->{disk_image} } // ''; 
    my $images_file = $staging_file . '-tmp'. rand;

    my $accomplished=0;

    $c->on(message => sub { my ($c,$msg) = @_;
                            my $sf_size = eval { -s "$staging_path/$staging_file" } // 0;
                            my $if_size = eval { -s "$images_path/$images_file" } // 0;
                            $c->send(b(encode_json({ status => 1000,
						     total_size => $sf_size,
						     copy_size => $if_size }))->decode('UTF-8'))
				unless $accomplished;});

    my $tx = $c->tx;
    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run(
        sub { $c->app->log->debug("Starting copy");
	      
	      my $response;

	      $response = QVD::Admin4::Exception->new(code=>'2220')->json
		  unless -d $images_path;

	      $response //= QVD::Admin4::Exception->new(code=>'2230')->json
		  unless -d $staging_path;

	      $response //= QVD::Admin4::Exception->new(code=>'2240')->json
		  unless -e "$staging_path/$staging_file";

	      unless ($response)
	      {
		  for (1 .. 5)
		  {
		      eval { copy("$staging_path/$staging_file","$images_path/$images_file") };
		      $@ ? print $@ : last;
		  }
	      }
	      
	      if ($response || $@)
	      {
		  $c->report_di_problem_in_log(json => $json,tx => $tx, code => $response ? $response->{status} : 2210);
		  $response //= QVD::Admin4::Exception->new(code=>'2210')->json;
	      }
	      else
	      {
		  $response = $c->process_api_query($json);
		  if ($response->{status} eq 0)
		  {
		      my $di_id = ${$response->{rows}}[0]->{id};
		      eval { move("$images_path/$images_file","$images_path/".$di_id . '-' . $staging_file) };

		      if ($@) 
		      {
			  $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id })->delete;
			  $c->qvd_admin4_api->_db->resultset('Log')->find(
			      { object_id => $di_id, qvd_object => 'di' })->update(
			      { object_id => undef, object_name => undef, status => 2210});
			  $response = QVD::Admin4::Exception->new(code => 2210)->json;
		      }
		  }
	      }

              return $response; },
        sub { my ($fc, $err, $response) = @_;
	      $err //= 'no error signals';
              $c->app->log->debug("Copy finished: $err");
	      $accomplished=1;
              $c->send(b(encode_json($response))->decode('UTF-8')); }
        );
};


# UPLOAD OF DISK IMAGES

any [qw(POST OPTIONS)] => '/di/upload' => sub {

    my $c = shift;
    $c->inactivity_timeout(30000);     
    my $response;

    if ($c->req->method eq 'POST')
    {
	my $json = $c->get_input_json;
	my $file = eval { $c->req->upload('file') };

	if ($file)
	{
	    $response = $c->process_api_query($json);
	    
	    if ($response->{status} eq 0)
	    {
		my $di_id = ${$response->{rows}}[0]->{id};
		my $disk_image = $json->{arguments}->{disk_image}; 
		my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');

		eval { $file->move_to($images_path .'/'. $di_id . '-'. $disk_image) };

		if ($@) 
		{
		    $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id })->delete;
		    $c->qvd_admin4_api->_db->resultset('Log')->find(
			{ object_id => $di_id, qvd_object => 'di' })->update(
			{ object_id => undef, object_name => undef, status => 2251});
			$response = QVD::Admin4::Exception->new(code => 2251)->json;
		}
	    }
	}
	else
	{
	    $c->report_di_problem_in_log(json => $json, code => 2250);
	    $response = QVD::Admin4::Exception->new(code => 2250)->json;
	}
    }
    else
    {
	$response = {status => 0};
    }
    deep_utf8_decode($response);
    $c->render(text => b(encode_json($response))->decode('UTF-8'));
};

# DOWNLOAD OF DISK IMAGES

websocket '/di/download' => sub {
    
    my $c = shift;
    $c->inactivity_timeout(30000);     

    my ($size,$len) = (0,0);

    $c->ua->on(start => sub {
	my ($ua, $tx) = @_;
	$tx->req->once(finish => sub {
	    $tx->res->on(progress => sub {
		my $msg = shift;
		return unless $len = $msg->headers->content_length;
	      
		$size = $msg->content->progress;
		my $percent = $size == $len ? 100 : int($size / ($len / 100));
		print "\rProgress: ", $size == $len ? 100 : int($size / ($len / 100)), '%';
			 });
		       });
	    }); 
    
    my $json = $c->get_input_json;

    my $url = decode_json($json->{url});
    my $tx2 = $c->ua->build_tx(GET => $url);

    my ($response,$accomplished); 

    $c->ua->start($tx2, sub { my ($ua,$tx) = @_;

			      if ($tx->res->code eq 200)
			      { 
				  $response = $c->process_api_query($json);
				  
				  if ($response->{status} eq 0)
				  {
				      my $di_id = ${$response->{rows}}[0]->{id};
				      my $disk_image = $json->{arguments}->{disk_image}; 
				      my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
				      my $image_name = $images_path .'/'. $di_id . '-'. $disk_image;
				      eval { $tx->res->content->asset->move_to($image_name) };
				      if ($@) 
				      {
					  $c->qvd_admin4_api->_db->resultset('DI')->find({ id => $di_id })->delete;
					  $c->qvd_admin4_api->_db->resultset('Log')->find(
					      { object_id => $di_id, qvd_object => 'di' })->update(
					      { object_id => undef, object_name => undef, status => 2261});
					  $response = QVD::Admin4::Exception->new(code => 2261)->json;
				      }
				  }
			      }
			      else
			      {
				  $c->report_di_problem_in_log(json => $json,code => 2260);
				  $response = QVD::Admin4::Exception->new(code => 2260)->json;
			      }

			      $accomplished = 1; }); 

    $c->on(message => sub { my ($c,$msg) = @_; 
			    my $to_send = $accomplished ? $response : { status => 1000, total_size => $len, copy_size => $size };
			    $c->send(encode_json($to_send)); });

    $c->send(encode_json({ status => 1000,
			   total_size => $len,
			   copy_size => $size }));
};

app->start;

#################
### FUNCTIONS ###
#################

sub get_input_json
{
	my $c = shift;
	my $json = $c->req->json;
	deep_utf8_decode($json) if $json;

	unless ($json)
	{
		$json =  { map { $_ => b($c->param($_))->encode('UTF-8')->to_string } keys($c->req->params->to_hash) };

		eval
		{
			$json->{filters} =  decode_json($json->{filters}) if exists $json->{filters};
			$json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
			$json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by};
			$json->{fields} = decode_json($json->{fields}) if exists $json->{fields};
			$json->{parameters} = decode_json($json->{parameters}) if exists $json->{parameters}
		};

		$c->render(json => QVD::Admin4::Exception->new(code => 6100)->json) if $@;
	}
	$json->{parameters}->{remote_address} = $c->tx->remote_address; # For Log purposes
	$json;
}

sub process_api_query
{
    my ($c,$json) = @_;

    my $response = $c->qvd_admin4_api->process_query($json);
    $response->{sid} = $c->res->headers->header('sid');
    return $response;
}

sub get_action_channels
{
    my ($c,$json) = @_;

    my $channels = $c->qvd_admin4_api->get_channels($json->{action}) // [];

    @$channels;
}

sub get_auth_method
{
    my ($c,$session,$json) = @_;   
    return 'create_session' if 
	defined $json->{login} && defined $json->{password};

    return 'update_session' if
	$session->load;

    return 'reject_access';
}

sub create_session
{
	my ($c, $session, $json) = @_;
    my %args = (login => $json->{login}, 
		password => $json->{password});
    $args{tenant} = $json->{tenant} if defined $json->{tenant};
    my $admin = $c->qvd_admin4_api->validate_user(%args);
	my $exception_code = 3200;

   QVD::Admin4::LogReport->new(
       action => { action => 'login', type_of_action => 'login' },
       qvd_object => 'administrator',
       tenant => eval { $admin->tenant } // undef,
       object => $admin,
       administrator => $admin,
       ip => $c->tx->remote_address,
       source => eval { $json->{parameters}->{source} } // undef,
       arguments => \%args,
		status => ($admin ? 0 : $exception_code),
       )->report;

	# Login credentials not found
	if (not $admin) {
		return (0, QVD::Admin4::Exception->new(code => $exception_code));
	}

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
    my ($c,$session,$json) = @_;

    if ($session->is_expired)
    { $session->flush;

      QVD::Admin4::LogReport->new(

	  action => { action => 'login', type_of_action => 'login' },
	  qvd_object => 'administrator',
	  tenant => { tenant_id => $session->data('tenant_id'), 
		      tenant_name => $session->data('tenant_name') },
	  object => { object_id =>  $session->data('admin_id'), 
		      object_name =>  $session->data('admin_name')},
	  administrator => { administrator_id =>  $session->data('admin_id'), 
			     administrator_name =>  $session->data('admin_name'),
			     superadmin =>  $session->data('superadmin') },
	  ip => $c->tx->remote_address,
	  source => eval { $json->{parameters}->{source} } // undef,
	  arguments => {},
	  status => 3300
	  
	  )->report;

      return (0,QVD::Admin4::Exception->new(code =>3300));}
    
    my ($bool,$exception) = (1, undef);

    $session->extend_expires; 

    my $admin = $c->qvd_admin4_api->validate_user(id => $session->data('admin_id'));
    return (0,QVD::Admin4::Exception->new(code =>3200)) 
	unless $admin;
    $c->qvd_admin4_api->load_user($admin);

    for (1 .. 5) { eval { $session->flush }; last unless $@;}
    ($bool,$exception) = (0,QVD::Admin4::Exception->new(code => 3400)) if $@;

    return ($bool,$exception);
}

sub reject_access
{
  (0,QVD::Admin4::Exception->new(code => 3100));
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
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx);

    my $session = MojoX::Session->new(%session_args);


    $session->load($sid);

    QVD::Admin4::LogReport->new(
	
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
