package Pg::PQ;

our $VERSION = '0.03';

use 5.010001;
use strict;
use warnings;

require XSLoader;
XSLoader::load('Pg::PQ', $VERSION);

use Exporter qw(import);

our %EXPORT_TAGS;
our @EXPORT_OK = map @$_, values %EXPORT_TAGS;
$EXPORT_TAGS{all} = [@EXPORT_OK];

package Pg::PQ::Conn;
use Carp;

sub _escape_opt {
    my $n = shift;
    $n =~ s/(['\\])/\\$1/g;
    $n = "'$n'" if $n =~ /\s/;
}

sub _make_conninfo {
    my @conninfo = (@_ & 1 ? shift : ());
    my %opts = @_;
    push @conninfo, map _escape_opt($_).'='._escape_opt($opts{$_}), keys %opts;
    join ' ', @conninfo;
}

sub start {
    shift; # discards class
    connectdb(_make_conninfo @_)
}

sub new {
    shift;
    connectdb(_make_conninfo @_);
}

sub DESTROY {
    my $self = shift;
    $self->finish if $$self;
}

sub getssl { croak "Pg::PQ::Conn::getssl not implemented" }

package Pg::PQ::Result;

my %error_fields = qw( severity            S
                       sqlstate            C
                       message_primary     M
                       message_detail      D
                       message_hint        H
                       statement_position  P
                       internal_position   p
                       internal_query      q
                       context             W
                       source_file         F
                       source_line         L
                       source_function     R );

sub errorDescription {
    my $self = shift;
    my %desc;
    for my $key (keys %error_fields) {
	my $v = $self->errorField($error_fields{$key});
	$desc{$key} = $v if defined $v;
    }
    return (%desc ? \%desc : ());
}

sub DESTROY {
    my $self = shift;
    $self->clear if $$self;
}

package Pg::PQ::Cancel;

sub DESTROY {
    my $self = shift;
    $self->freeCancel if $$self;
}

1;

__END__

=head1 NAME

Pg::PQ - Perl wrapper for PostgreSQL libpq

=head1 SYNOPSIS

  use Pg::PQ qw(:pgres_polling);

  my $dbc = Pg::PQ::Conn->new(dbname => 'test',
                              host => 'dbserver');

  $dbc->sendQuery("select * from foo");

  while (1) {
    $dbc->consumeInput;
    last unless $dbc->busy
    # do something else
    ...
  }

  my $res = $dbc->result;
  my @rows = $res->rows;

  print "query result:\n", Dumper \@rows;

=head1 DESCRIPTION

  *******************************************************************
  ***                                                             ***
  *** NOTE: This is a very early release that may contain lots of ***
  *** bugs. The API is not stable and may change between releases ***
  ***                                                             ***
  *******************************************************************

This module is a thin wrapper around PostgreSQL libpq C API.

Its main purpose is to let query a PostgreSQL database asynchronously
from inside common non-blocking frameworks as L<AnyEvent>, L<POE> or
even L<Coro>.

=head2 Pg::PQ::Conn class

These are the methods available from the class Pg::PQ::Conn:

=over 4

=item $dbc = Pg::PQ::Conn->new($conninfo)

=item $dbc = Pg::PQ::Conn->new(%conninfo)

X<new>I<(wraps PQconnectdb)>

This method creates a new Pg::PQ::Conn object and connects to the
database defined by the parameters given as a string (C<$conninfo>) or
as a set of key value pairs (C<%conninfo>).

For example:

  # parameters as an string:
  my $dbc = Pg::PQ::Conn->new("dbname=testdb user=jsmith passwd=jsmith11");

  # as key-value pairs:
  my $dbc = Pg::PQ::Conn->new(dbname => 'testdb',
                              user   => 'jsmith',
                              passwd => 'jsmith11');

The set of parameters accepted is as follows:

=over 4

=item host

Name of host to connect to. If this begins with a slash, it specifies
Unix-domain communication rather than TCP/IP communication; the value
is the name of the directory in which the socket file is stored. The
default behavior when host is not specified is to connect to a
Unix-domain socket in C</tmp> (or whatever socket directory was
specified when PostgreSQL was built). On machines without Unix-domain
sockets, the default is to connect to localhost.

=item hostaddr

Numeric IP address of host to connect to. This should be in the
standard IPv4 address format, e.g., C<172.28.40.9>. If your machine
supports IPv6, you can also use those addresses. TCP/IP communication
is always used when a nonempty string is specified for this parameter.

Using C<hostaddr> instead of C<host> allows the application to avoid a
host name look-up, which might be important in applications with time
constraints. However, a host name is required for Kerberos, GSSAPI, or
SSPI authentication, as well as for full SSL certificate
verification.

The following rules are used:

=over 4

=item *

If C<host> is specified without C<hostaddr>, a host name lookup
occurs.

=item *

If C<hostaddr> is specified without C<host>, the value for C<hostaddr>
gives the server address. The connection attempt will fail in any of
the cases where a host name is required.

=item *

If both C<host> and C<hostaddr> are specified, the value for
C<hostaddr> gives the server address. The value for C<host> is ignored
unless needed for authentication or verification purposes, in which
case it will be used as the host name.

Note that authentication is likely to fail if C<host> is not the name
of the machine at C<hostaddr>. Also, note that C<host> rather than
C<hostaddr> is used to identify the connection in C<~/.pgpass> (see
Section 31.14 of the PostgreSQL documentation).

=item *

Without either a host name or host address, libpq will connect using a
local Unix-domain socket; or on machines without Unix-domain sockets,
it will attempt to connect to localhost.

=back

=item port

Port number to connect to at the server host, or socket file name
extension for Unix-domain connections.

=item dbname

The database name. Defaults to be the same as the user name.

=item user

PostgreSQL user name to connect as. Defaults to be the same as the
operating system name of the user running the application.

=item password

Password to be used if the server demands password authentication.

=item connect_timeout

Maximum wait for connection, in seconds (write as a decimal integer
string). Zero or not specified means wait indefinitely. It is not
recommended to use a timeout of less than 2 seconds.

=item options

Adds command-line options to send to the server at run-time. For
example, setting this to C<-c geqo=off> sets the session's value of
the geqo parameter to off. For a detailed discussion of the available
options, consult Chapter 18 of the PostgreSQL documentation.

=item application_name

Specifies a value for the C<application_name> configuration parameter.

=item fallback_application_name

Specifies a fallback value for the C<application_name> configuration
parameter. This value will be used if no value has been given for
application_name via a connection parameter or the C<PGAPPNAME>
environment variable.

Specifying a fallback name is useful in generic utility programs that
wish to set a default application name but allow it to be overridden
by the user.

=item keepalives

Controls whether client-side TCP keepalives are used. The default
value is C<1>, meaning on, but you can change this to C<0>, meaning
off, if keepalives are not wanted.

This parameter is ignored for connections made via a Unix-domain
socket.

=item keepalives_idle

Controls the number of seconds of inactivity after which TCP should
send a keepalive message to the server. A value of zero uses the
system default. This parameter is ignored for connections made via a
Unix-domain socket, or if keepalives are disabled. It is only
supported on systems where the C<TCP_KEEPIDLE> or C<TCP_KEEPALIVE>
socket option is available, and on Windows; on other systems, it has
no effect.

=item keepalives_interval

Controls the number of seconds after which a TCP keepalive message
that is not acknowledged by the server should be retransmitted. A
value of zero uses the system default. This parameter is ignored for
connections made via a Unix-domain socket, or if keepalives are
disabled. It is only supported on systems where the C<TCP_KEEPINTVL>
socket option is available, and on Windows; on other systems, it has
no effect.

=item keepalives_count

Controls the number of TCP keepalives that can be lost before the
client's connection to the server is considered dead. A value of zero
uses the system default. This parameter is ignored for connections
made via a Unix-domain socket, or if keepalives are disabled. It is
only supported on systems where the C<TCP_KEEPINTVL> socket option is
available; on other systems, it has no effect.

=item sslmode

This option determines whether or with what priority a secure SSL
TCP/IP connection will be negotiated with the server. There are six
modes:

=over 4

=item disable

only try a non-SSL connection

=item allow

first try a non-SSL connection; if that fails, try an SSL connection

=item prefer (default)

first try an SSL connection; if that fails, try a non-SSL connection

=item require

only try an SSL connection

=item verify-ca

only try an SSL connection, and verify that the server certificate is
issued by a trusted CA

=item verify-full

only try an SSL connection, verify that the server certificate is
issued by a trusted CA and that the server host name matches that in
the certificate

=back

C<sslmode> is ignored for Unix domain socket communication. If
PostgreSQL is compiled without SSL support, using options C<require>,
C<verify-ca>, or C<verify-full> will cause an error, while options
C<allow> and C<prefer> will be accepted but libpq will not actually
attempt an SSL connection.

=item sslcert

This parameter specifies the file name of the client SSL certificate,
replacing the default C<~/.postgresql/postgresql.crt>. This parameter
is ignored if an SSL connection is not made.

=item sslkey

This parameter specifies the location for the secret key used for the
client certificate. It can either specify a file name that will be
used instead of the default C<~/.postgresql/postgresql.key>, or it can
specify a key obtained from an external "engine" (engines are OpenSSL
loadable modules). An external engine specification should consist of
a colon-separated engine name and an engine-specific key
identifier. This parameter is ignored if an SSL connection is not
made.

=item sslrootcert

This parameter specifies the name of a file containing SSL certificate
authority (CA) certificate(s). If the file exists, the server's
certificate will be verified to be signed by one of these
authorities. The default is C<~/.postgresql/root.crt>.

=item sslcrl

This parameter specifies the file name of the SSL certificate
revocation list (CRL). Certificates listed in this file, if it exists,
will be rejected while attempting to authenticate the server's
certificate. The default is C<~/.postgresql/root.crl>.

=item krbsrvname

Kerberos service name to use when authenticating with Kerberos 5 or
GSSAPI. This must match the service name specified in the server
configuration for Kerberos authentication to succeed. (See also
Section 19.3.5 and Section 19.3.3. of the PostgreSQL documentation).

=item gsslib

GSS library to use for GSSAPI authentication. Only used on
Windows. Set to gssapi to force libpq to use the GSSAPI library for
authentication instead of the default SSPI.

=item service

Service name to use for additional parameters. It specifies a service
name in C<pg_service.conf> that holds additional connection
parameters. This allows applications to specify only a service name so
connection parameters can be centrally maintained. See Section 31.15
of the PostgreSQL documentation.

=back

If any parameter is unspecified, then the corresponding environment
variable (see Section 31.13 of the PostgreSQL documentation) is
checked. If the environment variable is not set either, then the
indicated built-in defaults are used.

See also
L<http://www.postgresql.org/docs/9.0/interactive/libpq-connect.html>.

=item $dbc = Pg::PQ::Conn->start($conninfo)

X<start>I<(wraps PQconnectStart)>

This method is similar to L</new> but returns inmediately, without
waiting for the network connection to the database or the protocol
handshake to be completed.

Combined with L</connectPoll> described below allows to establish
database connections asynchronously (see L</Non-blocking connecting to
the database>).

=item $poll_status = $dbc->connectPoll

X<connectPoll>I<(wraps PQconnectPoll)>

This method returns the polling status when connecting asynchronously
to a database. Returns any of the L</pgres_polling> constants (see
L</Constants> bellow).

This method combined with L</start> are used to open a connection to a
database server such that your application's thread of execution is
not blocked on remote I/O whilst doing so. The point of this approach
is that the waits for I/O to complete can occur in the application's
main loop, rather than down inside L</start> and so the application
can manage this operation in parallel with other activities (see
L</Non-blocking connecting to the database>).

Neither C<start> nor C<connectPoll> will block, so long as a number of
restrictions are met:

=over 4

=item *

The C<hostaddr> and C<host> parameters are used appropriately to
ensure that name and reverse name queries are not made. See the
documentation of these parameters under L</new> above for details.

=item *

If you call L</trace>, ensure that the stream object into which you
trace will not block.

=item *

You ensure that the socket is in the appropriate state before calling
C<connectPoll>, as described in L</Non-blocking connecting to the
database>.

=back

=item $dbc->db

Returns the database name.

=item $dbc->user

Returns the user name.

=item $dbc->pass

Returns the login password.

=item $dbc->host

Returns the name of the server

=item $dbc->port

Returns the remote port of the connection

=item $dbc->options

Return the options passed to the constructor

=item $dbc->status

Return the status of the connection

The status can be one of a number of values. However, only two of
these are seen outside of an asynchronous connection procedure:
C<CONNECTION_OK> and C<CONNECTION_BAD>. A good connection to the
database has the status C<CONNECTION_OK>. A failed connection attempt
is signaled by status C<CONNECTION_BAD>. Ordinarily, an OK status will
remain so until L</finish> (called implicitly by C<DESTROY>), but a
communications failure might result in the status changing to
C<CONNECTION_BAD> prematurely. In that case the application could try
to recover by calling L</reset>.

See the entry for L</start> and L</connectPoll> with regards to other
status codes that might be seen.

=item $dbc->transactionStatus

Returns the current in-transaction status of the server.

The status can be:

=over 4

=item PQTRANS_IDLE

Currently idle.

=item PQTRANS_ACTIVE

A command is in progress. This status is reported only when a query
has been sent to the server and not yet completed.

=item PQTRANS_INTRANS

Idle, in a valid transaction block.

=item PQTRANS_INERROR

Idle, in a failed transaction block.

=item PQTRANS_UNKNOWN

Is reported if the connection is bad.

=back

PostgreSQL documentation contains the following warning:

   Caution: transactionStatus will give incorrect results when using a
   PostgreSQL 7.3 server that has the parameter autocommit set to
   off. The server-side autocommit feature has been deprecated and
   does not exist in later server versions.

=item $dbc->parameterStatus

Looks up a current parameter setting of the server.

Certain parameter values are reported by the server automatically at
connection startup or whenever their values change. C<parameterStatus>
can be used to interrogate these settings. It returns the current
value of a parameter if known, or C<undef> if the parameter is not
known.

Parameters reported as of the current release include:

  server_version, server_encoding, client_encoding, application_name,
  is_superuser, session_authorization, DateStyle, IntervalStyle,
  TimeZone, integer_datetimes and standard_conforming_strings.

  server_encoding, TimeZone, and integer_datetimes were not reported
  by releases before 8.0.

  standard_conforming_strings was not reported by releases before 8.1.

  IntervalStyle was not reported by releases before 8.4.

  application_name was not reported by releases before 9.0.

Note that C<server_version>, C<server_encoding> and
C<integer_datetimes> can not change after startup.

Pre-3.0-protocol servers do not report parameter settings, but libpq
includes logic to obtain values for C<server_version> and
C<client_encoding> anyway. Applications are encouraged to use
C<parameterStatus> rather than ad hoc code to determine these values
(beware however that on a pre-3.0 connection, changing
C<client_encoding> via C<SET> after connection startup will not be
reflected by C<parameterStatus>). For C<server_version>, see also
C<serverVersion>, which returns the information in a numeric form that
is much easier to compare against.

If no value for C<standard_conforming_strings> is reported,
applications can assume it is off, that is, backslashes are treated as
escapes in string literals. Also, the presence of this parameter can
be taken as an indication that the escape string syntax (C<E'...'>) is
accepted.

=item $dbc->protocolVersion

Interrogates the frontend/backend protocol being used.

Applications might wish to use this to determine whether certain
features are supported. Currently, the possible values are 2 (2.0
protocol), 3 (3.0 protocol), or zero (connection bad). This will not
change after connection startup is complete, but it could
theoretically change during a connection reset. The 3.0 protocol will
normally be used when communicating with PostgreSQL 7.4 or later
servers; pre-7.4 servers support only protocol 2.0. (Protocol 1.0 is
obsolete and not supported by libpq.)

=item $dbc->serverVersion

Returns an integer representing the backend version.

Applications might use this to determine the version of the database
server they are connected to. The number is formed by converting the
major, minor, and revision numbers into two-decimal-digit numbers and
appending them together. For example, version 8.1.5 will be returned
as 80105, and version 8.2 will be returned as 80200 (leading zeroes
are not shown). Zero is returned if the connection is bad.

=item $dbc->errorMessage

X<errorMessage>Returns the error message most recently generated by an
operation on the connection.

Nearly all libpq functions will set a message for C<errorMessage> if
they fail. Error messages can be multiline.

Note that the returned string will not contain any trailing newline
character (as the libpq C version does).

=item $dbc->socket

Obtains the file descriptor number of the connection socket to the
server. A valid descriptor will be greater than or equal to 0; a
result of -1 indicates that no server connection is currently open
(this will not change during normal operation, but could change during
connection setup or reset).

=item $dbc->backendPID

Returns the process ID (PID) of the backend server process handling
this connection.

The backend PID is useful for debugging purposes and for comparison to
C<NOTIFY> messages (which include the PID of the notifying backend
process). Note that the PID belongs to a process executing on the
database server host, not the local host!

=item $dbc->connectionNeedsPassword

Returns true if the connection authentication method required a
password, but none was available. Returns false if not.

This function can be applied after a failed connection attempt to
decide whether to prompt the user for a password.

=item $dbc->connectionUsedPassword

Returns true if the connection authentication method used a
password. Returns false if not.

This function can be applied after either a failed or successful
connection attempt to detect whether the server demanded a password.

=item $dbc->finish

X<finish>Closes the connection to the server and frees the underlaying
libpq PGconn data structure. This method is automatically called by
C<DESTROY> so usually there is no need to call it explicitly.

=item $dbc->reset

X<reset>This function will close the connection to the server and
attempt to reestablish a new connection to the same server, using all
the same parameters previously used. This might be useful for error
recovery if a working connection is lost.

=item $dbc->resetStart

=item $dbc->resetPoll

Reset the communication channel to the server, in a non-blocking
manner.

These functions will close the connection to the server and attempt to
reestablish a new connection to the same server, using all the same
parameters previously used. This can be useful for error recovery if a
working connection is lost. They differ from L</reset> in that
they act in a non-blocking manner. These functions suffer from the
same restrictions as L</start> and L</connectPoll>.

To initiate a connection reset, call C<resetStart>. If it returns 0,
the reset has failed. If it returns 1, poll the reset using
C<resetPoll> in exactly the same way as you would create the
connection using C<connectPoll>.

=item $dbc->trace($fh)

X<trace>Enables tracing of the client/server communication to a
debugging file handle. For instance:

  $dbc->trace(*STDERR);

=item $dbc->untrace

Disables tracing started by L</trace>.

=item $dbc->execQuery

I<(wraps PQexec and PQexecParams)>

This method submits a command to the server and waits for the result.

Returns a Pg::PQ::Result object or C<undef>. A valid object will
generally be returned except in out-of-memory conditions or serious
errors such as inability to send the command to the server. If
C<undef> is returned, it should be treated like a C<PGRES_FATAL_ERROR>
result. Use L</errorMessage> to get more information about such errors.

It is allowed to include multiple SQL commands (separated by
semicolons) in the command string. Multiple queries sent in a single
C<execQuery> call are processed in a single transaction, unless there
are explicit C<BEGIN>/C<COMMIT> commands included in the query string
to divide it into multiple transactions. Note however that the
returned Pg::PQ::Result object describes only the result of the
last command executed from the string.

Should one of the commands fail, processing of the string stops with
it and the returned Pg::PQ::Result object describes the error
condition.

=item $res = $dbc->prepare($name => $query)

Submits a request to create a prepared statement with the given
parameters, and waits for completion.

C<prepare> creates a prepared statement for later execution with
L</execQueryPrepared>. This feature allows commands that will be used
repeatedly to be parsed and planned just once, rather than each time
they are executed. C<prepare> is supported only in protocol 3.0 and
later connections; it will fail when using protocol 2.0.

The method creates a prepared statement named C<$name> from the
C<$query> string, which must contain a single SQL command. C<$name>
can be "" to create an unnamed statement, in which case any
pre-existing unnamed statement is automatically replaced; otherwise it
is an error if the statement name is already defined in the current
session. If any parameters are used, they are referred to in the query
as $1, $2, etc. (see L</describePrepared> for a means to find out what
data types were inferred).

As with L</execQuery>, the result is normally a Pg::PQ::Result object
whose contents indicate server-side success or failure. An undefined
result indicates out-of-memory or inability to send the command at
all. Use L</errorMessage> to get more information about such errors.

Prepared statements for use with L</execQueryPrepared> can also be
created by executing SQL C<PREPARE> statements. Also, although there
is no libpq function for deleting a prepared statement, the SQL
C<DEALLOCATE> statement can be used for that purpose.

=item $res = $dbc->execQueryPrepared($name => @args)

X<execQueryPrepared>I<(wraps PQexecPrepared)>

This method sends a request to execute a prepared statement with given
parameters, and waits for the result.

C<execQueryPrepared> is like L</execQuery>, but the command to be
executed is specified by naming a previously-prepared statement,
instead of giving a query string. This feature allows commands that
will be used repeatedly to be parsed and planned just once, rather
than each time they are executed. The statement must have been
prepared previously in the current session. C<execQueryPrepared> is
supported only in protocol 3.0 and later connections; it will fail
when using protocol 2.0.

The parameters are identical to C<execQuery>, except that the name of
a prepared statement is given instead of a query string.

=item $res = $dbc->describePrepared($name)

X<describePrepared>Submits a request to obtain information about the
specified prepared statement, and waits for completion.

C<describePrepared> allows an application to obtain information about
a previously prepared statement. It is supported only in protocol 3.0
and later connections; it will fail when using protocol 2.0.

C<$name> can be "" to reference the unnamed statement, otherwise it
must be the name of an existing prepared statement. On success, a
Pg::PQ::Result object with status C<PGRES_COMMAND_OK> is returned. The
functions L</nParams> and L</paramType> can be applied to this
Pg::PQ::Result object to obtain information about the parameters of
the prepared statement, and the methods L</nFields>, L</fName>,
L</fType>, etc provide information about the result columns (if any)
of the statement.

=item $res = $dbc->describePortal($portalName)

Submits a request to obtain information about the specified portal,
and waits for completion.

C<describePortal> allows an application to obtain information about a
previously created portal (libpq does not provide any direct access to
portals, but you can use this function to inspect the properties of a
cursor created with a DECLARE CURSOR SQL command). C<describePortal>
is supported only in protocol 3.0 and later connections; it will fail
when using protocol 2.0.

C<$name> can be "" to reference the unnamed portal, otherwise it must
be the name of an existing portal. On success, a Pg::PQ::Result object
with status C<PGRES_COMMAND_OK> is returned. Its methods L</nFields>,
L</fName>, L</fType>, etc can be called to obtain information about the
result columns (if any) of the portal.

=item $ok = $dbc->sendQuery($query, @args)

I<(wraps PQsendQuery and PQsendQueryParams)>

This method submits a query to the server without waiting for the
result(s). 1 is returned if the query was successfully dispatched and
0 if not (in which case, use L</errorMessage> to get more information
about the failure).

After successfully calling C<sendQuery>, call L</result> one or
more times to obtain the results.

C<sendQuery> can not be called again on the same connection until
C<result> has returned C<undef>, indicating that the command is done.

=item $ok = $dbc->sendPrepare($name => $query)

Sends a request to create a prepared statement without waiting for
completion.

This is an asynchronous version of L</prepare>. It returns 1 if it was
able to dispatch the request, and 0 if not. After a successful call,
call L</result> to determine whether the server successfully created
the prepared statement.

Like L</prepare>, it will not work on 2.0-protocol connections.

=item $ok = $dbc->sendQueryPrepared($name, @args)

Sends a request to execute a prepared statement with given parameters,
without waiting for the result(s).

This is similar to L</sendQuery>, but the command to be executed is
specified by naming a previously-prepared statement, instead of giving
a query string. The function's parameters are handled identically to
L</execQueryPrepared>.

It will not work on 2.0-protocol connections.

=item $ok = $dbc->sendDescribePrepared($name)

Submits a request to obtain information about the specified prepared
statement, without waiting for completion.

This is an asynchronous version of L</describePrepared>: it returns 1
if it was able to dispatch the request, and 0 if not. After a
successful call, call L</result> to obtain the results.

It will not work on 2.0-protocol connections.

=item $ok = $dbc->sendDescribePortal($name)

Submits a request to obtain information about the specified portal,
without waiting for completion.

This is an asynchronous version of L</describePortal>: it returns 1 if
it was able to dispatch the request, and 0 if not. After a successful
call, call L</result> to obtain the results.

It will not work on 2.0-protocol connections.

=item $res = $dbc->result

I<(wraps PQgetResult)>

This method waits for the next result from a prior L</sendQuery>,
L</sendPrepare>, L</sendQueryPrepared>, L</sendDescribePrepare> or
L</sendDescribePortal> method call, and returns it. L</undef> is
returned when the command is complete and there will be no more
results.

C<result> must be called repeatedly until it returns C<undef>
indicating that the command is done (if called when no command is
active, C<result> will just return C<undef> at once).

Each non undefined result from C<result> should be processed using
the accessor methods for the Pg::PQ::Result class described below.

Note that C<result> will block only if a command is active and the
necessary response data has not yet been read by L</consumeInput>.

Using C<sendQuery> and C<result> solves one of L</exec>'s problems: if
a command string contains multiple SQL commands, the results of those
commands can be obtained individually.

This allows a simple form of overlapped processing, by the way: the
client can be handling the results of one command while the server is
still working on later queries in the same command string.

However, calling C<result> will still cause the client to block until the
server completes the next SQL command. This can be avoided by proper
use of the C<consumeInput> and L</busy> methods described next.

=item $ok = $dbc->consumeInput

If input is available from the server, consume it.

C<consumeInput> normally returns 1 indicating "no error", but returns
0 if there was some kind of trouble (in which case L</errorMessage> can
be consulted). Note that the result does not say whether any input
data was actually collected.

After calling C<consumeInput>, the application can check L</busy>
and/or L</notifies> to see if their state has changed.

C<consumeInput> can be called even if the application is not prepared
to deal with a result or notification just yet. The method will read
available data and save it in a buffer, thereby causing a C<select>
read-ready indication to go away.

=item $ok = $dbc->busy

Returns 1 if a command is busy, that is, L</result> would block waiting
for input. A 0 return indicates that C<result> can be called with
assurance of not blocking.

C<busy> will not itself attempt to read data from the server;
therefore L</consumeInput> must be invoked first, or the busy state
will never end.

=item $nb = $dbc->nonBlocking

=item $dbc->nonBlocking($bool)

This methods get and sets the non blocking status of the database connection.

=item $dbc->flush

Attempts to flush any queued output data to the server. Returns 0 if
successful (or if the send queue is empty), -1 if it failed for some
reason, or 1 if it was unable to send all the data in the send queue
yet (this case can only occur if the connection is nonblocking).

=item $dbc->notifies

Returns a Pg::PQ::Notify object representing the next notification
from a list of unhandled notification messages received from the
server or undef if the list is empty. See L</Asynchronous
notification> below.

=item $esc = $dbc->escapeLiteral($literal)

C<escapeLiteral> escapes a string for use within an SQL command. This
is useful when inserting data values as literal constants in SQL
commands. Certain characters (such as quotes and backslashes) must be
escaped to prevent them from being interpreted specially by the SQL
parser.

The return string has all special characters replaced so that they can
be properly processed by the PostgreSQL string literal parser. The
single quotes that must surround PostgreSQL string literals are
included in the result string.

On error, C<escapeLiteral> returns C<undef> and a suitable message is
stored in the Pg::PQ::Conn object.

=item $esc = $conn->escapeIdentifier($identifier)

C<escapeIdentifier> escapes a string for use as an SQL identifier, such
as a table, column, or function name. This is useful when a
user-supplied identifier might contain special characters that would
otherwise not be interpreted as part of the identifier by the SQL
parser, or when the identifier might contain upper case characters
whose case should be preserved.

C<escapeIdentifier> returns a version of the str parameter escaped as
an SQL identifier. The return string has all special characters
replaced so that it will be properly processed as an SQL
identifier.

The return string will also be surrounded by double quotes.

On error, C<escapeIdentifier> returns C<undef> and a suitable message
is stored in the connection object.


=item $esc = $dbc->escapeString($str)

C<escapeString> escapes string literals, much like L</escapeLiteral>
but it does not generate the single quotes that must surround
PostgreSQL string literals; they should be provided in the SQL command
that the result is inserted into.

Returns undef on error (presently the only possible error conditions
involve invalid multibyte encoding in the source string) and a
suitable error message is stored in the connection object.

=back

=head2 Pg::PQ::Result class

=over 4

=item $status = $res->status

Returns the result status of the command.

C<$status> can take one of the following values:

=over 4

=item PGRES_EMPTY_QUERY

The string sent to the server was empty.

=item PGRES_COMMAND_OK

Successful completion of a command returning no data.

=item PGRES_TUPLES_OK

Successful completion of a command returning data (such as a SELECT or
SHOW).

=item PGRES_COPY_OUT

Copy Out (from server) data transfer started.

=item PGRES_COPY_IN

Copy In (to server) data transfer started.

=item PGRES_BAD_RESPONSE

The server's response was not understood.

=item PGRES_NONFATAL_ERROR

A nonfatal error (a notice or warning) occurred.

=item PGRES_FATAL_ERROR

A fatal error occurred.

=back

If the result status is C<PGRES_TUPLES_OK>, then the functions
described below can be used to retrieve the rows returned by the
query.

Note that a C<SELECT> command that happens to retrieve zero rows still
shows C<PGRES_TUPLES_OK>. C<PGRES_COMMAND_OK> is for commands that can
never return rows (C<INSERT>, C<UPDATE>, etc.). A response of
C<PGRES_EMPTY_QUERY> might indicate a bug in the client software.

A result of status C<PGRES_NONFATAL_ERROR> will never be returned
directly by L</exec> or other query execution methods; results of this
kind are instead passed to the notice processor (see Section 31.11).

# FIXME: revise last paragraph notice processor reference.

=item $str = $res->statusMessage

Returns the status as a human readable string.

=item $err = $res->errorMessage

Returns the error message associated with the command or an empty
string is there was no error.

Immediately following a C<Pg::PQ::Conn::exec> or
C<Pg::PQ::Conn::result> call, C<$dbc-E<gt>errorMessage> (on the
connection object) will return the same string as
C<$res-E<gt>errorMessage> (on the result). However, a Pg::PQ::Result
will retain its error message until destroyed, whereas the
connection's error message will change when subsequent operations are
done.

=item $field = $res->errorField($fieldCode)

Returns an individual field of an error report.

=item $desc = $res->errorDescription

Return a hash reference whose entries describe the error as follows:

=over 4

=item severity

The severity. The field contents are C<ERROR>, C<FATAL>, or C<PANIC>
(in an error message), or C<WARNING>, C<NOTICE>, C<DEBUG>, C<INFO>, or
C<LOG> (in a notice message), or a localized translation of one of
these. Always present.

=item sqlstate

The C<SQLSTATE> code for the error.

The C<SQLSTATE> code identifies the type of error that has occurred;
it can be used by front-end applications to perform specific
operations (such as error handling) in response to a particular
database error. For a list of the possible SQLSTATE codes, see
Appendix A of the PostgreSQL documentation.

This field is not localizable, and is always present.

=item primary

The primary human-readable error message (typically one line). Always
present.

=item detail

Detail. An optional secondary error message carrying more detail about the problem. Might run to multiple lines. 

=item hint

Hint. An optional suggestion what to do about the problem. This is
intended to differ from C<detail> in that it offers advice
(potentially inappropriate) rather than hard facts. Might run to
multiple lines.

=item statement_position

An integer indicating an error cursor position as an index into the
original statement string. The first character has index 1, and
positions are measured in characters not bytes.

=item internal_position

This is defined the same as the C<statement_position> field, but
it is used when the cursor position refers to an internally generated
command rather than the one submitted by the client.

The C<internal_query> field will always appear when this field
appears.

=item internal_query

The text of a failed internally-generated command. This could be, for
example, a SQL query issued by a PL/pgSQL function.

=item context

An indication of the context in which the error occurred. Presently
this includes a call stack traceback of active procedural language
functions and internally-generated queries. The trace is one entry per
line, most recent first.

=item source_file

The file name of the source-code location where the error was
reported.

=item source_line

The line number of the source-code location where the error was
reported.

=item source_function

The name of the source-code function reporting the error.

=back

The client is responsible for formatting displayed information to meet
its needs; in particular it should break long lines as needed. Newline
characters appearing in the error message fields should be treated as
paragraph breaks, not line breaks.

Errors generated internally by libpq will have severity and primary
message, but typically no other fields. Errors returned by a
pre-3.0-protocol server will include severity and primary message, and
sometimes a detail message, but no other fields.

Note that error fields are only available from Pg::PQ::Result objects;
there is no C<Pq::PQ::Conn::errorDescription> method.

=item $n = $res->nRows

Returns the number of rows in the query result.

=item $n = $res->nColumns

Returns the number of columns in the query result.

=item $name = $res->columnName($index)

Returns the column name associated with the given column
number. Column numbers start at 0.

=item $n = $res->columnNumber($column_name)

Returns the column number associated with the given column name.

-1 is returned if the given name does not match any column.

The given name is treated like an identifier in an SQL command, that
is, it is downcased unless double-quoted. For example, given a query
result generated from the SQL command:

  SELECT 1 AS FOO, 2 AS "BAR";

we would have the results:

  $res->columnName(0);          # foo
  $res->columnName(1);          # BAR
  $res->columnNumber('FOO');    # 0
  $res->columnNumber('foo');    # 0
  $res->columnNumber('BAR');    # -1
  $res->columnNumber('"BAR"');  # 1

=back

=item $oid = $res->columnTable($index)

Returns the OID of the table from which the given column was
fetched. Column numbers start at 0.

undef is returned if the column number is out of range, or if the
specified column is not a simple reference to a table column, or when
using pre-3.0 protocol. You can query the system table pg_class to
determine exactly which table is referenced.

=item $col = $res->columnTableColumn($index)

Returns the column number (within its table) of the column making up
the specified query result column. Query-result column numbers start
at 0, but table columns have nonzero numbers.

=item $isNull = $res->null($row, $column)

Tests a field for a null value. Row and column numbers start at 0.

This function returns 1 if the field is null and 0 if it contains a
non-null value.

=item $data = $res->value($row, $column)

Returns a single field value of one row. Row and column numbers start
at 0.

=item @fields = $res->row($index)

Returns a list of the fields in the indicated row.

=item @fields = $res->column($index)

Return a list of the fields in the indicated column.

=item $nRows = $res->rows

=item @rows = $res->rows

In scalar context this method returns the number of rows in the result set.

In list context it return a list of arrays containing the values on
every row of the result set.

=item $nColumns = $res->columns

=item @columns = $res->columns

In scalar context this method returns the number of columns in the result set.

In list context it return a list of arrays containing the values on
every column of the result set.

=item $status = $res->cmdStatus

Returns the command status tag from the SQL command that generated the
PGresult.

Commonly this is just the name of the command, but it might include
additional data such as the number of rows processed.

=item $nRows = $res->cmdRows

Returns the number of rows affected by the SQL command.

This function returns a string containing the number of rows affected
by the SQL statement that generated the Pg::PQ::Result object. This
function can only be used following the execution of a C<SELECT>,
C<CREATE TABLE AS>, C<INSERT>, C<UPDATE>, C<DELETE>, C<MOVE>,
C<FETCH>, or C<COPY> statement, or an C<EXECUTE> of a prepared query
that contains an C<INSERT>, C<UPDATE>, or C<DELETE> statement. If the
command that generated the result object was anything else, C<cmdRows>
returns C<undef>.

=item $oid = $res->oidValue

Returns the OID of the inserted row, if the SQL command was an
C<INSERT> that inserted exactly one row into a table that has OIDs, or
a C<EXECUTE> of a prepared query containing a suitable C<INSERT>
statement.

Otherwise, this function returns C<undef>. This function will also
return C<undef> if the table affected by the C<INSERT> statement does
not contain OIDs.

=item $n = $res->nParams

X<nParams>Return the number of parameters on the prepared query.

=item $oid = $res->paramType($ix)

X<paramType>Returns the type of the parameter at the given index on a
prepared query.

=head2 Pg::PQ::Cancel class

The cancel object is an artifact provided by the C libpq library to
allow interrupting database requests from signal handlers or from
other threads.

Due to the way signals and threads are handled in Perl it becomes
mostly useless here so the functionality is currently disabled.

You can use the cancel method from the Pg::PQ::Conn and non-blocking
request to obtain a similar functionality.

=head2 Constants

The following constants can be imported from this module:

=over 4

=item :copyres

  PG_COPYRES_ATTRS
  PG_COPYRES_TUPLES
  PG_COPYRES_EVENTS
  PG_COPYRES_NOTICEHOOKS

=item :connection

  CONNECTION_OK
  CONNECTION_BAD
  CONNECTION_STARTED
  CONNECTION_MADE
  CONNECTION_AWAITING_RESPONSE
  CONNECTION_AUTH_OK
  CONNECTION_SETENV
  CONNECTION_SSL_STARTUP
  CONNECTION_NEEDED

=item :pgres_polling

X<pgres_polling>

  PGRES_POLLING_FAILED
  PGRES_POLLING_READING
  PGRES_POLLING_WRITING
  PGRES_POLLING_OK
  PGRES_POLLING_ACTIVE

=item :pgres

  PGRES_EMPTY_QUERY
  PGRES_COMMAND_OK
  PGRES_TUPLES_OK
  PGRES_COPY_OUT
  PGRES_COPY_IN
  PGRES_BAD_RESPONSE
  PGRES_NONFATAL_ERROR
  PGRES_FATAL_ERROR

=item :pqtrans

  PQTRANS_IDLE
  PQTRANS_ACTIVE
  PQTRANS_INTRANS
  PQTRANS_INERROR
  PQTRANS_UNKNOWN

=item :pqerrors

  PQERRORS_TERSE
  PQERRORS_DEFAULT
  PQERRORS_VERBOSE

=back

=head2 Non-blocking database access

=head3 Non-blocking connecting to the database

To begin a nonblocking connection request, call C<$dbc =
Pg::PQ-E<gt>start($conninfo)>. If C<$dbc> is undefined, then libpq has
been unable to allocate a new Pg::PQ::Conn object. Otherwise, a valid
Pg::PQ::Conn object is returned (though not yet representing a valid
connection to the database).

On return from C<start>, call C<$status = $dbc-E<gt>status>. If
C<$status> equals C<CONNECTION_BAD>, C<start> has failed.

If C<start> succeeds, the next stage is to poll libpq so that it can
proceed with the connection sequence.  Use C<socket> to obtain the
descriptor of the socket underlying the database connection.

Loop thus:

=over 4

=item *

If C<connectPoll> last returned C<PGRES_POLLING_READING>,
wait until the socket is ready to read (as indicated by C<select>,
C<poll>, or similar system function). Then call
C<connectPoll> again.

=item *

Conversely, if C<connectPoll> last returned C<PGRES_POLLING_WRITING>,
wait until the socket is ready to write, then call C<connectPoll>
again.

=item *

If you have yet to call C<connectPoll>, i.e., just after the
call to C<start>, behave as if it last returned
C<PGRES_POLLING_WRITING>.

=item *

Continue this loop until C<connectPoll> returns
C<PGRES_POLLING_FAILED>, indicating the connection procedure has
failed, or C<PGRES_POLLING_OK>, indicating the connection has been
successfully made.

=back

At any time during connection, the status of the connection can be
checked by calling C<status>. If this gives C<CONNECTION_BAD>, then
the connection procedure has failed; if it gives C<CONNECTION_OK>,
then the connection is ready. Both of these states are equally
detectable from the return value of C<connectPoll>, described
above.

Other states might also occur during (and only during) an asynchronous
connection procedure. These indicate the current stage of the
connection procedure and might be useful to provide feedback to the
user for example. These statuses are:

=over 4

=item CONNECTION_STARTED

Waiting for connection to be made.

=item CONNECTION_MADE

Connection OK; waiting to send.

=item CONNECTION_AWAITING_RESPONSE

Waiting for a response from the server.

=item CONNECTION_AUTH_OK

Received authentication; waiting for backend start-up to finish.

=item CONNECTION_SSL_STARTUP

Negotiating SSL encryption.

=item CONNECTION_SETENV

Negotiating environment-driven parameter settings.

=back

Note that, although these constants will remain (in order to maintain
compatibility), an application should never rely upon these occurring
in a particular order, or at all, or on the status always being one of
these documented values. An application might do something like this:


  given($dbc->status) {
      when (CONNECTION_STARTED) {
          say "Connecting...";
      }
      when (CONNECTION_MADE) {
          say "Connected to server...";
      }
      ...
      default {
          say "Connecting...";
      }
  }

The C<connect_timeout> connection parameter is ignored when using
C<start> and C<connectPoll>; it is the application's responsibility to
decide whether an excessive amount of time has elapsed. Otherwise,
C<start> followed by a C<connectPoll> loop is equivalent to
C<new>.

=head3 Non-blocking quering the database

A typical non-blocking application will have a main loop that
uses C<select> or C<poll> to wait for all the conditions that it must
respond to.

After some query is dispatched to the database using any of the
asynchronous send methods (C<sendQuery>, C<sendPrepare>,
C<sendQueryPrepared>, C<sendDescribePrepared> or
C<sendDescribePortal>) one of the conditions will be input available
from the server, which in terms of C<select> means readable data on
the file descriptor identified by C<socket>.

When the main loop detects input ready, it should call C<consumeInput>
to read the input. It can then call C<isBusy>, followed by C<result>
if C<busy> returns false (0).

It can also call C<notifies> to detect C<NOTIFY> messages (see Section
31.7 of the PostgreSQL documentation).

A client that uses C<sendQuery>/C<result> can also attempt to cancel a
command that is still being processed by the server (see Section 31.5
of the PostgreSQL documentation). But regardless of the return value
of C<cancel>, the application must continue with the normal
result-reading sequence using C<result>. A successful cancellation
will simply cause the command to terminate sooner than it would have
otherwise.

By using the functions described above, it is possible to avoid
blocking while waiting for input from the database server. However, it
is still possible that the application will block waiting to send
output to the server. This is relatively uncommon but can happen if
very long SQL commands or data values are sent (it is much more
probable if the application sends data via C<COPY IN>, however).

To prevent this possibility and achieve completely nonblocking
database operation, the nonblocking mode has to be activated for
the session using C<$dbc-E<gt>nonBlocking(1)>.

After sending any command or data on a nonblocking connection, call
C<flush>. If it returns 1, wait for the socket to be write-ready and
call it again; repeat until it returns 0. Once C<flush> returns 0,
wait for the socket to be read-ready and then read the response as
described above.

=head2 Asynchronous notifications

PostgreSQL offers asynchronous notification via the LISTEN and NOTIFY
commands. A client session registers its interest in a particular
notification channel with the LISTEN command (and can stop listening
with the UNLISTEN command). All sessions listening on a particular
channel will be notified asynchronously when a NOTIFY command with
that channel name is executed by any session. A "payload" string can
be passed to communicate additional data to the listeners.

libpq applications submit C<LISTEN>, C<UNLISTEN>, and C<NOTIFY>
commands as ordinary SQL commands. The arrival of C<NOTIFY> messages
can subsequently be detected by calling C<notifies>.

The method C<notifies> returns the next notification (Pg::PQ::Notify)
from a list of unhandled notification messages received from the
server. It returns undef if there are no pending notifications.

Once a notification is returned from C<notifies>, it is considered
handled and will be removed from the list of notifications.

C<notifies> does not actually read data from the server; it just
returns messages previously absorbed by another libpq function.

In prior releases of libpq, the only way to ensure timely receipt of
C<NOTIFY> messages was to constantly submit commands, even empty ones,
and then check C<notifies> after each C<exec>. While this still works,
it is deprecated as a waste of processing power.

A better way to check for C<NOTIFY> messages when you have no useful
commands to execute is to call C<consumeInput>, then check
C<notifies>. You can use the C<select> builtin to wait for data to
arrive from the server, thereby using no CPU power unless there is
something to do (see C<socket> to obtain the file descriptor number to
use with C<select>).

Note that this will work OK whether you submit commands with
C<sendQuery>/C<result> or simply use C<exec>. You should, however,
remember to check C<notifies> after each C<result> or C<exec>, to see
if any notifications came in during the processing of the command.

=head1 SEE ALSO

Most of the time you would prefer to use L<DBD::Pg> through L<DBI>
(the standard Perl database interface module) to access PostgreSQL
databases.

L<AnyEvent::Pg> integrates Pg::PQ under the L<AnyEvent> framework.

The original PostgreSQL documentation available from
L<http://www.postgresql.org/docs/>. Note that this module is a thin
layer on top of libpq, and probably the documentation corresponding to
the version of libpq installed on your machine would actually be more
accurate in some aspects than that included here.

=head1 TODO

=over 4

=item *

Supoprt binary data transfer.

=item *

Wrap the COPY API.

=item *

Non-blocking cancels.

=item *

Write a test suite.

=back

=head1 BUGS AND SUPPORT

This is a very early release that may contain lots of bugs.

Send bug reports by email or using the CPAN bug tracker at
L<https://rt.cpan.org/Dist/Display.html?Status=Active&Queue=Pg-PQ>.

=head2 Known bugs and limitations

=item *

Currently all the data is transferred as text, that means that strings
are truncated at the first '\0' character.

=item *

Currently the utf-8 encoding is hard-coded into the wrapper. Talking
to databases configured to use other encodings would produce bad data
(and maybe even crash the application).

=head2 Commercial support

Commercial support, professional services and custom software
development services around this module are available from QindelGroup
(L<http://qindel.com>). Send us an email with a rough description of
your requirements and we will get back to you ASAP.

=head1 AUTHOR

Salvador FandiE<ntilde>o E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Qindel FormaciE<oacute>n y Servicios S.L.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

The documentation of this module is based on the original libpq
documentation that has the following copyright:

Copyright (C) 1996-2011 PostgreSQL Global Development Group.

=cut
