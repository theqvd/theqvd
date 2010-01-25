package Net::Parallel::Socket;

use strict;
use warnings;

use Net::Parallel::Constants qw(:error);

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

sub append_input { shift->{_nps_input} .= join('', @_) }

sub output { shift->{_nps_output} }

sub sock { shift->{_nps_sock} }

sub _nps_wants_to_read { 1 }

sub _nps_wants_to_write { length shift->{_nps_input} }

sub _nps_done { shift->{_nps_closed} }

sub _nps_do_read {
    my $self = shift;
    my $bout = \$self->{_nps_output};
    my $bytes = sysread($self->{_nps_sock}, $$bout, 16*1024, length $$bout);
    $self->{_nps_closed} = 1 if (not $bytes and (defined $bytes or $! != Errno::EINTR));
}

sub _nps_do_write {
    my $self = shift;
    my $bin = \$self->{_nps_input};
    my $bytes = syswrite($self->{_nps_sock}, $$bout, 16*1024);
    if ($bytes) {
        substr($$bout, 0, $bytes, "");
    }
    else {
        $self->{_nps_closed} = 1 if (defined $bytes or $! != Errno::EINTR);
    }
}

sub run {
    my $self = shift;
    my $par = Net::Parallel->new(@_);
    $par->register($self);
    $par->run;
}

1;
