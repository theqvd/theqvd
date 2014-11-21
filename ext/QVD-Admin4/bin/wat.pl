#!/usr/lib/qvd/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(encode_json decode_json);
use QVD::Admin4::Exception;
use QVD::Config;
use MojoX::Session;
use File::Copy qw(copy move);
use File::Basename qw(basename dirname);
use Mojo::IOLoop::ForkCall;
app->config(hypnotoad => {listen => ['http://192.168.56.101:3000']});

my $QVD_ADMIN4_API = QVD::Admin4::REST->new();
my $DB_CONNECTION_INFO = "dbi:Pg:dbname=".cfg('database.name').";host=".cfg('database.host');

package MojoX::Session::Transport::WAT
{
    use base qw(MojoX::Session::Transport);

    sub get {
        my ($self) = @_;
	my $sid = $self->tx->req->params->param('sid');
	return $sid;
    }

    sub set {
        my ($self, $sid, $expires) = @_;
	$self->tx->res->headers->header('sid' => $sid);
	return 1;
    }
}

plugin PgAsync => {dbi => [$DB_CONNECTION_INFO,cfg('database.user'),cfg('database.password'), 
			   {AutoCommit => 1, RaiseError => 1}]};
helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });
helper (get_input_json => \&get_input_json);
helper (process_api_query => \&process_api_query);
helper (get_api_channel => \&get_api_channel);

under sub {

    my $c = shift;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid');

    my $session = MojoX::Session->new( 
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx );

    my $json = $c->req->json // 
    { map { $_ => $c->param($_) } $c->param };
 
    if (defined $json->{login} &&
	defined $json->{password})
    {
	my $admin = $c->qvd_admin4_api->validate_user(login    => $json->{login}, 
						      password => $json->{password});
	if ($admin)
	{
	    $c->qvd_admin4_api->load_user($admin);
	    $session->create;
	    $session->flush; 
	    $session->data(admin_id => $admin->id);
	    $session->flush; 
	    return 1;
	} 
	else
	{
	    $c->render(json => 
		       QVD::Admin4::Exception->new(code =>3200)->json);
	    return 0;
	}
    }
    elsif ($session->load) 
    {
        if ($session->is_expired)
	{  
	    $session->flush; 
	    $c->render(json => 
		       QVD::Admin4::Exception->new(code => 3300)->json);
	    return 0;
	}
	else
	{
	    $session->extend_expires;

	    for (1 .. 5)
            {
                eval { $session->flush };
                $@ ? print $@ : last;
            }
            if ($@)
            {
                $c->render(json =>
                           QVD::Admin4::Exception->new(code => 3400)->json);
                return 0;
            }

	    $c->qvd_admin4_api->load_user($session->data('admin_id'));
	    return 1;
	}
    }
    else 
    {
	$c->render(json => 
		   QVD::Admin4::Exception->new(code => 3100)->json);
	return 0;
    }
};

get '/index' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    $c->stash(query => $json, 
	      sid => $c->res->headers->header('sid'));
    $c->render(template => 'index');
};

any '/' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);
    $c->render(json => $response->json);
};

websocket '/ws' => sub {
    my $c = shift;

    $c->app->log->debug("WebSocket opened");
    $c->inactivity_timeout(3000); 
    my ($json,$res,$channel) = 
	($c->get_input_json, undef, 'foo');

    my $cb = 
    sub { $res = $c->process_api_query($json); 
	  $channel = eval { $res->channel } // 'foo';
	  $c->send(encode_json($res->json)); };
 
    $c->on(message => sub {
	my ($c,$msg) = @_;

	$c->app->log->debug("Signal $msg received in WebSocket");
	$c->pg_listen($channel, sub { 
	    $c->app->log->debug("$channel notified"); $cb->();});
	$c->pg(q/NOTIFY foo/,sub{}); });
    
    $c->on(finish => sub {
	my ($c, $code) = @_;
	$c->app->log->debug("WebSocket closed with status $code");});
	   
};

#######################
#######################

$ENV{MOJO_MAX_MESSAGE_SIZE} = 0;

app->hook(after_build_tx => sub {
    my ($tx, $app) = @_;
    $tx->req->on(progress => sub{
        my $message = shift;
        return unless my $len = $message->headers->content_length;
        my $size = $message->content->progress;
        say 'Progress: ', $size == $len ? 100 : int($size / ($len / 100)), '%', " size: $size";
    })
});

post '/di/upload' => sub {

    my $c = shift;
    my $file = $c->req->upload('file');
};


#######################
#######################

websocket '/di/download' => sub {

    my $c = shift;
    my $url = $c->param('url');

    my $staging_path = cfg('path.storage.staging');
    $c->render(json => QVD::Admin4::Exception->new(code => 2230)->json) 
	unless -d $staging_path;
    my $file = basename($url);

    my $tx = $c->ua->build_tx(GET => $url);

    $tx->res->on(progress => sub{
        my $message = shift;
        return unless my $len = $message->headers->content_length;
        my $size = $message->content->progress;
	$c->session(len => $len, siz => $size);
	});

    Mojo::IOLoop->recurring(1 => sub { 	use Data::Dumper; print Dumper $c->session;my ($len,$size) = ($c->session('len'),$c->session('siz')); ; $c->send("Lenght: $len, Size: $size");});
		       	 
    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run( 
	sub { $c->ua->start($tx); return 1;},
	sub { $tx->res->content->asset->move_to($staging_path."/".$file); }
	);
};


