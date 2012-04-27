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

sub table_column {
    my ($self, $key_col, $value_col) = @_;

    my %cols;
    my $colno = 0;
    foreach my $col ( @{$self->table_header} ) {
        $cols{$col} = $colno++;
    }

    die "$key_col column missing" unless(exists $cols{$key_col});
    die "$value_col column missing" unless(exists $cols{$value_col});

    my $name_col = $cols{$key_col};
    my $want_col = $cols{$value_col};

    return map { $_->[$name_col] => $_->[$want_col] } @{$self->table_body};
}





1;
