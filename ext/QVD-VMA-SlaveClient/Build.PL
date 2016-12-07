use strict;
use warnings;
use Module::Build;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

my $builder = Module::Build->new(
    module_name         => 'QVD::VMA::SlaveClient',
    license             => 'gpl',
    dist_author         => q{QVD Team <qvd@qindel.com>},
    dist_version        => '3.5' .  $SUF_VERSION,
    dist_abstract       => 'QVD::VMA::SlaveClient',
    configure_requires => { 'Module::Build' => 0.38  },
    build_requires => {
        'Test::More'       => 0,
    },
    requires => {
        'Net::Server::Fork' => 0,
        'JSON' => 0,
        'QVD::Config::Core' => 0,
        'QVD::HTTPC' => 0,
        'QVD::HTTP::StatusCodes' => 0,
        'QVD::SlaveServer' => 0,
    },
    add_to_cleanup      => [ 'QVD-VMA-SlaveClient-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
