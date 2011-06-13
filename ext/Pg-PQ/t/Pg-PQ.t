#!/usr/bin/perl

use 5.010;

use strict;
use warnings;

use Pg::PQ qw(:all);
use Data::Dumper;

my ($dbr, $dbc);

sub print_status {
    # no warnings 'uninitialized';
    printf("conn status:\t'%s' (%d),\terr:\t'%s'\nresult status:\t'%s' (%d),\tmsg:\t'%s',\terr:\t'%s'\n",
           $dbc->status, $dbc->status, $dbc->errorMessage,
           $dbr->status, $dbr->status, $dbr->statusMessage, $dbr->errorMessage);
}

$dbc = Pg::PQ::Conn->new("dbname=pgpqtest");
say $dbc->status;
say $dbc->errorMessage;

say $dbc->db;

$dbr = $dbc->exec("drop table foo");
print_status;

$dbr = $dbc->exec("drop table bar");
print_status;

$dbr = $dbc->exec("create table foo (id int)");
print_status;

$dbr = $dbc->exec('insert into foo (id) values ($1)', 8378);
print_status;

$dbr = $dbc->prepare(sth1 => 'insert into foo (id) values ($1)');
print_status;

$dbr = $dbc->execPrepared(sth1 => 11);
print_status;

$dbr = $dbc->execPrepared(sth1 => 12);
print_status;

$dbr = $dbc->execPrepared(sth1 => 13);
print_status;

$dbr = $dbc->execPrepared(sth1 => 14);
print_status;

$dbr = $dbc->prepare(sth2 => 'select id, id * id from foo where id > $1 order by id');
print_status;

$dbr = $dbc->execPrepared(sth2 => 12);
print_status;

if ($dbr->status == PGRES_TUPLES_OK()) {
    my $rows = $dbr->rows;
    my $columns = $dbr->columns;
    say "ntuples: ", $dbr->ntuples;
    say "nfields: ", $dbr->nfields;
    say "id column number: ", $dbr->fnumber("id");
    for my $row (0 .. $dbr->nTuples - 1) {
        for my $col (0 .. $dbr->nFields - 1) {
            print "\t", $dbr->value($row, $col);
        }
        print "\n";
    }

    say "rows:";
    for my $row (0..$rows-1) {
        say join ", ", $dbr->row($row);
    }
    say "columns:";
    for my $column (0..$columns-1) {
        say join ", ", $dbr->column($column);
    }
    say "all rows:";
    say Dumper [$dbr->rows];
    say "all columns:";
    say Dumper [$dbr->columns];
}

use Test::More tests => 1;
ok(1);

