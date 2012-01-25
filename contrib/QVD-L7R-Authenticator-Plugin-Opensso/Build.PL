use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::L7R::Authenticator::Plugin::Opensso',
    license             => 'perl',
    dist_author         => q{Nito Martinez <Nito@Qindel.ES>},
    dist_version        => '3.1'.$ENV{BUILD_NUMBER},
    build_requires => {
        'Test::More' => 0,
        'File::Temp' => 0,
        'File::Spec' => 0,
    },
    requires => {
        'QVD::L7R' => 0,
    },
    add_to_cleanup      => [ 'QVD-L7R-Authenticator-Plugin-Opensso-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
