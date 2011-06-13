package AnyEvent::Pg;

our $VERSION = 0.01;

use 5.010;
use strict;
use warnings;
use Carp;

use AnyEvent;
use Pg::PQ qw(:pgres_polling);

sub _check_state {
    my $self = shift;
    my $state = $self->{state};
    for (@_) {
        return if $_ eq $state;
    }
    my $upsub = (caller 1)[3];
    croak "$upsub can not be called in state $state";
}

sub _ensure_list { ref $_[0] ? @{$_[0]} : $_[0]  }


sub new {
    my ($class, $conninfo, %opts) = @_;

    my $on_connect = delete $opts{on_connect};
    my $on_connect_error = delete $opts{on_connect_error};
    my $on_empty_queue = delete $opts{on_empty_queue};
    my $on_notify = delete $opts{on_notify};
    my $on_error = delete $opts{on_error};

    %opts and croak "unknown option(s) ".join(", ", keys %opts)." found";

    my $dbc = Pg::PQ::Conn->start($conninfo);
    # $dbc->trace(\*STDERR);
    # FIXME: $dbc may be undef
    my $self = { state => 'connecting',
                 dbc => $dbc,
                 on_connect => $on_connect,
                 on_connect_error => $on_connect_error,
                 on_error => $on_error,
                 on_empty_queue => $on_empty_queue,
                 on_notify => $on_notify,
                 queries => [],
               };
    bless $self, $class;

    $self->_connectPoll;

    $self;
}

sub dbc { shift->{dbc} }

sub _connectPoll {
    # warn "_connectPoll";
    my $self = shift;
    my $dbc = $self->{dbc};
    my $fd = $self->{fd};

    my ($r, $goto, $rw, $ww);
    if (defined $fd) {
        $r = $dbc->connectPoll;
    }
    else {
        $fd = $self->{fd} = $dbc->socket;
        $r = PGRES_POLLING_WRITING;
    }

    given ($r) {
        when (PGRES_POLLING_READING) {
            $rw = $self->{read_watcher} // AE::io $fd, 0, sub { $self->_connectPoll };
            # say "fd: $fd, read_watcher: $rw";
        }
        when (PGRES_POLLING_WRITING) {
            $ww = $self->{write_watcher} // AE::io $fd, 1, sub { $self->_connectPoll };
            # say "fd: $fd, write_watcher: $ww";
        }
        when (PGRES_POLLING_FAILED) {
            $goto = '_on_connect_error';
        }
        when ([PGRES_POLLING_OK, PGRES_POLLING_ACTIVE]) {
            $goto = '_on_connect';
        }
    }
    $self->{read_watcher} = $rw;
    $self->{write_watcher} = $ww;
    # warn "read_watcher: $rw, write_watcher: $ww";

    $self->$goto if $goto;
}

sub _call_back {
    my $cb = shift;
    $cb->(@_) if $cb;
}

sub _on_connect {
    my $self = shift;
    my $dbc = $self->{dbc};
    $dbc->nonBlocking(1);
    $self->{state} = 'connected';
    _call_back($self->{on_connect}, $self);
    $self->_on_push_query;
}

sub _on_connect_error {
    my $self = shift;
    _call_back($self->{on_connect_error}, $self);
    $self->_on_fatal_error;
}

sub fail { shift->_on_fatal_error }

sub _on_fatal_error {
    my $self = shift;
    $self->{state} = 'failed';
    undef $self->{write_watcher};
    undef $self->{read_watcher};
    _call_back($self->{on_error}, $self, 1);
    my $cq = delete $self->{current_query};
    $cq and _call_back($cq->{on_error}, $self);
    my $queue = $self->{queue};
    _call_back($_->{on_error}, $self) for @$queue;
    @$queue = ();
}

sub _push_query {
    my ($self, %opts) = @_;
    my %query;
    my $unshift = delete $opts{_unshift};
    my $type = $query{type} = delete $opts{_type};
    $query{$_} = delete $opts{$_} for qw(on_result on_error on_done);
    given ($type) {
        when ('query') {
            my $query = delete $opts{query};
            my $args = delete $opts{args};
            $query{args} = [_ensure_list($query), ($args ? @$args : ())];
        }
        when ('query_prepared') {
            my $name = delete $opts{name} // croak "name argument missing";
            my $args = delete $opts{args};
            $query{args} = [_ensure_list($name), ($args ? @$args : ())];
        }
        when ('prepare') {
            my $name = delete $opts{name} // croak "name argument missing";
            my $query = delete $opts{query} // croak "query argument missing";
            $query{args} = [$name, $query];
        }
        default {
            die "internal error: unknown push_query type $_";
        }
    }
    %opts and croak "unsuported option(s) ".join(", ", keys %opts);

    if ($unshift) {
        unshift @{$self->{queries}}, \%query;
    }
    else {
        push @{$self->{queries}}, \%query;
    }
}

