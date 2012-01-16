package Linux::Proc::Mountinfo;

our $VERSION = '0.01';

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
        croak "'$mnt' is not a proc filesystem" unless -d $mnt and (stat _)[12] == 0;
        $pid = $$ unless defined $pid;
        $file = "$mnt/$pid/mountinfo";
    }
    open my $fh, '<', $file or croak "Unable to open '$file': $!";

    my @entries;
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

        my @entry = ( @fields[0 .. 5, $dash_ix+1 .. $#fields],
                      [ @fields[6 .. $dash_ix-1] ],
                      $., $_ );
        push @entries, bless \@entry, 'Linux::Proc::Mountinfo::Entry';
    }

    bless \@entries, $class;
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

sub major           { (split /:/, shift->[2])[0] }
sub minor           { (split /:/, shift->[2])[1] }








1;

__END__

=head1 NAME

Linux::Proc::Mountinfo - Parse Linux /proc/$pid/mountinfo data

=head1 SYNOPSIS

  use Linux::Proc::Mountinfo;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Linux::Proc::Mountinfo, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


Documentation from Linux C<Documentation/Linux/proc.txt> (available at
L<http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=Documentation/filesystems/proc.txt>).

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
