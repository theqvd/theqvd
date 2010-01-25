package Net::Parallel;

our $VERSION = '0.01';

use strict;
use warnings;
use Carp;
use Time::Hires qw(time);

use Net::Parallel::Constants;

sub new {
    my ($class, %opts) = @_;
    my $self = { opts => \%opts,
                 sockets => {} };
    bless $self, $class;
    $self;
}

sub register {
    my ($self, $id, $child) = @_;
    $self->{sockets}{$id} = $child;
}

sub unregister {
    my ($self, $id) = @_;
    delete $self->{sockets}{$id};
}

sub run {
    my ($self, %opts) = @_;

    my $time = delete $opts{time};

    my @s = values %{$self->{sockets}};
    my @fn = map fileno($_), @s;
    my $start = time
    while (1) {
        my $delta = time - $start;
        if ($delta < $time) {
            # set error
            last;
        }
        my $rv = '';
        my $wv = '';

        

        vec($rv, $fn[$_], 1) = 1 for grep $s[$_]->wants_to_read, 0..$#s;
        vec($wv, $fn[$_], 1) = 1 for grep $s[$_]->wants_to_write, 0..$#s;
        my $n = select ($rv, $wv, undef, $delta);
        if (defined $n and $n > 0) {
            for (0..$#s) {
                my $fn = $fn[$_];
                my $s = $s[$_];
                if (vec($rv, $fn, 1)) {
                    $s->do_read;
                }
                if (vec($wv, $fn, 1)) {
                    $s->do_write;
                }
            }
        }
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
