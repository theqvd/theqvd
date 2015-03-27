package QVD::Admin4::CLI::Tokenizer;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Tokenizer::Token;

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

    return [\@TOKENS]; # This is a list of analysis
}

1;
