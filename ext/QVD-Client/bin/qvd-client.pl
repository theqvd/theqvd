#!/usr/bin/perl

use strict;
use warnings;

use QVD::HTTPC;
use QVD::HTTP::Headers qw(header_lookup header_eq_check);
use QVD::HTTP::StatusCodes qw(:status_codes);
use IO::Socket::Forwarder qw(forward_sockets);
use MIME::Base64 qw(encode_base64);
use JSON;
use Proc::Background; 




# Forces a flush
$| = 1;

my $vm_id;
my $username = shift @ARGV;
my $password = shift @ARGV;
my $host = shift @ARGV;
my $port = shift @ARGV // "8443";
#my $cmd = "C:\\WINDOWS\\system32\\nxproxy.exe";
my $cmd_win = "C:\\WINDOWS\\system32\\nxproxy.exe -S localhost:40 media=4713 kbtype=pc105/es client=windows";
my $child_pid;
my $child_proc;
my $nonblocking=1;


my $authorization = 'Basic '.encode_base64("$username:$password", '');

# FIXME: do not use a heuristic but some command line flag for that
my $ssl = ($port =~ /43$/ ? 1 : undef);

my $httpc = QVD::HTTPC->new($host.":".$port, SSL => $ssl);
my $json = JSON->new->ascii->pretty;


$httpc->send_http_request(GET => '/qvd/list_of_vm',
			  headers => [ 'Accept: application/json',
			  	       'Authorization: '.$authorization ]);
my ($code, $msg, $headers, $body) = $httpc->read_http_response;
if ($code != HTTP_OK) {
   die "Unable to get list of vm";
} 
my $json_body = $json->decode($body);
print "Connecting to ".$json_body->[0]{name}."\n";
$vm_id = $json_body->[0]{id};

$httpc->send_http_request(GET => '/qvd/connect_to_vm?id='.$vm_id,
			  headers => [ 'Connection: Upgrade',
			  	       'Authorization: '.$authorization,
				       'Upgrade: QVD/1.0' ]);
while (1) {
    my ($code, $msg, $headers, $body) = $httpc->read_http_response;
    use Data::Dumper;
    print Dumper [http_response => $code, $msg, $headers, $body];
    if ($code == HTTP_SWITCHING_PROTOCOLS) {
	my $ll = IO::Socket::INET->new(LocalPort => 4040,
				       ReuseAddr => 1,
				       Listen => 1);
	
	# FIXME NX_CLIENT is used for showing the user information on things
	# like broken connection, perhaps we should show them to the user
	# instead of ignoring them? 
	$ENV{NX_CLIENT} = '';
	# XXX: make media port configurable (4713 for pulseaudio)
	
	if ($^O eq 'linux'){
	    my $cmd_linux="nxproxy -S localhost:40 media=4713";
	    #system "nxproxy -S localhost:40 media=4713 &";
	    my $proc1 = Proc::Background->new ($cmd_linux);
	}
	else{	
	    my $proc1 = Proc::Background->new ($cmd_win);
	}
	my $s1 = $ll->accept()
	    or die "connection from nxproxy failed";
	undef $ll; # close the listening socket
	my $s2 = $httpc->get_socket;
	if ($^O eq 'MSWin32'){		
	    ioctl ($s1, 0x8004667e, \$nonblocking);
	}
	forward_sockets($s1, $s2); #, debug => 1);
	last;
    }
    elsif ($code >= 100 and $code < 200) {
	print "$code\ncontinuing...\n"
    }
    else {
	die "unable to connect to remote vm: $code";
    }
}

__END__

=head1 NAME

qvd-client.pl

=head1 DESCRIPTION

probe of concept client for the new QVD

=cut
