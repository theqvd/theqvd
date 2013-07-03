package QVD::DB::Simple;

use strict;
use warnings;

use QVD::DB;
use QVD::Config::Core;
use QVD::Log;

use Exporter qw(import);
our @EXPORT = qw(db db_release txn_do txn_eval rs this_host_id this_host notify sql);

my $db;

sub sql {
    my $sql = shift;
    db->storage->dbh_do(sub { $_[1]->do($sql) })
}

sub db {
    unless (defined $db) {
        $db = QVD::DB->new;
        $db->storage->dbh_do(sub { $_[1]->do("set session time zone 'UTC'") })
    }
    $db;
}

sub db_release {
    undef $db;
}

sub txn_do (&) {
    db->txn_do(@_);
}

sub txn_eval (&) {
    my $db = db;
    if (wantarray) {
        my @r = eval { $db->txn_do(@_) };
        DEBUG "txn_eval failed: $@" if $@;
        return @r;
    }
    else {
        my $r = eval { $db->txn_do(@_) };
        DEBUG "txn_eval failed: $@" if $@;
        return $r;
    }
}

sub rs (*) {
    db->resultset($_[0]);
}

sub notify (*) {
    my $channel = shift;
    sql("notify $channel");
}

sub this_host {
    my $nodename = core_cfg('nodename');
    my $this_host = rs(Host)->search({name => $nodename})->first;
    unless (defined $this_host) {
	my $msg = "This node '$nodename' is not registered in the database";
	ERROR $msg;
	return;
    }
    $this_host;
}

my $this_host_id;
sub this_host_id { $this_host_id //= this_host->id }


1;
