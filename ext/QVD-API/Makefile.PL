use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::API',
    AUTHOR            => 'QVD Team <qvd@qindel.es>',
    VERSION	          => '4.0'.$ENV{BUILD_NUMBER},
    ABSTRACT          => 'QVD::API',
    EXE_FILES         => [ 'bin/qvd-api.pl' ],
    PREREQ_PM         => {
        'Clone' => 0,
        'Config::Properties' => 0,
        'Data::Page' => 0,
        'Data::Rmap' => 0,
        'DateTime' => 0,
        'DBIx::Error' => 0,
        'Deep::Encode' => 0,
        'File::Slurp' => 0,
        'Mojo::ByteStream' => 0,,
        'Mojo::IOLoop::ForkCall' => 0,
        'Mojo::JSON' => 0,
        'Mojolicious::Lite' => 0,
        'Mojo::Log' => 0,
        'Mojo::Pg' => 0,
        'Mojolicious::Plugin' => 0,
        'Mojolicious::Plugin::Directory' => 0,
        'Mojolicious::Plugin::SetUserGroup' => 0,
        'MojoX::Session' => 0,
        'MojoX::Session::Transport' => 0,
        'Moo' => 0,
        'Moose' => 0,
        'QVD::Config' => 0,
        'QVD::Config::Core' => 0,
        'QVD::Config::Network' => 0,
        'QVD::DB::Simple' => 0,
        'QVD::L7R::LoadBalancer' => 0,
        'QVD::VMProxy' => 0,
        'TryCatch' => 0,
        'Try::Tiny' => 0,
    },
);
