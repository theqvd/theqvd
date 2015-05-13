package QVD::Admin4::CLI::Tokenizer;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Tokenizer::Token;

# Class intended to split a string according a simple grammar
# of regular expressions.

# GRAMMAR OF REGULAR EXPRESSIONS
# Tokens and special tokens are found in the string
# and isolated as words: 

my $SPECIAL_TOKEN = qr/<=|>=|!=|[=,;)([\]!<>~:]|["'][^'"]*["']/;
my $TOKEN = qr/[^\s<=>,;)(\][!~:'"]+/;

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
	$string =~ s/^\s*($TOKEN)\s*// || 
	    $string =~ s/^\s*($SPECIAL_TOKEN)\s*// || last;
	my $form = $1; $form =~ s/['"]//g;

	my $token = QVD::Admin4::CLI::Tokenizer::Token->new(
	    string => $form, from => $position);

	push @TOKENS, $token;
	$position = $token->to + 1;
    }

    return [\@TOKENS]; # This is a list of analysis, though, the current
                       # version of the class always returns just one analysis
}

1;
