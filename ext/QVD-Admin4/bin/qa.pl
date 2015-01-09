#!/usr/lib/qvd/bin/perl
use strict;
use 5.010;
use warnings;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::CLI;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Parser::Unificator;
use QVD::Admin4::CLI::Tokenizer;
use Text::SimpleTable::AutoWidth;
use Mojo::UserAgent;

my $res;
my $head = "cli > ";

print "$head Address: ";
my $address = <>;
chomp $address;

print "$head Login: ";
my $login = <>;
chomp $login;

print "$head Password: ";
my $password = <>;
chomp $password;

my $ua = Mojo::UserAgent->new;

my $sid =  eval { $ua->post($address, 
			    json => { login => $login, password => $password, 
				      action => "current_admin_setup"})->res->json->{sid} };


my $unificator = QVD::Admin4::CLI::Parser::Unificator->new();
my $grammar = QVD::Admin4::CLI::Grammar->new();
my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();

my $CLI = QVD::Admin4::CLI->new( 
    sid => $sid,
    ua => $ua, 
    url => $address, 
    parser => $parser, 
    tokenizer => $tokenizer);


$head = "cli.$login\@$address> ";
print $head;

while (my $query = <>)
{
    chomp $query;
    $res = $CLI->query($query);

    if (ref($res) eq 'HASH')
    {
	say $res->{status} . ": ".$res->{message};
    }
    else
    { 
	print_table();
    }

    print $head;
}

#### PARSE THE RESPONSE AND PRINT IT
	      
sub print_table
{
    my $n = 0;
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    my $properties = $res->json("/rows/$n");

    my $tb = Text::SimpleTable::AutoWidth->new();
    $tb->max_width(500);
    my $first = $res->json("/rows/0") // {};
    my @keys = sort keys %$first;
    $tb->captions(\@keys);

    while ($properties = $res->json("/rows/$n")) 
    {
	my @values = map {  defined $_ ? $_ : 'undef' } 
	map { ref($_) ? 'ref' : $_ } @{$properties}{@keys};

	$tb->row(@values);
	$n++;
    }
    print $tb->draw; 
}
