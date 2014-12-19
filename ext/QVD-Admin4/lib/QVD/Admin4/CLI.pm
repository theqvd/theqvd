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
    my $api_query = $self->parser->parse($tokens_list);
    $api_query->{login} = 'superadmin';
    $api_query->{password} = 'superadmin';
    my $qvd_object = delete $api_query->{qvd_object};
    my $type_of_action = delete $api_query->{command};
    $api_query->{action} = $qvd_object."_".$type_of_action;

     my $res = $ua->post($url, json => $api_query);
    $res ? return $res->res : 
    { status => 1100, message => 'No output from API'};
}


1;
