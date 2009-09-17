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

    start_or_resume_session;

    # sleep 3;
    {host => 'localhost', port => 5000};
}

sub get_nxagent_pid {
    return `cat /var/run/qvd/nxagent-pid`;
}

sub start_or_resume_session {
    my $pid = get_nxagent_pid;
    if (is_nxagent_running) {
	kill('HUP', $pid);
	while (! is_nxagent_suspended) {
	    # FIXME: timeout
	    sleep 1;
	}
    } else {
	my $pid = fork;
	if (!$pid) {
	    defined $pid or die "fork failed";
	    { exec "xinit gnome-session -- QVD-VMA/bin/nxagent-monitor.pl :1000 -display nx/nx,link=lan:1000 -ac" };
	    { exec "/bin/false" };
	    require POSIX;
	    POSIX::_exit(-1);
	}
    }
}

sub is_nxagent_running {
    my $pid = get_nxagent_pid;
    kill 0, $pid;
}

sub is_nxagent_suspended {
    my $status = `cat /var/run/qvd/state`;
    return $status == 'suspended';
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

