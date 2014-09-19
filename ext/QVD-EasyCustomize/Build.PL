use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::EasyCustomize',
    license             => 'gpl',
    dist_author         => q{QVD Team <qvd@theqvd.com>},
    dist_version_from   => 'lib/QVD/EasyCustomize.pm',
    dist_abstract       => 'QVD::EasyCustomize',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'QVD::Admin'      => 0,
        'Log::Log4perl'   => 0,
        'Pod::Usage'      => 0,
        'Log::Log4perl'   => 0,
        'Term::ReadKey'   => 0,
    },
    add_to_cleanup     => [ 'QVD-EasyCustomize-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
