package Net::Parallel::Socket;

use strict;
use warnings;

use Net::Parallel::Constants qw(:error);

sub reset {
    my $self = shift;
    $self->{input} = '';
    $self->{output} = '';
    $self->{sock} = undef;
    $self->{error} = NETPAR_OK;
}

sub new {
    my ($class, %opts) = @_;

    my $id = delete $opts{Id};
    my $sock_class = delete $opts{SockClass};
    my $sock_opts = delete $opts{SockOpts};
    my %sock_opts = (defined $sock_opts ? %$sock_opts : ());
    %opts and croak "Unsupported option(s) ", join(", ", keys %opts), "found";

    my $self = { sock_opts => \%sock_opts,
		 sock_class => $sock_class,
		 id => $id };
    bless $self, $class;
    $self->reset;
    $self;
}

sub append_input { shift->{input} .= join('', @_);
}

sub output { shift->{output} }

sub sock { shift->{sock} }

sub connect {
    my $self = shift;
    $self->{sock} //= $self->{$sock_class}->new(%{$self->{sock_opts}});
}



sub want_to_read

sub run {
    my $self = shift;
    my $par = Net::Parallel->new(@_);
    $par->register($self);
    $par->run;
}

1;
