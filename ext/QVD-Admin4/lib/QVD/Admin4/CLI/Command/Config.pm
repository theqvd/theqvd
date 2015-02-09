package QVD::Admin4::CLI::Command::Config;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
config get
config get parameter
config del parameter
config set parameter_key=parameter_value
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;
    my $parsing = $self->parse_string('config',@args);

    if (my $s = $parsing->filters->{key_re})
    {
	$s =~ s/%/.*/g;
	$parsing->filters->{key_re} = qr/^$s$/;
    } 

    my $query = $self->make_api_query($parsing); 
    my $res = $self->ask_api($query);
    $self->print_table($res,$parsing);
}

1;

