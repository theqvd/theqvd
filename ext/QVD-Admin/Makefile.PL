use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::Admin',
               AUTHOR        => 'QVD Team <qvd@qindel.es>',
               VERSION	     => '3.1'.$ENV{BUILD_NUMBER},
               ABSTRACT_FROM => 'lib/QVD/Admin.pm',
               EXE_FILES     => [ 'bin/qvd-admin.pl'],
               PL_FILES      => {},
               PREREQ_PM     => { 'File::Slurp' => 0,
                                  'QVD::Config' => 0,
                                  'QVD::DB' => 0,
                                  'QVD::L7R::LoadBalancer' => 0,
                                  'QVD::Log' => 0,
                                  'Test::More' => 0,
                                  'Text::Table' => 0,
                                  'DateTime' => 0,
                                  'Digest::SHA' => 0,
                                  'Net::OpenSSH' => 0 },
             );

