use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::CommandInterpreter',
    license             => 'GLP3',
    dist_author         => q{QVD Team <qvd@qindel.com>},
    dist_version_from   => 'lib/QVD/CommandInterpreter.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'QVD-CommandInterpreter-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
