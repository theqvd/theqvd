package Net::Parallel::Socket;

use strict;
use warnings;

use Net::Parallel::Constants qw(:error);

sub reset {
    my $self = shift;
    $self->{input} = '';
    $self->{output} = '';
    $self->{error} = NETPAR_OK;
    $self->{done} = undef;
}

sub new {
    my ($class, %opts) = @_;

    my $id = delete $opts{id};
    my $sock = delete $opts{sock};
    my $sock_class = delete $opts{sock_class} // "IO::Socket::INET";
    my %sock_opts = %{ delete $opts{sock_opts} // {} };
    %opts and croak "Unsupported option(s) ", join(", ", keys %opts), "found";

    my $self = { sock_opts => \%sock_opts,
		 sock_class => $sock_class,
		 id => $id,
                 sock => $sock
               };
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

sub wants_to_read { 1 }

sub wants_to_write { lengt

sub run {
    my $self = shift;
    my $par = Net::Parallel->new(@_);
    $par->register($self);
    $par->run;
}

1;
