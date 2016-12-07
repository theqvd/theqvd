use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Admin4',
    AUTHOR            => 'QVD Team <qvd@qindel.es>',
    VERSION	          => '4.0'.$ENV{BUILD_NUMBER},
    ABSTRACT          => 'QVD::Admin4',
    EXE_FILES         => [ 'bin/qa4' ],
    PREREQ_PM         => {
        'CLI::Framework' => 0,
        'CLI::Framework::Command' => 0,
        'CLI::Framework::Command::Menu' => 0,
        'CLI::Framework::Command::Meta' => 0,
        'CLI::Framework::Exceptions' => 0,
        'Clone' => 0,
        'Mojo::IOLoop' => 0,
        'Mojo::JSON' => 0,
        'Mojo::Message::Response' => 0,
        'Mojo::URL' => 0,
        'Mojo::UserAgent' => 0,
        'Moo' => 0,
        'QVD::API::REST::Filter' => 0,
        'QVD::Config' => 0,
        'Term::ReadKey' => 0,
        'Text::SimpleTable::AutoWidth' => 0,
        'Text::UnicodeTable::Simple' => 0,
        'utf8::all' => 0,
    },
);
