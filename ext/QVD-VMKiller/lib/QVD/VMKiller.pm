package QVD::VMKiller;

our $VERSION = '3.1';

use strict;
use warnings;

use QVD::Log;
use QVD::Config::Core;

use QVD::VMKiller::KVM;
use QVD::VMKiller::LXC;

use Fcntl ();

sub kill_dangling_vms {
    my $hkd_lock_fn = core_cfg('internal.hkd.lock.path');
    INFO "Starting";
    sysopen my $hkd_lock_fh, $hkd_lock_fn, Fcntl::O_CREAT()|Fcntl::O_RDWR()
        or LOGDIE "Unable to open file '$hkd_lock_fn'";

    if (flock($hkd_lock_fh, Fcntl::LOCK_EX() | Fcntl::LOCK_NB())) {
        INFO "Looking for dangling VMs";
        "QVD::VMKiller::$_"->kill_dangling_vms for qw(KVM LXC);
    }
    else {
        if ($! == Errno::EAGAIN()) {
            INFO "HKD is running";
            return
        }
        LOGDIE "flock failed: $!";
    }
    INFO "Done";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

QVD::VMKiller - Perl extension for blah blah blah

=head1 SYNOPSIS

  use QVD::VMKiller;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for QVD::VMKiller, created by h2xs. It looks like the
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

root, E<lt>root@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
