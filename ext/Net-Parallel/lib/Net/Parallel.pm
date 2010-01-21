package Net::Parallel;

our $VERSION = '0.01';

use strict;
use warnings;

use Net::Parallel::Constants;

sub new {
    my ($class, %opts) = @_;
    my $self = { opts => \%opts,
		 children => {} };
    bless $self, $class;
    $self;
}

sub register {
    my ($self, $id, $child) = @_;
    $self->{children}{$id} = $child;
}

sub unregister {
    my ($self, $id) = @_;
    delete $self->{children}{$id};
}

sub run {
    my ($self, %opts) = @_;
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Net::Parallel - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Net::Parallel;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Net::Parallel, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandino, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Salvador Fandino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
