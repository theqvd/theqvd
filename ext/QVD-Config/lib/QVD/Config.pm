package QVD::Config;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::DB::Simple;

use Exporter qw(import);
our @EXPORT = qw(cfg);

my %cache = map { $_->key => $_->value } rs(Config)->all;

sub cfg (*;@) { $cache{$_[0]} // $_[1] }

1;

__END__

=head1 NAME

QVD::Config - Retrieve QVD configuration from database.

=head1 SYNOPSIS

This module encapsulate configuration access.

    use QVD::Config;
    my $foo = cfg('field');
    my $bar = cfg('bar', $default_bar);

=head1 DESCRIPTION

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head2 FUNCTIONS

=over

=item cfg($key)

=item cfg($key, $default)

Returns the configuration associated to the given key.

If no entry exist on the database it returns the default value if
given or otherwise undef.

=back

=head1 AUTHORS

Hugo Cornejo (hcornejo at qindel.com)

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-config at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-Config>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009, 2010 Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