sub push_query { shift->_push_query(_type => 'query', @_) }

sub push_query_prepared { shift->_push_query(_type => 'query_prepared', @_) }

sub push_prepare { shift->_push_query(_type => 'prepare', @_) }

sub unshift_query { shift->_push_query(_type => 'query', _unshift => 1, @_) }

sub unshift_query_prepared { shift->_push_query(_type => 'query_prepared', _unshift => 1, @_) }

sub _on_push_query {
    my $self = shift;
    # warn "_on_push_query";
    if ($self->{current_query}) {
        # warn "there is already a query queued";
    }
    else {
        my $queries = $self->{queries};
        # warn scalar(@$queries)." queries queued";
        if (@$queries) {
            $self->{write_watcher} = AE::io $self->{fd}, 1, sub { $self->_on_push_query_writable };
            # warn "waiting for writable";
        }
        else {
            _call_back($self->{on_empty_queue}, $self);
        }
    }
}

my %send_type2method = (query => 'sendQuery',
                        query_prepared => 'sendQueryPrepared',
                        prepare => 'sendPrepare' );

sub _on_push_query_writable {
    my $self = shift;
    # warn "_on_push_query_writable";
    undef $self->{write_watcher};
    $self->{current_query} and die "Internal error: _on_push_query_writable called when there is already a current query";
    my $dbc = $self->{dbc};
    my $query = shift @{$self->{queries}};
    # warn "sendQuery('" . join("', '", @query) . "')";
    my $method = $send_type2method{$query->{type}} //
        die "internal error: no method defined for push type $query->{type}";
    if ($dbc->$method(@{$query->{args}})) {
        $self->{current_query} = $query;
        $self->_on_push_query_flushable;
    }
    else {
        warn "$method failed: ". $dbc->errorMessage;
        _call_back($query->{on_error}, $self);
        # FIXME: check if the error is recoverable or fatal before continuing...
        $self->_on_push_query
    }
}

sub _on_push_query_flushable {
    my $self = shift;
    my $dbc = $self->{dbc};
    my $ww = delete $self->{write_watcher};
    given ($dbc->flush) {
        when (-1) {
            $self->_on_fatal_error;
        }
        when (0) {
            $self->_on_consume_input;
        }
        when (1) {
            $self->{write_watcher} = $ww // AE::io $self->{fd}, 1, sub { $self->_on_push_query_flushable };
        }
        default {
            die "internal error: flush returned $_";
        }
    }
}

sub _on_consume_input {
    my $self = shift;
    my $dbc = $self->{dbc};
    $self->{current_query} or die "Internal error: _on_consume_input called when there is no current query";
    unless ($dbc->consumeInput) {
        _call_back($self->{on_error}, $self);
    }
    while (1) {
        if ($dbc->busy) {
            $self->{read_watcher} //= AE::io $self->{fd}, 0, sub { $self->_on_consume_input };
            return;
        }
        else {
            my $result = $dbc->result;
            if ($result) {
                # warn "result readed";
                _call_back($self->{current_query}{on_result}, $self, $result);
            }
            else {
                _call_back($self->{current_query}{on_done}, $self);
                undef $self->{read_watcher};
                undef $self->{current_query};
                $self->_on_push_query;
                return;
            }
        }
    }
}

sub destroy {
    my $self = shift;
    %$self = ();
}

1;
__END__

=head1 NAME

AnyEvent::Pg - Query a PostgreSQL database asynchronously

