package Linux::Proc::Mounts;

our $VERSION = '0.02';

use strict;
use warnings;
use Carp;

sub read {
    my ($class, %opts) = @_;
    my $mnt = delete $opts{mnt};
    my $pid = delete $opts{pid};
    my $file = delete $opts{file};
    %opts and croak "Unknown option(s) ". join(", ", sort keys %opts);

    unless (defined $file) {
        $mnt = "/proc" unless defined $mnt;
        croak "$mnt is not a proc filesystem" unless -d $mnt and (stat _)[12] == 0;
        $mnt .= "/$pid" if defined $pid;
        $file = "$mnt/mounts";
    }
    open my $fh, '<', $file
        or croak "Unable to open '$file': $!";

    my @entries;
    while (<$fh>) {
        chomp;
        my @entry = split;
        if (@entry != 6) {
            warn "invalid number of entries in $file line $.";
            next;
        }
        $#entry = 3; # ignore the two dummy values at the end
        s/\\([0-7]{1,3})/chr oct $1/g for @entry;
        push @entry, _key($entry[1]);
        push @entry, $.;
        my $entry = \@entry;
        bless $entry, 'Linux::Proc::Mounts::Entry';
        push @entries, $entry;
    }

    for my $i (1..$#entries) {
        my $shadow = $entries[$i];
        # my $re = quotemeta $shadow->[4];
        # $re = qr/^$re/;
        # for my $e (@entries[0..$i-1]) {
        #    $e->[6] = $shadow if $e->[4] =~ $re and not $e->[6];
        # }
        for my $e (@entries[0..$i-1]) {
            $e->[6] = $shadow if $e->[4] eq $shadow->[4] and not $e->[6];
        }
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

sub at {
    my ($self, $at) = @_;
    my $key = _key $at;
    bless [grep { $_->[4] eq $key } @$self], ref $self;
}

sub under {
    my ($self, $under) = @_;
    my $key = quotemeta _key $under;
    my $re = qr/^$key/;
    bless [grep $_->[4] =~ $re, @$self], ref $self;
}

sub visible {
    my $self = shift;
    bless [grep !$_->[6], @$self], ref $self;
}

package Linux::Proc::Mounts::Entry;

sub _key     { shift->[4] }
sub spec     { shift->[0] }
sub file     { shift->[1] }
sub fstype   { shift->[2] }
sub opts     { shift->[3] }
sub ix       { shift->[5] }
sub shadower { shift->[6] }

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

sub is_rw { shift->[3] =~ /(?:^|,)rw(?:,|$)/ }


__END__

=head1 NAME

Linux::Proc::Mounts - Parser for Linux /proc/mounts

=head1 SYNOPSIS

  use Linux::Proc::Mounts;

  my $m = Linux::Proc::Mounts->read;

  my $at = $m->at('/');
  say $_->spec . ' is mounted at /' for (@$at);

  my $under = $m->under('/sys');
  say $_->spec . ' is under /sys as ' . $_->file for (@$under);


=head1 DESCRIPTION

Linux::Proc::Mounts parses the mount points information provided by
the Linux kernel at C</proc/mounts>.

=head1 API

=head2 The Linux::Proc::Mounts class

The internal representation of the class is an array whose entries can
be accessed directly unreferencing it. For instance:

  my $mnts = Linux::Proc::Mount->read;

  for my $e (@$mnts) {
    say $e->spec . " is mounted at " . $e->file . " as " . $e->fstype;
  }

The methods accepted by the class are as follows:

=over 4

=item $mnts = Linux::Proc::Mounts->read

=item $mnts = Linux::Proc::Mounts->read(%opts)

Reads C</proc/mounts> and returns a new object representing the data
there.

The currently supported options are as follows:

=over 4

=item mnt => $proc

Overrides the default mount point for the procfs at C</proc>.

=item pid => $pid

Reads C</proc/$pid/mounts> instead of C</proc/mounts>.

=item file => $filename

Reads the file with the given name.

=back

=item $mnts->at($path)

Returns a new object containing the list of file systems mounted at
the given path.

If no file system is mounted at the given point an object containing
an empty list will be returned. For instance:

  my $at = $mnts->at('/foo');
  say "no file systems are mounted at /foo" unless @$at;

Note than, more than one file system can be mounted in the same
place. For instance, this happens frequently for the root filesystem
(C</>).

=item $mnts->under($path)

Returns a new object containing the list of file systems mounted at or
under the given path.

=item $mnts->visible

Filter out the mount points that are hidden below later mounts.

=back

=head2 The Linux::Proc::Mounts::Entry class

This is the class used to represent single mount points.

The methods provided are as follows:

=over 4

=item $e->spec

Returns the fs_spec field describing the block special device or
remote filesystem mounted.

=item $e->file

Returns the fs_file field describing the mount point for the filesystem.

=item $e->fstype

Returns the fs_vfstype field describing the type of the filesystem.

=item $e->opts

Returns the fs_mntopts field describing the mount options associated
with the filesystem.

=item $e->opts_hash

Returns the fs_mntopts field as a hash.

=item $e->is_ro

Returns a true value when the filesystem has been mounted as read only.

=item $e->is_rw

Returns a true value when the filesystem has been mounted as read/write.

=item $e->ix

Returns the line number of the entry inside the /proc/mounts file.

=item $e->shadower

When the filesystem is hiden behind a later mount performed at the
same path. This method returns the entry of the filesystem shadowing
it.

Note that some mount may also be hidden by a latter mount performed
over some parent directory, but the information available from
/proc/mounts does not allow to detect that condition.

=back

Note that there are no methods to get the fs_freq and fs_passno fields
as the kernel those not store then internally and the corresponding
entries in /proc/mounts are always 0 and so, useless.

=head1 SEE ALSO

L<fstab(5)> describes the format of the /proc/mounts file.

L<mount(8)> describes the filesystems and the options accepted.

L<Linux::Proc::Mountinfo>. The information offered by the Linux kernel
through C</proc/$pid/mountinfo> is more detailed so you should
probably use that module instead of Linux::Proc::Mounts.

L<Sys::Filesystem> provides similar functionality to this module and
support most common operating systems.

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Qindel Formación y Servicios S.L.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
