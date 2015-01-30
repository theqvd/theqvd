package QVD::Admin4::CLI::Tokenizer;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Tokenizer::Token;

my $TOKEN = qr/<=|>=|([a-z]|[A-Z]|_|[0-9]|[*.])+|[=,;)([\]!<>\-~:]/;

sub BUILD
{
    my $self = shift;
}

sub parse
{
    my ($self,$string) = @_;
    my $position = 0;

    my @TOKENS;

    while ($string ne '')
    { 
	$string =~ s/^\s*($TOKEN)\s*// || last;
	my $token = QVD::Admin4::CLI::Tokenizer::Token->new(
	    string => $1, from => $position);
	push @TOKENS, $token;
	$position = $token->to + 1;
    }

    return [\@TOKENS]; # This is a list of analysis
}

1;
