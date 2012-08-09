use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME                => 'QVD::Config',
               AUTHOR              => q{Hugo Cornejo <hcornejo@qindel.com>},
               VERSION             => '3.1'.$ENV{BUILD_NUMBER},
               ABSTRACT_FROM       => 'lib/QVD/Config.pm',
               PREREQ_PM           => { 'Config::Properties' => 0,
                                        'Test::More' => 0,
                                        'QVD::Config::Core' => 0 },
               clean               => { FILES => 'QVD-Config-*' }
             );
