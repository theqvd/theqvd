package QVD::HKD;

use warnings;
use strict;

use Log::Log4perl qw/:easy/;
use QVD::VMAS;

our $VERSION = '0.01';

sub new {
    my ($class, %opts) = @_;
    $loop_wait_time = delete $opts{loop_wait_time};
    my $vmas = QVD::VMAS->new;
    my $self = { 
	loop_wait_time => $loop_wait_time,
	vmas => $vmas,
    };
    bless $self, $class;
}

sub _handle_signal {
    my $signame = shift;
    INFO "Received $signame";
}

sub _install_signals {
    $SIG{USR1} = \&_handle_signal;
}

sub _do_actions {
    my $self = shift;
    my $vmas = $self->{vmas};
}

sub run {
    my $self = shift;
    $self->_install_signals;
    for (;;) {
	$self->_do_actions();
	sleep $self->{loop_wait_time};
    }
}

1;

__END__

=head1 NAME

QVD::HKD - The QVD house-keeping daemon

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::HKD;
    my $hkd = QVD::HKD->new;
    $hkd->run;

=head2 API

=over

=item new(loop_wait_time => time)

Construct a new HKD. 

=item run

Run the HKD processing loop.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Group, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
