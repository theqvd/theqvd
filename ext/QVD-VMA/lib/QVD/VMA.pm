package QVD::VMA;

our $VERSION = '0.01';

use warnings;
use strict;

use Proc::ProcessTable;

use parent 'QVD::HTTPD';

sub post_configure_hook {
    my $self = shift;
    my $impl = QVD::VMA::Impl->new();
    $impl->set_http_request_processors($self, '/vma/*');
}

package QVD::VMA::Impl;

use parent 'QVD::SimpleRPC::Server';

sub SimpleRPC_start_vm_listener {
    my $self = shift;

    warn "killing any running nxagent...\n";
    system "pkill nxagent";

    my $pt = Proc::ProcessTable->new;
    my $nxagent_pid;
    for my $process (@{$pt->table}) {
	my $cmnd = $process->cmndline;
	if ($cmnd =~ /\bnxagent\b/) {
	    $nxagent_pid = $process->pid;
	}
    }

    die "nxagent seems to be already running, pid: $nxagent_pid"
	if defined $nxagent_pid;

    my $pid = fork;
    if (!$pid) {
	defined $pid or die "fork failed";
	{ exec "xinit lxsession -- /usr/bin/nxagent :1000 -display nx/nx,link=lan:1000 -ac" };
	{ exec "/bin/false" };
	require POSIX;
	POSIX::_exit(-1);
    }
    # sleep 3;
    {host => 'localhost', port => 5000};
}


1;

__END__

=head1 NAME

QVD::VMA - The great new QVD::VMA!


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::VMA;

    my $foo = QVD::VMA->new();
    ...

=head1 DESCRIPTION

=head2 FUNCTIONS

=over

=item function1

=item function2

=back

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 BUGS


=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2009 Qindel Formacion y Servicios S.L., all rights
reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

