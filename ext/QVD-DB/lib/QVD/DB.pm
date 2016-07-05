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

require QVD::DB::Translator;

__PACKAGE__->load_namespaces(result_namespace => 'Result');
__PACKAGE__->exception_action(sub { croak @_ ; DBIx::Class::Exception::throw(@_);});


my $db_name   = core_cfg('database.name');
my $db_user   = core_cfg('database.user');
my $db_host   = core_cfg('database.host');
my $db_passwd = core_cfg('database.password');
my $db_port   = core_cfg('database.port', 0);

my $db_connect_timeout = core_cfg('internal.database.client.connect.timeout');
my $db_keepidle        = core_cfg('internal.database.client.socket.keepidle');
my $db_keepintvl       = core_cfg('internal.database.client.socket.keepintvl');
my $db_keepcnt         = core_cfg('internal.database.client.socket.keepcnt');

sub new {
    my ($class, %opts) = @_;
    if ($opts{trim_spaces}) {
        if ($db_user =~ /\s$/ or $db_passwd =~ /\s$/) {
            warn "WARN: trailing whitepace detected in either DB username and/or password. Trying again without them...\n\n"
        }
        $db_user =~ s/\s*$//;
        $db_passwd =~ s/\s*$//;
    }

    my $data_source = "dbi:Pg:dbname=$db_name;host=$db_host;connect_timeout=$db_connect_timeout";
    $data_source .= ";port=$db_port" if defined $db_port;

    $class->SUPER::connect($data_source,
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

	# Get list of sources
	my $source_list = $db->{source_registrations};

	# Create procedures
	for my $class (keys (%$source_list)) {
		my $package = $source_list->{$class}->{result_class};
		my $table_name = $source_list->{$class}->{name};

		my $function = $package->can('get_procedures');
		if ($function) {
			my @elem_array = $function->();
			for my $elem (@elem_array) {
				my $drop_query = QVD::DB::Translator::translate_drop_procedure($elem);
				my $create_query = QVD::DB::Translator::translate_create_procedure($elem);
				if($drop_query and $create_query) {
					$dbh->do($drop_query);
					$dbh->do($create_query);
				}
			}
		}
	}

	# Create triggers
	for my $class (keys (%$source_list)) {
		my $package = $source_list->{$class}->{result_class};
		my $table_name = $source_list->{$class}->{name};

		my $function = $package->can('get_triggers');
		if ($function) {
			my @elem_array = $function->();
			for my $elem (@elem_array) {
				my $drop_query = QVD::DB::Translator::translate_drop_trigger($elem);
				my $create_query = QVD::DB::Translator::translate_create_trigger($elem);
				if($drop_query and $create_query) {
					$dbh->do($drop_query);
					$dbh->do($create_query);
				}
			}
		}
	}

	# Create DB version
	$db->resultset('Version')->create({ component => 'schema', version => '3.3.0' });
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
