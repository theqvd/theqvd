package QVD::VMA;

our $VERSION = '0.01';

use warnings;
use strict;

use Proc::ProcessTable;

use parent QVD::HTTPD;

sub _start_vm_listener {
    my $self = shift;
    my $pt = Proc::ProcessTable->new;
    my $nxagent_pid;
    for my $process (@{$t->table}) {
	my $cmd = $process->cmdline;
	if ($cmd =~ /\bnxagent\b/) {
	    $nxagent_pid = $process->pid;
	}
    }

    die "nxagent seems to be already running, pid: $nxagent_pid"
	if defined $nxagent_pid;

    my $pid = fork;
    if (!$pid) {
	defined $pid or die "fork failed";
	exec "xinit -- /usr/bin/nxagent :1000 -display nx/nx,link=modem:1000 -ac";
	exec "/bin/false";
	require POSIX;
	POSIX::_exit(-1);
    }
    $self->send_http_response_json({host => 'localhost', port => 5000});
    return ('localhost', 5000);
}


sub post_configure_hook {
    my $self = shift;
    $self->set_http_request_processor('/vma/start_vm_listener',
				      \&_start_vm_listener);
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

