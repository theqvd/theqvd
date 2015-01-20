package QVD::Admin4::CLI;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Parser::Edge;

has 'tokenizer', is => 'ro', isa => sub { die "Invalid type for attribute tokenizer" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Tokenizer'; };
has 'parser', is => 'ro', isa => sub { die "Invalid type for attribute parser" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser'; };

has 'ua', is => 'ro', isa => sub { die "Invalid type for attribute ua" 
						  unless ref(+shift) eq 'Mojo::UserAgent'; };

has 'url', is => 'ro', isa => sub { die "Invalid type for attribute url" if ref(+shift); };

has 'sid', is => 'ro', isa => sub { die "Invalid type for attribute sid" if ref(+shift); };

sub BUILD
{
    my $self = shift;
}

sub query
{
    my ($self,$raw_string) = @_;

    my $tokens_list = $self->tokenizer->parse($raw_string);
    my $parser_response = $self->parser->parse($tokens_list);

    if ($parser_response->status)
    {
	return $parser_response->api_query;
    }
    else
    {
	my $json = $parser_response->api_query(sid => $self->sid);
	my $res = $self->ua->post($self->url, json => $json);

	$res->res->code ? return $res->res : 
	{ status => 1100, message => 'No output from API'};
    }
}


1;