=head1 SYNOPSIS

  use AnyEvent::Pg;
  my $db = AnyEvent::Pg->new("dbname=foo",
                             on_connect => sub { ... });

  $db->push_query(query => 'insert into foo (id, name) values(7, \'seven\')',
                  on_result => sub { ... },
                  on_error => sub { ... } );

  # Note that $1, $2, etc. are Pg placeholders, nothing to do with
  # Perl regexp captures!

  $db->push_query(query => ['insert into foo (id, name) values($1, $2)', 7, 'seven']
                  on_result => sub { ... }, ...);

  $db->push_prepare(name => 'insert_into_foo',
                    query => 'insert into foo (id, name) values($1, $2)',
                    on_result => sub { ... }, ...);

  $db->push_query_prepared(name => 'insert_into_foo',
                           args => [7, 'seven'],
                           on_result => sub { ... }, ...);

=head1 DESCRIPTION

This library allows to query PostgreSQL databases asynchronously. It
is a thin layer on top of L<Pg::PQ> that integrates it inside the
L<AnyEvent> framework.

=head2 API

The following methods are available from the AnyEvent::Pg class:

=over 4

=item $adb = AnyEvent::Pg->new($conninfo, %opts)

Creates and starts the connection to the database. C<$conninfo>
contains the parameters defining how to connect to the database (see
libpq C<PQconnectdbParams> and C<PQconnectdb> documentation for the
details:
L<http://www.postgresql.org/docs/9.0/interactive/libpq-connect.html>).

=item $adb->push_query(%opts)

Pushes a query into the object queue that will eventually be
dispatched to the database.

The accepted options are:

=over

=item query => $sql_query

The SQL query to be passed to the database

=item query => [$sql_query, @args]

A SQL query with placeholders ($1, $2, $3, etc.) and the arguments.

=item args => \@args

An alternative way to pass the arguments to a SQL query with placeholders.

=item on_error => sub { ... }

The given callback will be called when the query processing fails for
any reason.

=item on_result => sub { ... }

The given callback will be called for every result returned for the
given query.

You should expect one result object for every SQL statment on the
query.

The callback will receive as its arguments the AnyEvent::Pg and the
L<Pg::PQ::Result> object.

=item on_done => sub { ... }

This callback will be run after the last result from the query is
processed. The AnyEvent::Pg object is passed as an argument.

=back

=item $adb->push_prepare(%opts)

Queues a query prepare operation for execution.

The accepted options are:

=over

=item name => $name

Name of the prepared query.

=item query => $sql

SQL code for the prepared query.

=item on_error => sub { ... }

=item on_result => sub { ... }

=item on_done => sub { ... }

These callbacks perform in the same fashion as on the C<push_query>
method.

=back

=item $adb->push_query_prepared(%opts)

Queues a prepared query for execution.

The accepted options are:

=over 4

=item name => $name

Name of the prepared query.

=item args => \@args

Arguments for the query.

=item on_result => sub { ... }

=item on_done => sub { ... }

=item on_error => sub { ... }

These callbacks work as on the C<push_query> method.

=back

=item $adb->unshift_query(%opts)

=item $adb->unshift_query_prepared(%opts)

These method work in the same way as its C<push> counterparts, but
instead of pushing the query at the end of the queue they push
(unshift) it at the beginning to be executed just after the current
one is done.

This methods can be used as a way to run transactions composed of
several queries.

=item $adb->fail

Aborts any queued queries calling the C<on_error> callbacks.

=item $adb->destroy

=back

=head1 SEE ALSO

L<Pg::PQ>, L<AnyEvent>.

L<AnyEvent::DBD::Pg> provides non-blocking access to a PostgreSQL
through L<DBD::Pg>, but note that L<DBD::Pg> does not provides a
complete asynchronous interface (for instance, establishing new
connections is always a blocking operation).

L<Protocol::PostgreSQL>: pure Perl implementation of the PostgreSQL
client-server protocol that can be used in non-blocking mode.

=head1 BUGS AND SUPPORT

This is a very early release that may contain lots of bugs.

Send bug reports by email or using the CPAN bug tracker at
L<https://rt.cpan.org/Dist/Display.html?Status=Active&Queue=AnyEvent-Pg>.

=head2 Commercial support

This module was implemented during the development of QVD
(L<http://theqvd.com>) the Linux VDI platform.

Commercial support, professional services and custom software
development services around this module are available from QindelGroup
(L<http://qindel.com>). Send us an email with a rough description of your
requirements and we will get back to you ASAP.

=head1 AUTHOR

Salvador FandiE<ntilde>o, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Qindel FormaciE<oacute>n y Servicios S.L.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
