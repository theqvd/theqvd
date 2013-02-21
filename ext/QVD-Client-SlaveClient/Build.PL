use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::Client::SlaveClient',
    license             => 'gpl3',
    dist_author         => q{QVD Team <qvd@qindel.com>},
    dist_version_from   => 'lib/QVD/Client/SlaveClient.pm',
    configure_requires => { 'Module::Build' => 0.38  },
    build_requires => {
        'Test::More'       => 0,
    },
    add_to_cleanup      => [ 'QVD-Client-SlaveClient-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
