use strict;
use warnings;
use ExtUtils::MakeMaker;


my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}


WriteMakefile( NAME          => 'QVD::Admin',
               AUTHOR        => 'QVD Team <qvd@qindel.es>',
               VERSION	     => '3.5'.$SUF_VERSION ,
               ABSTRACT      => 'QVD::Admin',
               EXE_FILES     => [ 'bin/qvd-admin.pl'],
               PL_FILES      => {},
               PREREQ_PM     => { 'File::Slurp' => 0,
                                  'QVD::Config' => 0,
                                  'QVD::DB' => 0,
                                  'QVD::L7R::LoadBalancer' => 0,
                                  'QVD::Log' => 0,
                                  'Test::More' => 0,
                                  'Text::Table' => 0,
                                  'Term::ReadKey' => 0,
                                  'DateTime' => 0,
                                  'Digest::SHA' => 0,
                                  'DateTime::Format::Pg' => '0.16007',
                                  'Net::OpenSSH' => 0,
                                  'DateTime::Format::GnuAt' => '0.03' },
             );

