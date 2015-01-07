package QVD::Admin4::CLI;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Parser::Edge;
use Mojo::UserAgent;


my $url = "http://localhost:3000";
my $ua = Mojo::UserAgent->new;

has 'tokenizer', is => 'ro', isa => sub { die "Invalid type for attribute tokenizer" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Tokenizer'; };
has 'parser', is => 'ro', isa => sub { die "Invalid type for attribute parser" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser'; };

sub BUILD
{
    my $self = shift;
}

sub query
{
    my ($self,$raw_string) = @_;

    my $tokens_list = $self->tokenizer->parse($raw_string);
    my $parser_response = $self->parser->parse($tokens_list);

    use Data::Dumper; print Dumper $parser_response->json;
    if ($parser_response->status)
    {
	return $parser_response->api_query;
    }
    else
    {
	my $res = $ua->post($url, json => $parser_response->api_query);

	$res->res->code ? return $res->res : 
	{ status => 1100, message => 'No output from API'};
    }
}


1;
