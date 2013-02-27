use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::Client::SlaveServer',
    license             => 'gpl',
    dist_author         => q{QVD Team <qvd@qindel.com>},
    dist_version_from   => 'lib/QVD/Client/SlaveServer.pm',
    dist_abstract    	=> 'QVD::Client::SlaveServer',
    configure_requires => { 'Module::Build' => 0.38  },
    build_requires => {
        'Test::More'       => 0,
        'Proc::Background' => 0,
        'Log::Log4perl'    => 0,
    },
    add_to_cleanup      => [ 'QVD-Client-SlaveServer-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
