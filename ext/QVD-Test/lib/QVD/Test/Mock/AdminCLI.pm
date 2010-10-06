package QVD::Test::Mock::AdminCLI;
use parent qw(QVD::AdminCLI);

sub _print_table {
    my ($self, $header, $body) = @_;
    $self->{table_header} = $header;
    $self->{table_body} = $body;
}

sub table_header { shift->{table_header}; }
sub table_body { shift->{table_body}; }

# Mock reading password from user
sub _read_password { shift->{mock_password} }

sub set_mock_password {
    my ($self, $mock_password) = @_;
    $self->{mock_password} = $mock_password;
}

# Mock failed commands
sub _die {
    my $self = shift;
    die @_;
}

1;
