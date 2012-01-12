package Linux::Proc::Mounts;

our $VERSION = '0.01';

use strict;
use warnings;
use Carp;

sub read {
    my ($class, %opts) = @_;
    my $mnt = delete $opts{mnt};

    %opts and croak "Unknown option(s) ". join(", ", sort keys %opts);

    $mnt = "/proc" unless defined $mnt;

    unless (-d $mnt and (stat _)[12] == 0) {
        croak "$mnt is not a proc filesystem";
    }

    my @entries;
    open my $fh, '<', "$mnt/mounts"
        or croak "Unable to open $mnt/mounts: $!";
    while (<$fh>) {
        chomp;
        my @entry = split;
        if (@entry != 6) {
            warn "invalid number of entries in $mnt/mounts line $.";
            next;
        }
        $#entry = 3; # ignore the two dummy values at the end
        s/\\([0-7]{1,3})/chr oct $1/g for @entry;
        push @entry, _key($entry[1]);
        my $entry = \@entry;
        bless $entry, 'Linux::Proc::Mounts::Entry';
        push @entries, $entry;
    }
    bless \@entries, $class;
}

sub _key {
    my $mnt = shift;
    $mnt =~ s|/+|/|g;
    $mnt =~ s|/?$|/|;
    $mnt =~ s|([\0/])|\0$1|g;
    $mnt;
}

sub sorted {
    my $self = shift;
    bless [ sort { $a->[4] cmp $b->[4] } @$self ], ref $self;
}

sub at {
    my ($self, $at) = @_;
    my $key = _key $at;
    bless [ grep { $_->[4] eq $key } @$self ], ref $self;
}

sub under {
    my ($self, $at) = @_;
    my $key = quotemeta _key $at;
    my $re = qr/^$key/;
    bless [ grep { $_->[4] =~ $re } @$self ], ref $self;
}

package Linux::Proc::Mounts::Entry;

sub _key   { shift->[4] }
sub spec   { shift->[0] }
sub file   { shift->[1] }
sub fstype { shift->[2] }
sub opts   { shift->[3] }

sub opts_hash {
    my %h;
    for (split /,/, shift->[3]) {
        if (/(.*)=(.*)/) {
            $h{$1} = $2;
        }
        else {
            $h{$_} = 1;
        }
    }
    \%h;
}

sub is_ro { shift->[3] =~ /(?:^|,)ro(?:,|$)/ }


__END__

=head1 NAME

Linux::Proc::Mounts - Parser for Linux /proc/mounts

=head1 SYNOPSIS

  use Linux::Proc::Mounts;

  my $m = Linux::Proc::Mount->read;

  my $at = $m->at('/');
  if ($at) {
    for (@$at) {

    }


=head1 DESCRIPTION

Stub documentation for Linux::Proc::Mounts, created by h2xs. It looks like the
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

root, E<lt>root@nonetE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
