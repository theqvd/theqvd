package QVD::DB;

our $VERSION = '0.01';

use warnings;
use strict;

use Carp;
use DBIx::Class::Exception;

require QVD::Config;

use parent qw(DBIx::Class::Schema);

__PACKAGE__->load_namespaces(result_namespace => 'Result');
__PACKAGE__->exception_action(sub { croak @_ ; DBIx::Class::Exception::throw(@_);});

sub new {
    my $class = shift;
    my $name = QVD::Config::core_cfg('database.name');
    my $user = QVD::Config::core_cfg('database.user');
    my $host = QVD::Config::core_cfg('database.host');
    my $passwd = QVD::Config::core_cfg('database.password');
    $class->SUPER::connect("dbi:Pg:dbname=$name;host=$host",
			   $user, $passwd,
                           { RaiseError => 1,
			     AutoCommit => 1,
                             quote_char => '"',
			     name_sep   => '.' });
}

my %initial_values = ( VM_State   => [qw(stopped starting running
					 stopping_1 stopping_2
					 zombie_1 zombie_2)],
		       VM_Cmd     => [qw(start stop)],
		       User_State => [qw(disconnected connecting
					 connected aborting)],
		       User_Cmd   => [qw(abort)] );

sub deploy {
    my $db = shift;
    $db->SUPER::deploy(@_);
    while (my ($rs, $names) = each %initial_values) {
	$db->resultset($rs)->create({name => $_}) for @$names;
    }
}

sub erase {
    my $db = shift;
    my $dbh = $db->storage->dbh;
    for my $table (qw( vm_runtimes
		       vms
		       vm_properties
		       osis
		       host_runtimes
		       hosts
		       host_properties
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

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-db at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-DB>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009, 2010 Qindel Formacion y Servicios S.L., all rights
reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
