#!/usr/lib/qvd/bin/perl
use strict;
use warnings;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::CLI;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Parser::Unificator;
use QVD::Admin4::CLI::Tokenizer;
use Text::Table;

my $unificator = QVD::Admin4::CLI::Parser::Unificator->new();
my $grammar = QVD::Admin4::CLI::Grammar->new();
my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();
my $CLI = QVD::Admin4::CLI->new( parser => $parser, tokenizer => $tokenizer);
my $res;

print 'cli > ';

while (my $query = <>)
{
    chomp $query;
    $res = $CLI->query($query);
    print_rows_table();

    print 'cli > ';
}


#### OUTPUT MODEL FOR Text::Table

my @model = ( 
{ is_sep => 1,
  title  => '|',
  body   => '|' },

{ title   => "Key",
  align   => 'left',
  align_title => 'center',
  align_title_lines => 'center' },

{ is_sep => 1,
  title  => '|',
  body   => '|' },

{ title   => "Value",
  align   => 'left',
  align_title => 'center',
  align_title_lines => 'center' },

{ is_sep => 1,
  title  => '|',
  body   => '|' }

);

#### PARSE THE RESPONSE AND PRINT IT
	      
sub print_rows_table
{
    my $n = 0;
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    my $properties = $res->json("/rows/$n");

    while ($properties = $res->json("/rows/$n")) 
    {
	my $tb = Text::Table->new(@model);
	$tb->add("Status $status","$message");

	while (my ($k,$v) = each %$properties)
	{
	    $tb->add($k,$v);
	}

	$n++;
	print_table($tb);
    }
    
    print_status_table() unless $n;
}

sub print_status_table
{
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';

    my $tb = Text::Table->new(@model);
    $tb->add("Status $status","$message");
    print_table($tb);
}

sub print_table
{
    my $tb = shift;
    my $rule = $tb->rule(qw(- +));
    my @body = $tb->body;
    my $title = $tb->title;

    print "\n";
    print $rule;
    print $tb->title;
    print $rule;
    
    for my $row (@body)
    {
	print $row;
	print $rule;
    }
    print "\n";
}
