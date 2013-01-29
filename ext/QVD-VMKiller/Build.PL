# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
#use inc::Module::Install;
use strict;
use warnings;
use Module::Build;

my $cron_dst = '/etc/cron.d'; 

my $build = new Module::Build(
	module_name      => 'QVD::VMKiller',
	dist_author      => 'QVD Team <qvd@qindel.com',
	dist_version     => '3.1'.$ENV{SVN_REVISION},
	dist_abstract    => 'QVD::VMKiller - Kill QVD Zombies VM',
	license          => 'gpl',

	install_path => { 'cron.d' => $cron_dst  },

	configure_requires => { 
		'Module::Build'                      => 0.38
	},

	requires => {
		'Proc::ProcessTable' => 0,
        	'QVD::Config' => '0',
                'QVD::Log' => '0',
	}, 
);


foreach my $ext (qw(cron)) {
	$build->add_build_element($ext);
}

$build->create_build_script();
