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
                 sockets => [] };
    bless $self, $class;
    $self;
}

sub register {
    my ($self, $sock) = @_;
    $self->unregister($sock);
    @push @{$self->{sockets}}, $sock;
}

sub unregister {
    my ($self, $sock) = @_;
    my $sockets = $self->{sockets};
    @$sockets = grep $_ != $sock, @$sockets;
}

sub run {
    my $start = time;
    my ($self, %opts) = @_;

    my $time = delete $opts{time};

    my $npss = $self->{sockets};
    my @socks = map $_->{_nps_sock}, @$npss;
    my @ssl = map UNIVERSAL::isa($_, "IO::Socket::SSL"), @socks;
    my @fn = map fileno($_), @socks;

    # Working here!

    my @ssl_wtr, @ssl_wtw;
    while (1) {
        if (defined $time and time - $start < $time) {
            # set error
            return 1;
        }
        my $rv = '';
        my $wv = '';
        my $cont;
        my (@wtr, @wtw);
        for (0..$#$npss) {
            next if $npss->[$_]->done;
            my $wtr = $wtr[$_] = $npss->[$_]->wants_to_read;
            my $wtw = $wtw[$_] = $npss->[$_]->wants_to_write;

            if ($wtr && !$ssl_wtw[$_] or $wtw && $ssl_wtr[$_]) {
                vec($rv, $fn[$_], 1) = 1;
                $cont = 1;
            }
            if ($wtw && !$ssl_wtr[$_] or $wtr && $ssl_wtw[$_]) {
                vec($wv, $fn[$_], 1) = 1;
                $cont = 1;
            }
        }
        last unless $cont;

        my $n = select ($rv, $wv, undef, $delta);
        if (defined $n and $n > 0) {
            for (0..$#s) {
                my $fn = $fn[$_];
                my $sock = $sock[$_];
                my $canr = vec($rv, $fn, 1);
                my $canw = vec($rw, $fn, 1);
                if ($wtr[$_] and ($canr && !$ssl_wtw[$_] or
                                  $canw && $ssl_wtw[$_])) {
                    my $bout = \$sock->{_nps_output};
                    my $bytes = sysread($sock, $$bout, 16*1024, length $$bout);
                    $sock->do_read;
                }
                elsif ($wtw[$_] and ($canw && !$ssl_wtr[$_] or
                                     $canr && $ssl_wtr[$_])) {
                    $sock->do_write;
                }
            }
        }
    }
    return 0;
}

# Preloaded methods go here.

1;
__END__

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
