package Linux::Proc::Mountinfo;

our $VERSION = '0.01';

use strict;
use warnings;
use Carp;

sub _key {
    my $mnt = shift;
    $mnt =~ s|/+|/|g;
    $mnt =~ s|/?$|/|;
    $mnt =~ s|([\0/])|\0$1|g;
    $mnt;
}

sub read {
    my ($class, %opts) = @_;
    my $mnt = delete $opts{mnt};
    my $pid = delete $opts{pid};
    my $file = delete $opts{file};
    %opts and croak "Unknown option(s) ". join(", ", sort keys %opts);

    unless (defined $file) {
        $mnt = "/proc" unless defined $mnt;
        croak "'$mnt' is not a proc filesystem" unless -d $mnt and (stat _)[12] == 0;
        $pid = $$ unless defined $pid;
        $file = "$mnt/$pid/mountinfo";
    }
    open my $fh, '<', $file or croak "Unable to open '$file': $!";

    my @entries;
    my %entry_by_id;
 OUT: while (<$fh>) {
        chomp;
        my @fields = split;
        my ($dash_ix) = grep $fields[$_] eq '-', 6 .. $#fields;
        unless ($dash_ix) {
            warn "dash not found inside mountinfo";
            next;
        }

        if (@fields < $dash_ix + 4) {
            warn "invalid number of fields";
            next;
        }

        s/\\([0-7]{1,3})/chr oct $1/g for @fields;

        my $entry = [ @fields[0 .. 5, $dash_ix+1 .. $#fields],
                      [ @fields[6 .. $dash_ix-1] ],
                      $., $_,
                      _key($fields[4]),
                      [] ];
        push @entries, bless $entry, 'Linux::Proc::Mountinfo::Entry';
        $entry_by_id{$entry->[0]} = $entry;
    }

    for my $entry (@entries) {
        my $parent_id = $entry->[1];
        next if $entry->[0] == $parent_id;
        my $parent = $entry_by_id{$parent_id} or next;
        push @{$parent->[13]}, $entry;
    }

    bless \@entries, $class;
}

*new = \&read;

sub at {
    my ($self, $at) = @_;
    my $key = _key $at;
    $_->[12] eq $key and return $_ for @$self;
    ()
}

sub root {
    my $self = shift;
    $_->[4] eq '/' and return $_ for @$self;
    ()
}

package Linux::Proc::Mountinfo::Entry;

sub mount_id        { shift->[ 0] }
sub parent_id       { shift->[ 1] }
sub major_minor     { shift->[ 2] }
sub root            { shift->[ 3] }
sub mount_point     { shift->[ 4] }
sub mount_options   { shift->[ 5] }
sub fs_type         { shift->[ 6] }
sub mount_source    { shift->[ 7] }
sub super_options   { shift->[ 8] }

sub optional_fields { [@{shift->[9]}] }

sub line_number     { shift->[10] }
sub line            { shift->[11] }

sub _key            { shift->[12] }

sub major           { (split /:/, shift->[2])[0] }
sub minor           { (split /:/, shift->[2])[1] }

sub children        { bless [@{shift->[13]}], 'Linux::Proc::Mountinfo' }

sub flatten {
    my $self = shift;
    my @flatten;
    my @queue = $self;
    while (@queue) {
        my $first = shift @queue;
        push @flatten, $first;
        push @queue, @{$first->[13]}
    }
    bless \@flatten, 'Linux::Proc::Mountinfo'
}

1;

__END__

=head1 NAME

Linux::Proc::Mountinfo - Parse Linux /proc/$PID/mountinfo data

=head1 SYNOPSIS

  use Linux::Proc::Mountinfo;

  my $mi = Linux::Proc::Mountinfo->read;

  my $root = $mi->root;
  say $root->mount_source, " mounted at /, filesystem type is ", $root->fs_type;

  my $flatten = $root->flatten;

  # umount all file systems but / in an ordered fashion:
  for (reverse @flatten) {
    my $mount_point = $_->mount_point;
    system umount => $mount_point unless $mount_point eq '/';
  }

=head1 DESCRIPTION

Linux::Proc::Mounts parses the information about mount points provided by
the Linux kernel at C</proc/$PID/mountinfo>.

=head1 API

=head2 The Linux::Proc::Mountinfo class

=head3 Internal public representation

The internal representation of the class is an array whose entries can
be accessed directly unreferencing it. For instance:

  my $mnts = Linux::Proc::Mount->read;

  for my $e (@$mnts) {
    say $e->spec . " is mounted at " . $e->file . " as " . $e->fstype;
  }


=head3 Methods

The following methods are available from this class:

=over 4

=item $mnts = Linux::Proc::Mountinfo->read(%opts)

Reads C</proc/$PID/mountinfo> and returns a new object with the parsed
data.

The accepted options are as follows:

=over 4

=item mnt => $proc

Overrides the default mount point for the procfs at C</proc>.

=item pid => $pid

Reads the C<mountinfo> file of the process with the given PID. By
default the C<mouninfo> file of the current process is read.

For instance, for reading C<init> C<mountinfo> file:

  my $mi = Linux::Proc::Mountinfo->read(pid => 1);

=item file => $filename

Reads and parses the file of the given name.

=back

=item $mi->at($path)

Returns an object representing the mount point at the given place.

For instance:

  my $var = $mi->at('/var');
  print $var->mount_source, " is mounted at /var" if $var;

Returns undef if no file system is mounted there.

=item $mi->root

Returns an object representing the root file system mount point.

=back

=head2 The Linux::Proc::Mountinfo::Entry class

This class is used to represent the single entries on the C<mountinfo>
file.

=head3 Methods

The methods supported by this class are as follows:

=over 4

=item $mie->mount_id

=item $mie->parent_id

=item $mie->major_minor

=item $mie->root

=item $mie->mount_point

=item $mie->mount_options

=item $mie->fs_type

=item $mie->mount_source

=item $mie->super_options

=item $mie->optional_fields

See the excerpt from the Linux documentation below for the meaning of
the return values from these accessors.

=item $mie->line_number

Returns the line number of this entry inside the C<mountinfo> file.

=item $mie->line

Returns the full line on the C<mountinfo> file.

=item $mie->major

Returns the major part or the major:minor field.

=item $mie->minor

Returns the minor part of the major:minor field.

=item $mie->children

Returns an Linux::Proc::Mountinfo object containing the mount point
that are on top of the given one.

=item $mie->flatten

This method is similar to children but returns all the descendants
instead of just the direct ones.

=back

=head1 Excerpt from Linux documentation

What follows is the documentation available from Linux
C<Documentation/Linux/proc.txt>
(L<http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=Documentation/filesystems/proc.txt>)
related to C<mountinfo>.

    3.5	/proc/<pid>/mountinfo - Information about mounts
    --------------------------------------------------------

    This file contains lines of the form:

    36 35 98:0 /mnt1 /mnt2 rw,noatime master:1 - ext3 /dev/root rw,errors=continue
    (1)(2)(3)   (4)   (5)      (6)      (7)   (8) (9)   (10)         (11)

    (1) mount ID: unique identifier of the mount (may be reused after
    umount)

    (2) parent ID: ID of parent (or of self for the top of the mount
    tree)

    (3) major:minor: value of st_dev for files on filesystem

    (4) root: root of the mount within the filesystem

    (5) mount point: mount point relative to the process's root

    (6) mount options: per mount options

    (7) optional fields: zero or more fields of the form "tag[:value]"

    (8) separator: marks the end of the optional fields

    (9) filesystem type: name of filesystem of the form
    "type[.subtype]"

    (10) mount source: filesystem specific information or "none"

    (11) super options: per super block options

    Parsers should ignore all unrecognised optional fields.  Currently
    the possible optional fields are:

    shared:X  mount is shared in peer group X
    master:X  mount is slave to peer group X
    propagate_from:X mount is slave and receives propagation from peer
    group X (*) unbindable mount is unbindable

    (*) X is the closest dominant peer group under the process's root.
    If X is the immediate master of the mount, or if there's no
    dominant peer group under the same root, then only the "master:X"
    field is present and not the "propagate_from:X" field.

    For more information on mount propagation see:

        Documentation/filesystems/sharedsubtree.txt

=head1 SEE ALSO

L<mount(8)> describes the filesystems and the options accepted.

L<Sys::Filesystem> provides similar functionality to this module and
support most common operating systems.

L<Linux::Proc::Mounts> provides similar information from
C</proc/mounts>, though the information from C</proc/$PID/mountinfo>
is supposedly more detailed so there is no reason to use that module
(at least, this is the theory).

=head1 AUTHOR

Salvador FandiE<ntilde>o, E<lt>sfandino@yahoo.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Qindel FormaciE<oacute>n y Servicios S.L.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
