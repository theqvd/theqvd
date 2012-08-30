use strict;
use warnings;
use Module::Build;

my $build = new Module::Build(
	module_name      => 'QVD::Config::Core',
	dist_author       => 'QVD Team <qvd@qindel.com',
	dist_version     => '3.1'.$ENV{SVN_REVISION},
	dist_abstract    => 'QVD::Admin::Web - Catalyst based application',
	license          => 'gpl',

	configure_requires => { 
		'Module::Build'                      => 0.38
	},

	requires => {
		'Config::Properties' => 0
	}, 
	usr_files => { 'usr/lib/qvd/config/sample-node.conf' => "/usr/lib/qvd/config/sample-node.conf", 'usr/lib/qvd/config/sample-vma.conf' => "/usr/lib/qvd/config/sample-vma.conf" },
	install_path => { 'usr' => '/usr' },
);


foreach my $ext (qw(fb tt png jar css gif js zip ico usr)) {
	$build->add_build_element($ext);
}

$build->create_build_script();

