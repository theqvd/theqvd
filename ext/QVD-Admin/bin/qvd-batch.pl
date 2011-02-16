#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Net::OpenSSH::Parallel;
use QVD::DB::Simple qw(db);

my %cmd2op = qw(ssh   command
                get   scp_get
                put   scp_put
                reget rsync_get
                reput rsync_put);

my $cmd = shift @ARGV;
my $op = $cmd2op{$cmd} // die "Unsupported command $cmd\n";

my %opt;

my $state = 'running';

while (@ARGV and $ARGV[0] =~ /^-/) {
    my $opt = shift @ARGV;

    given ($opt) {
	when ('-l')  { $opt{user}   = shift @ARGV }
	when ('-pw') { $opt{passwd} = shift @ARGV }
	when ('-s')  { $state = shift @ARGV }
	default { die "Unsupported option $_\n" }
    }
}

my @all_states = qw(starting_1 starting_2 running zombie_1 zombie_2 debug);
my @state = ($state eq 'all' ? @all_states : split /\s*,\s*/, $state);
grep /\W/, @state and die "bad state enumeration $state\n";
@state or die "Empty state list\n";
my $in_states = join(', ', @state);

@ARGV // die "target machine template missing";

my $sth = db->storage->dbh->prepare("select name, ip from vms, vm_runtimes where vms.id = vm_runtimes.vm_id and vm_state in ('$in_states')");
$sth->execute or die "Unable to query QVD database\n";

my %host;
while (my ($name, $ip) = $sth->fetchrow_array()) {
    $host{$name} = $ip;
}

my @target = split /\s*,\s*/, shift @ARGV;
my %target;
for my $target (@target) {
    my ($user, $passwd, $host, $port) =
        $target =~ m{^
                     \s*               # space
                     (?:
                      ([^\@:]+)       # username
                      (?::(.*))?      # : password
                      \@              # @
                     )?
                     ([^\@:]+)    #   hostname / ipv4
                    }x;
    $passwd //= $opt{passwd};
    $user   //= $opt{user};

    $target =~ s/\*/.*/g;
    my $target_re = qr/^$target$/;
    my @hosts = grep $_=~ $target_re, keys %host;
    for my $host (@hosts) {
	$target{$host} = [ $host,
			   host => $host{$host},
			   (defined $user   ? (user   => $user  ) : ()),
			   (defined $passwd ? (passwd => $passwd) : ()) ];
    }
}


my $pssh = Net::OpenSSH::Parallel->new;
$pssh->add_host(@{$target{$_}}, master_opts => [qw(-o StrictHostKeyChecking=no)]) for keys %target;

$pssh->push('*', $op => @ARGV);
$pssh->run;
