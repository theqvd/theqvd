package QVD::VMAS::Client;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $httpc = QVD::HTTPC->new('localhost:3030')
	or croak "unable to connect to VMA";
    my $self = { httpc => $httpc };
    bless $self, $class;
    $self;
}

sub start_vm_listener {
    my ($self, $id) = @_;

    my ($code, $msg, $headers, $data) =
	$self->{httpc}->send_http_query_json('/vma/start_vm_listener');
    if ($data and $data->{status} == 0) {
	return @$data{qw(host, port)};
    }
    return ();
}

sub error {
    return 0;
}

1;
