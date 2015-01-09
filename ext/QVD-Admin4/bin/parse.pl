#!/usr/lib/qvd/bin/perl
use strict;
use 5.010;
use warnings;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Parser::Unificator;
use QVD::Admin4::CLI::Tokenizer;
use Data::Dumper;

my $unificator = QVD::Admin4::CLI::Parser::Unificator->new();
my $grammar = QVD::Admin4::CLI::Grammar->new();
my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();

my $raw_string = <>;
chomp $raw_string;

my $tokens_list = $tokenizer->parse($raw_string);
my $parser_response = $parser->parse($tokens_list);

print Dumper $parser_response;
