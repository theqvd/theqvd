# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'QVD-Admin-Web';
abstract_from 'lib/QVD/Admin/Web.pm';
author_from 'lib/QVD/Admin/Web.pm';
license_from 'lib/QVD/Admin/Web.pm';
perl_version_from 'lib/QVD/Admin/Web.pm';
version '3.1'.$ENV{SVN_REVISION};

requires 'Catalyst::Runtime' => '5.80007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::FormBuilder';
requires 'Catalyst::View::Component::jQuery';
requires 'MooseX::Log::Log4perl';
requires 'parent';
requires 'QVD::Admin';
requires 'QVD::Config';
requires 'QVD::Log';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
#catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
