package QVD::DB;

our $VERSION = '0.01';

use warnings;
use strict;

use Carp;
use DBIx::Class::Exception;
use Config::Tiny;

use parent qw(DBIx::Class::Schema);

__PACKAGE__->load_namespaces(result_namespace => 'Result');
__PACKAGE__->exception_action(sub { croak @_ ; DBIx::Class::Exception::throw(@_);});

sub new {
    my $class = shift;
    # Load database configuration from file
    my $config = Config::Tiny->read('config.ini');
    my $cdb = $config->{database};
    my $conn_data_source = $cdb->{data_source};
    my $conn_username = $cdb->{username};
    my $conn_password = $cdb->{password};
    $class->SUPER::connect($conn_data_source, $conn_username, $conn_password,
				  { RaiseError => 1, AutoCommit => 1 });
}

sub erase {
    my $db = shift;
    for my $table (qw( vm_runtimes
		       vms
		       vm_properties
		       osis
		       host_runtimes
		       hosts
		       host_properties
		       users
		       user_properties
		       x_states
		       vm_states
		       user_states
		       x_cmds
		       vm_cmds
		       user_cmds
		       configs
		       ssl_configs )
		  ) {

	eval {
	    warn "DROPPING $table\n";
	    $db->storage->dbh->do("DROP TABLE $table CASCADE");
	    $db->txn_commit;
	};
	warn "Error (DROP $table): $@" if $@;
    }
}

sub disconnect { shift->storage->disconnect }

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

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-db at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-DB>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
