package QVD::DB;

our $VERSION = '0.01';

use warnings;
use strict;

use Carp;
use DBIx::Class::Exception;
use DBIx::Error;
use Socket qw(IPPROTO_TCP SOL_SOCKET SO_KEEPALIVE);
use Socket::Linux qw(TCP_KEEPIDLE TCP_KEEPINTVL TCP_KEEPCNT);

use QVD::Config::Core;
use parent qw(DBIx::Class::Schema);

__PACKAGE__->load_namespaces(result_namespace => 'Result');
__PACKAGE__->exception_action(sub { croak @_ ; DBIx::Class::Exception::throw(@_);});


my $db_name   = core_cfg('database.name'); # FIXME: INSTANTIATED IN THE CONSTRUCTOR
my $db_user   = core_cfg('database.user'); # FIXME: INSTANTIATED IN THE CONSTRUCTOR
my $db_host   = core_cfg('database.host'); # FIXME: INSTANTIATED IN THE CONSTRUCTOR
my $db_passwd = core_cfg('database.password'); # FIXME: INSTANTIATED IN THE CONSTRUCTOR

my $db_connect_timeout = core_cfg('internal.database.client.connect.timeout');
my $db_keepidle        = core_cfg('internal.database.client.socket.keepidle');
my $db_keepintvl       = core_cfg('internal.database.client.socket.keepintvl');
my $db_keepcnt         = core_cfg('internal.database.client.socket.keepcnt');

sub new {
    my ($class,%parameters) = @_;

    $class->SUPER::connect("dbi:Pg:dbname=$db_name;host=$db_host;connect_timeout=$db_connect_timeout",
			   $db_user, $db_passwd,
                           { RaiseError => 1,
			     HandleError => DBIx::Error->HandleError,
			     ShowErrorStatement => 1,
			     unsafe => 1,
			     AutoCommit => 1,
                             quote_char => '"',
			     name_sep   => '.',
			     on_connect_call => \&_make_pg_socket_keepalive });
}

sub _make_pg_socket_keepalive {
    my $storage = shift;
    my $dbh = $storage->_dbh // die "not connected to database";
    # we have to duplicate the socket as setsockopt does not accept a
    # file descriptor
    open my $socket, '+<&', $dbh->{pg_socket};
    unless (setsockopt($socket, SOL_SOCKET,  SO_KEEPALIVE,   1) and
	    # see tcp(7)
	    setsockopt($socket, IPPROTO_TCP, TCP_KEEPIDLE,  10) and
	    setsockopt($socket, IPPROTO_TCP, TCP_KEEPINTVL,  5) and
	    setsockopt($socket, IPPROTO_TCP, TCP_KEEPCNT,    3)) {
	die "Unable to set database client socket keepalive options: $!";
    }
}

sub deploy {
    my $db = shift;
    # Ensure the default transaction isolation is "serializable" (see #1210)
    my $dbh = $db->storage->dbh;
    $dbh->do("ALTER DATABASE $db_name SET default_transaction_isolation TO serializable");

	# Get arguments
	my %args_as_hash = %{$_[0]};

	# Generate enumerates
	if($args_as_hash{add_enums}){
		while (my ($name, $values) = each %{$args_as_hash{add_enums}}) {
			$dbh->do("DROP TYPE IF EXISTS $name CASCADE");
			$dbh->do("CREATE TYPE $name AS ENUM (" . join(",", map {qq/'$_'/} @$values) . ")");
		}
	}

	# Generate tables
    $db->SUPER::deploy(@_);

	# Generate initial values
	if($args_as_hash{add_init_vars}){
		while (my ($name, $values) = each %{$args_as_hash{add_init_vars}}) {
			$db->resultset($name)->create({name => $_}) for @$values;
		}
    }

    $db->resultset('Version')->create({ component => 'schema',
                                        version => '3.3.0' });
}

sub erase {
    my $db = shift;
    my $dbh = $db->storage->dbh;
    for my $table (qw( versions
                       vm_runtimes
		       vms
		       vm_properties
		       osfs
		       host_runtimes
		       hosts
		       host_properties
		       dis
		       di_tags
		       users
		       user_properties
		       vm_states
		       user_states
		       vm_cmds
		       user_cmds
		       configs
		       ssl_configs )
		  ) {

	eval {
	    warn "DROPPING $table\n";
	    $dbh->do("DROP TABLE $table CASCADE");
	};
	warn "Error (DROP $table): $@" if $@;
    }
}

1;

__END__

=head1 NAME

QVD::DB - ORM for QVD entities

=head1 SYNOPSIS

    use QVD::DB;

    my $foo = QVD::DB->new();
    ...

=head1 DESCRIPTION

=head2 API

=over 4

=item $db = QVD::DB->new()

Opens a new connection to the database using the configuration from
the file 'config.ini'

=item $db->erase()

Drops all the database tables.

=back

=head1 AUTHORS

Joni Salonen (jsalonen at qindel.es)

Nicolas Arenas (narenas at qindel.es)

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
