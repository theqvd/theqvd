# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
#use inc::Module::Install;
use strict;
use warnings;
use Module::Build;

my $vma_dst; 
if ( -f '/etc/debian_version' ) {
	$vma_dst = '/etc/default' ;
}
else {
	$vma_dst = '/etc/sysconfig'; 
}


my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
	$SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

my $build = new Module::Build(
	module_name      => 'QVD::VMA',
	dist_author       => 'QVD Team <qvd@qindel.com',
	dist_version     => '3.5'.$SUF_VERSION,
	dist_abstract    => 'QVD::VMA - QVD Virtual Machine Agent',
	license          => 'gpl',

	PL_files         => {},
	pl_files         => [ glob('script/*') ],

	configure_requires => { 
		'Module::Build'                      => 0.38
	},

	requires => {
		'QVD::Log' => 0,
                'QVD::SimpleRPC' => 0,
                'App::Daemon' => 0,
                'Config::Properties' => 0,
                'Test::More' => 0 
	}, 
	etc_files=> {
        "etc/vma_defaults.conf"  => "$vma_dst/qvd-vma",
        "etc/vma.conf"           => "/etc/qvd/vma.conf",
    },
	install_path => { 'etc' => '/etc' },
);


foreach my $ext (qw(fb tt png jar css gif js zip ico etc conf)) {
	$build->add_build_element($ext);
}

$build->create_build_script();
