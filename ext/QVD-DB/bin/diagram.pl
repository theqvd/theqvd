#!/usr/bin/perl

use SQL::Translator;
use QVD::DB;

my $schema = QVD::DB->connect;
my $translator = SQL::Translator->new( parser        => 'SQL::Translator::Parser::DBIx::Class',
                                       parser_args   => { package => $schema },
                                       producer      => 'Diagram',
                                       producer_args => { out_file       => 'diagram.png',
                                                          output_type    => 'png',
                                                          title          => 'QVD DB Diagram' } ) or die SQL::Translator->error;
$translator->translate;
