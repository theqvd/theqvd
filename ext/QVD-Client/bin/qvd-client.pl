#!/usr/bin/perl

use strict;
use warnings;

use Proc::Background; 
use JSON;

BEGIN {
    $QVD::Config::USE_DB = 0;
    @QVD::Config::FILES = ('/etc/qvd/client.conf',
			   ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/client.conf',
			   'qvd-client.conf');

    # FIXME NX_CLIENT is used for showing the user information on things
    # like broken connection, perhaps we should show them to the user
    # instead of ignoring them? 
    $ENV{NX_CLIENT} = '/bin/false';
}

use QVD::Config;
use QVD::Client::Proxy;

my $username = shift @ARGV;
my $password = shift @ARGV;
my $host = shift @ARGV;
my $port = shift @ARGV // cfg('client.host.port');
my $child_proc;
my $nonblocking=1;

# FIXME: do not use a heuristic but some command line flag for that
my $ssl = ($port =~ /43$/ ? 1 : undef);

my %connect_info = (
    link		=> cfg('client.link'),
    audio		=> cfg('client.audio.enable'),
    printing		=> cfg('client.printing.enable'),
    geometry		=> cfg('client.geometry'),
    fullscreen		=> cfg('client.fullscreen'),
    keyboard		=> 'pc105/en',
    port		=> $port,
    ssl			=> $ssl,
    host		=> $host,
    username		=> $username,
    password		=> $password);

my $delegate = QVD::Client::CLI->new();
QVD::Client::Proxy->new($delegate, %connect_info)->connect_to_vm();

package QVD::Client::CLI;

sub new {
    bless {}, shift;
}

sub proxy_unknown_cert {
    my ($self, $cert_arr) = @_;
    my ($cert_pem_str, $cert_data) = @$cert_arr;
    use Data::Dumper;
    print "$cert_data\n";
    print "Accept certificate? [y/N] ";
    return <STDIN> =~ /^y/i;
}

sub proxy_list_of_vm_loaded {
    my ($self, $vm_data) = @_;
    if (@$vm_data > 0) {
	print "You have ".@$vm_data." virtual machines.\n";
	print "Connecting to the one called ".$vm_data->[0]{name}."\n";
    }
    return $vm_data->[0]{id};
}

sub proxy_connection_status {
    my ($self, $status) = @_;
    print "Connection status $status\n";
}

sub proxy_connection_error {
    my $self = shift;
    my %args = @_;
    print 'Connection error: ',$args{message},"\n";
}

__END__

=head1 NAME

qvd-client.pl

=head1 DESCRIPTION

Proof of concept command line client for QVD

=cut
