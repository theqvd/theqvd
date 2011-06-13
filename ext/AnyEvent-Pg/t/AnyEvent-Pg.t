#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Pg::PQ qw(:pgres);
use AnyEvent::Pg;

use Test::More tests => 1;

$| = 1;

sub on_connect;
sub on_empty_queue;
sub on_query_error;
sub on_query_done;
sub on_queue_empty;
sub dump_result;
sub push_query;

my $cv = AnyEvent->condvar;

my $pg = AnyEvent::Pg->new('dbname=pgpqtest',
                           on_connect => \&on_connect,
                           on_empty_queue => \&on_empty_queue);

push_query('drop table foo');
push_query('drop table bar');
push_query('create table foo (id int, name varchar(20))');
push_prepare(populate_foo => 'insert into foo (id, name) values ($1, $2)');

my %data = ( hello => 10, hola => 45, cheers => 1);
push_query('insert into foo (id, name) values ($1, $2)', $data{$_}, $_)
    for keys %data;

push_prepare(foo_bigger => 'select * from foo where id > $1 order by id desc');

my %data1 = ( bye => 12, goodbye => 13, adios => 111, 'hasta la vista' => 41);
push_query_prepared(populate_foo => $data1{$_}, $_)
    for keys %data1;

push_query('select * from foo');

push_query_prepared('foo_bigger', 12);

push_query('select * from foo where id < 12 order by name; select * from foo where id > 12 order by name');

$cv->recv;

sub on_connect {
    say 'connected!'
}

sub on_empty_queue {
    say 'queue is empty, exiting';
    $cv->send;
}

sub push_query {
    $pg->push_query(query => [@_],
                    on_error => \&on_query_error,
                    on_result => \&dump_result,
                    on_done => \&on_query_done);
}

sub push_prepare {
    $pg->push_prepare(name => $_[0], query => $_[1],
                      on_error => \&on_query_error,
                      on_result => \&dump_result,
                      on_done => \&on_query_done);
}

sub push_query_prepared {
    my $name = shift;
    $pg->push_query_prepared(name => $name, args => \@_,
                             on_error => \&on_query_error,
                             on_result => \&dump_result,
                             on_done => \&on_query_done);
}


sub on_query_error {
    say 'query error: ', $pg->dbc->errorMessage;
}

sub on_query_done {
    say 'query done!';
}

sub dump_result {
    my (undef, $dbr) = @_;
    my $dbc = $pg->dbc;
    printf("conn status:\t'%s' (%d),\terr:\t'%s'\nresult status:\t'%s' (%d),\tmsg:\t'%s',\terr:\t'%s'\n",
           $dbc->status, $dbc->status, $dbc->errorMessage,
           $dbr->status, $dbr->status, $dbr->statusMessage, $dbr->errorMessage);
    if ($dbr->status == PGRES_TUPLES_OK) {
        say 'ntuples: ', $dbr->ntuples;
        say 'nfields: ', $dbr->nfields;
        say 'id column number: ', $dbr->fnumber('id');
        for my $row (0 .. $dbr->nTuples - 1) {
            for my $col (0 .. $dbr->nFields - 1) {
                print "\t", $dbr->value($row, $col);
            }
            print "\n";
        }
    }
}

ok(1);


