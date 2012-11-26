use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'QVD::CommandInterpreter',
#    license             => 'gpl2',
    dist_author         => q{QVD Team <qvd@qindel.com>},
    dist_version_from   => 'lib/QVD/CommandInterpreter.pm',
    configure_requires => { 'Module::Build' => 0.38  },
    build_requires => {
        'Test::More'       => 0,
	'Test::Expect'    => 0,
        'Proc::Background' => 0,
        'Net::Ping' => 0,
    },
    requires => {
        'Log::Log4perl'    => 0,
    },
    add_to_cleanup      => [ 'QVD-CommandInterpreter-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
