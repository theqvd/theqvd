use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $SUF_VERSION = defined $ENV{BUILD_NUMBER} ? ".$ENV{BUILD_NUMBER}" : '';

my $builder = Module::Build->new(
    module_name         => 'QVD::EasyCustomize',
    license             => 'gpl',
    dist_author         => q{QVD Team <qvd@theqvd.com>},
    dist_version        => '3.5'.$SUF_VERSION,
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
        'Term::ReadKey'   => 0,
    },
    add_to_cleanup     => [ 'QVD-EasyCustomize-*' ],
    create_makefile_pl => 'traditional',
    pl_files           => [ qw(bin/qvd-easy-customize.pl) ],
);

$builder->create_build_script();
