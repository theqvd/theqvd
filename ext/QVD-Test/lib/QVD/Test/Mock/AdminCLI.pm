package QVD::Test::Mock::AdminCLI;
use parent qw(QVD::AdminCLI);

sub _print_table {
    my ($self, $header, $body) = @_;
    $self->{table_header} = $header;
    $self->{table_body} = $body;
}

sub table_header { shift->{table_header}; }
sub table_body { shift->{table_body}; }

1;
