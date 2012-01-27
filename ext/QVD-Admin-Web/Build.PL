# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
#use inc::Module::Install;
use Module::Build;

my $build = new Module::Build(
	module_name      => 'QVD::Admin::Web',
	dist_author       => 'QVD Team <qvd@qindel.com',
	dist_version     => '3.1'.$ENV{SVN_REVISION},
	dist_abstract    => 'QVD::Admin::Web - Catalyst based application',
	license          => 'gpl3',

	PL_files         => {},
	pl_files         => glob('script/*.pl'),

	requires => {
		'Catalyst::Runtime'                  => '5.80007',
		'Catalyst::Plugin::ConfigLoader'     => 0,
		'Catalyst::Plugin::Static::Simple'   => 0,
		'Catalyst::Action::RenderView'       => 0,
		'Catalyst::Plugin::FormValidator'    => 0,
		'Catalyst::Plugin::FormBuilder'      => 0,
		'Catalyst::View::Component::jQuery'  => 0,
		'MooseX::Log::Log4perl'              => 0,
		'parent'                             => 0,
		'QVD::Admin'                         => 0,
		'QVD::Config'                        => 0,
		'QVD::Log'                           => 0,
		'Config::General'                    => 0
	}
);

$build->create_build_script();
