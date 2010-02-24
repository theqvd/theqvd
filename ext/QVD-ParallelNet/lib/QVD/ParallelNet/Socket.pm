package QVD::ParallelNet::Socket;

use strict;
use warnings;

use QVD::ParallelNet::Constants qw(:error);

sub reset {
    my $self = shift;
    $self->{_nps_input} = '';
    $self->{_nps_output} = '';
    $self->{_nps_error} = NETPAR_OK;
    undef $self->{_nps_closed}
}

sub new {
    my ($class, $sock) = @_;
    my $self = { _nps_sock => $sock };
    bless $self, $class;
    $self->reset;
    $self;
}

sub queue_input { shift->{_nps_input} .= join('', @_) }

sub unqueue_output {
    my $bout = \(shift->{_nps_output});
    substr $$bout, 0, length $$bout, '';
}

sub sock { shift->{_nps_sock} }

sub _nps_done { shift->{_nps_closed} }

sub run {
    my $self = shift;
    my $par = QVD::ParallelNet->new(@_);
    $par->register($self);
    $par->run;
}

1;
