# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
#use inc::Module::Install;
use strict;
use warnings;
use Module::Build;

my $apache_dst; 
my $apache_conf;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
	$SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

if ( -f '/etc/debian_version' ) {
	$apache_conf = 'qvd-wat.conf';
	$apache_dst = '/etc/apache2/sites-available' ;
}
else {
	$apache_conf = 'qvd-wat-suse.conf';
	$apache_dst = '/etc/apache2/conf.d'; 
}

my $build = new Module::Build(
	module_name      => 'QVD::Admin::Web',
	dist_author       => 'QVD Team <qvd@qindel.com',
	dist_version     => '3.5'.$SUF_VERSION ,
	dist_abstract    => 'QVD::Admin::Web - Catalyst based application',
	license          => 'gpl',

	PL_files         => {},
	pl_files         => [ glob('script/*') ],

	configure_requires => { 
		'Module::Build'                      => 0.38
	},

	requires => {
		'Catalyst' => 0,
		'Catalyst::Controller'               => 0,
		'Catalyst::Controller::FormBuilder'  => 0,
		'Catalyst::Runtime'                  => '5.80007',
		'Catalyst::ScriptRunner'             => 0,
		'Catalyst::View::JSON'               => 0,
		'Data::FormValidator::Constraints'   => 0,
		'lib::glob'                          => 0,
		'List::MoreUtils'                    => 0,
		'Moose'                              => 0,
		'QVD::Admin'                         => 0,
		'QVD::Config'                        => 0,
		'QVD::DB::Simple'                    => 0,
		'QVD::Log'                           => 0,
	}, 
	etc_files=> { "etc/apache2/sites-available/$apache_conf"  => "$apache_dst/qvd-wat.conf" },
	install_path => { 'etc' => '/etc' },
);


foreach my $ext (qw(fb tt png jar css gif js zip ico etc conf)) {
	$build->add_build_element($ext);
}

$build->create_build_script();