websocket '/staging' => sub {
    my $c = shift;
    $c->inactivity_timeout(3000); 
    $c->app->log->debug("Staging WebSocket opened");
    my $json = $c->get_input_json;

    my $images_path  = cfg('path.storage.images');
    $c->send(encode_json(QVD::Admin4::Exception->new(code => 2220)->json)) 
	unless -d $images_path;
	
    my $staging_path = cfg('path.storage.staging');
    $c->send(encode_json(QVD::Admin4::Exception->new(code => 2230)->json)) 
	unless -d $staging_path;

    my $staging_file = $json->{arguments}->{disk_image};
    $c->send(encode_json(QVD::Admin4::Exception->new(code => 2240)->json)) 
	unless -e "$staging_path/$staging_file";
    my $images_file = $staging_file; 

    $c->on(message => sub { my ($c,$msg) = @_;
			    my $sf_size = -s "$staging_path/$staging_file";
			    my $if_size = eval { -s "$images_path/$images_file" } // 0;
			    my $percentage = (($if_size * 100) / $sf_size);
			    $c->send(encode_json({ status => 100, 
						   total_size => $sf_size, 
						   copy_size => $if_size,
                                                   percentage => $percentage.'%' }));});

    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run( 
	sub { $c->app->log->debug("Starting copy"); 
	      my $response = $c->qvd_admin4_api->process_query($json);
	      return $response->json; },
	sub { my ($fc, $err, $response) = @_;
	      $c->app->log->debug("Copy accomplished, $err");
	      $c->send(encode_json($response)); }
	);
};

sub get_input_json
{
    my $c = shift;
    my $json = $c->req->json;
    return $json if $json;
    $json =  { map { $_ => $c->param($_) } $c->param };
    
    eval 
    { 
	$json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
	$json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
	$json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by} 
    };
    
    $c->render(json => QVD::Admin4::Exception->new(code => 6100)->json) if $@;
    $json;
}

sub process_api_query
{
    my ($c,$json) = @_;
    my $res = $c->qvd_admin4_api->process_query($json);
    $res->{sid} = $c->res->headers->header('sid');
    $res;
}

sub get_api_channel
{
    my ($c,$json) = @_;
    $c->qvd_admin4_api->get_channel($json);
}


app->start;

__DATA__

@@ upload.html.ep
<!DOCTYPE html>
<html>
  <head><title>Streaming multipart upload</title></head>
  <body>
    %= form_for upload => (enctype => 'multipart/form-data') => begin
      <br>File: 
    %= file_field 'disk_image'
      <br>OSF: 
    %= text_field 'osf_id'
      <br>Login: 
    %= text_field 'login' 
      <br>Password 
    %= text_field 'password'
      %= submit_button 'Upload'
    % end
  </body>
</html>

@@ index.html.ep
<html>
<head>
<title>Web Sockets Proofs</title>
<script type="text/javascript">

      var ws = new WebSocket('ws://localhost:3000/ws?login=superadmin&password=superadmin&action=qvd_objects_statistics');

      ws.onopen = 
        function (event) 
        { 
              staging.send('start');
        };

      ws.onmessage = 
        function (event) 
        { 
              obj = JSON.parse(event.data); 
              document.getElementById("total").innerHTML = obj.vms_count;
              document.getElementById("blocked").innerHTML = obj.blocked_vms_count;
              document.getElementById("running").innerHTML = obj.running_vms_count;
              ws.send(JSON.stringify("restart"));
        };

      var staging = new WebSocket('ws://localhost:3000/staging?login=superadmin&password=superadmin&action=di_create&arguments={"disk_image":"ubuntu-13.04-i386-qvd.tar.gz","o_id":"1"}');

      staging.onopen = 
        function (event) 
        { 

        };

      staging.onmessage = 
        function (event) 
        { 
              obj = JSON.parse(event.data); 
              if ( obj.status == '100') 
              {
                  document.getElementById("copy").innerHTML = obj.percentage;
                  staging.send("restart");
              }
              else
              {
                  document.getElementById("response").innerHTML = event.data;
                  staging.close();
              }
        };


      var download = new WebSocket('ws://localhost:3000/di/download?login=superadmin&password=superadmin&url=https://s3.amazonaws.com/QVD_Images/3.4/lxc/opensuse-12.3-qvd.tar.gz');

      download.onopen = 
        function (event) 
        { 
        };

      download.onmessage = 
        function (event) 
        {  
         document.getElementById("download").innerHTML = event.data;
        };


</script>

</head>
<body>
    <h1>Web Sockets Proofs</h1>
<!--    <a href="http://localhost:3000/?login=superadmin&password=superadmin&action=user_get_list">bye bye</a> -->
    <hr/>
<!--    <section>
    <h3>VMs in QVD</h3>
    Total: <span id="total"></span></br>
    Blocked: <span id="blocked"></span></br>
    Running: <span id="running"></span></br>
    </section> -->
    <section>
    <h3>DI Copy Progress</h3>
    Copy state: <span id="copy"></span></br>
    Json response: <span id="response"></span></br>
    </section>
    <section>
    <h3>DI Download Progress</h3>
    Download state: <span id="download"></span></br>
    </section>

</body>

</html>
