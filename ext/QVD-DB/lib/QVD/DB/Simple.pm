package QVD::DB::Simple;

use strict;
use warnings;

use QVD::DB;
use QVD::Config;
use QVD::Log;

use Exporter qw(import);
our @EXPORT = qw(db db_release txn_do txn_eval rs this_host_id this_host);

my $db;

sub db {
    $db //= QVD::DB->new
}

sub db_release {
    undef $db;
}

sub txn_do (&) {
    $db //= QVD::DB->new();
    $db->txn_do(@_);
}

sub txn_eval (&) {
    $db //= QVD::DB->new();
    eval { $db->txn_do(@_) };
    DEBUG "txn_eval failed: $@" if $@;
}

sub rs (*) {
    ($db //= QVD::DB->new())->resultset($_[0]);
}

sub this_host {
    my $nodename = core_cfg('nodename');
    my $this_host = rs(Host)->search(name => $nodename)->first;
    unless (defined $this_host) {
	my $msg = "This node $nodename is not registered in the database";
	ERROR $msg;
	die "$msg\n";
    }
    $this_host;
}

my $this_host_id;
sub this_host_id { $this_host_id //= this_host->id }


1;
