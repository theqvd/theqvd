package QVD::DB;

use warnings;
use strict;

use parent qw/DBIx::Class::Schema/;
use DBIx::Class::Exception;

use Config::Tiny;

=head1 NAME

QVD::DB - The great new QVD::DB!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->load_namespaces(result_namespace => 'Result');
__PACKAGE__->exception_action(sub { warn @_ ; DBIx::Class::Exception::throw(@_);});

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::DB;

    my $foo = QVD::DB->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=cut

sub new {
    my $class = shift;
    
    my $config = Config::Tiny->new();
    # Carga los parámetros necesarios desde el fichero de configuración
    $config = Config::Tiny->read('config.ini');
    my $conn_data_source = $config->{database}->{data_source};
    my $conn_username = $config->{database}->{username};
    my $conn_password = $config->{database}->{password};
    
    my @conn_info = ($conn_data_source, $conn_username, $conn_password, 
    			{ RaiseError => 1, AutoCommit => 0 });
    my $self = { conn_info => \@conn_info };
    bless $self, $class;
    $self->connect(@conn_info);
}

sub erase {
    my $db = shift;
    
    eval { $db->storage->dbh->do("DROP TABLE osis CASCADE") };
    warn $@ if $@;
    $db->txn_commit;

    eval { $db->storage->dbh->do("DROP TABLE vm_runtimes CASCADE") };
    warn $@ if $@;
    $db->txn_commit;

    eval { $db->storage->dbh->do("DROP TABLE vms CASCADE") };
    warn $@ if $@;
    $db->txn_commit;
    
    eval { $db->storage->dbh->do('DROP TABLE host_runtimes CASCADE') };
    warn $@ if $@;
    $db->txn_commit;        

    eval { $db->storage->dbh->do("DROP TABLE hosts CASCADE") };
    warn $@ if $@;
    $db->txn_commit;

    eval { $db->storage->dbh->do('DROP TABLE users CASCADE') };
    warn $@ if $@;
    $db->txn_commit;

    eval { $db->storage->dbh->do('DROP TABLE x_states CASCADE') };
    warn $@ if $@;
    $db->txn_commit;
    
    eval { $db->storage->dbh->do('DROP TABLE vm_states CASCADE') };
    warn $@ if $@;
    $db->txn_commit;
    
    eval { $db->storage->dbh->do('DROP TABLE user_states CASCADE') };
    warn $@ if $@;
    $db->txn_commit;
    
    eval { $db->storage->dbh->do('DROP TABLE x_cmds CASCADE') };
    warn $@ if $@;
    $db->txn_commit;    
    
    eval { $db->storage->dbh->do('DROP TABLE vm_cmds CASCADE') };
    warn $@ if $@;
    $db->txn_commit;
    
    eval { $db->storage->dbh->do('DROP TABLE user_cmds CASCADE') };
    warn $@ if $@;
    $db->txn_commit;    
    
    eval { $db->storage->dbh->do('DROP TABLE configs CASCADE') };
    warn $@ if $@;
    $db->txn_commit;   
    
}

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.es> >>
Nicolas Arenas, C<< <narenas at qindel.es> >> 

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-db at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-DB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::DB


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-DB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-DB>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-DB>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-DB>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Joni Salonen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of QVD::DB
