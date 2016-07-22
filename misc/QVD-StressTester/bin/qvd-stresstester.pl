#!/usr/bin/perl

# targets file is a csv with the following columns: user, password, vm_id
# I.e.:
#   arthur,passw0rd,72
#   merlin,grial,75

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use Text::CSV_XS qw(csv);
use AnyEvent;
use AnyEvent::Socket;
use QVD::StressTester;
use URI::Encode qw(uri_encode);
use MIME::Base64 qw(encode_base64);
use JSON;
use Data::Dumper;

my $base = 'qvd';
my $json = JSON->new();
my $file = "targets.csv";
my $speed = 1;
my $time;
my $host = 'localhost';
my $port = 8443;
my $verbose;
my $limit;
my $debug;

sub dbg { say STDERR join(': ', @_) if $verbose }

GetOptions("file|f=s"  => \$file,
           "time|t=i"  => \$time,
           "speed|s=i" => \$speed,
           "port|p=i"  => \$port,
           "host|h=s"  => \$host,
           "limit|n=i" => \$limit,
           "verbose|v" => \$verbose,
           "debug|d"   => \$debug,
          );

my $targets = csv(in => $file);
if (defined $limit and $limit < @$targets) {
    $#$targets = $limit - 1;
}

$verbose ||= $debug;
$time ||= ($#$targets + 1) / $speed;

my $cv = AE::cv;

for my $target (@$targets) {
    $cv->begin;
    my $delay = int (0.5 + rand($time));
    my %target = (delay => $delay);
    @target{qw(user password vm_id)} = @$target;
    dbg "delaying user $target{user} $delay seconds";
    $target{w} = AE::timer $delay, 0, sub { start(\%target) };
}

$cv->recv;

sub start {
    my $target = shift;
    dbg "connecting to $host:$port";
    $target->{socket_guard} =
        tcp_connect($host, $port, sub {
                        dbg "connection for user $target->{user} established";
                        $target->{socket} = shift;
                        get_vms($target)
                    });
}

sub rpc {
    my $target = shift;
    my $url = shift;
    $url = "http://${host}:${port}/$base/$url";
    dbg "rpc $url";
    my $cb = pop @_;
    my %opts = @_;
    if (my $args = delete $opts{args}) {
        $url .= '?' .
            join('&',  map { uri_encode($_) . '=' . uri_encode($args->{$_}) } keys %$args);
    }

    my $auth = encode_base64("$target->{user}:$target->{password}", '');
    my %headers = ( %{delete($opts{headers}) // {}},
                    Authorization => "Basic $auth",
                    Accept => 'application/json' );
    http_get($url,
             %opts,
             headers => \%headers,
             tcp_connect => sub {
                 eval {
                     my ($host, $service, $connect_cb, $prepare_cb) = @_;
                     AE::postpone { $connect_cb->($target->{socket}, $host, $service) };
                     $target->{socket_guard}
                 } // dbg '$@', $@;
             },
             sub {
                 my $body = shift;
                 my $headers = shift;
                 if ($debug) {
                     dbg "RPC response headers", Dumper($headers);
                     dbg "RPC response body", Dumper($body);
                 }
                 if ($headers->{Status} == 101) {
                     $cb->($headers);
                 }
                 else {
                     my $json = eval {
                         no warnings;
                         $json->decode($body)
                     };
                     if ($json) {
                         $cb->($json);
                     }
                     else {
                         dbg "rpc failed for user $target->{user}", $@;
                         dbg "headers", Dumper($headers) unless $debug;
                         $cv->end;
                     }
                 }
             });
}

sub get_vms {
    my $target = shift;
    rpc($target, 'list_of_vm', sub {
            my $list = shift;
            $target->{vm_id} //=
                $list->[rand @$list]->{vm_id};
            connect_to_vm($target);
        });
}

sub connect_to_vm {
    my $target = shift;
    rpc($target, 'connect_to_vm',
        args => { id => $target->{vm_id} },
        headers => { Connection => 'Upgrade',
                     Upgrade => 'QVD/1.0' },
        sub {
            dbg "connection to VM $target->{vm_id} established";
            %$target = ();
            $cv->end();
        });
}

