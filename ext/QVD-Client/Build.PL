#!/usr/bin/perl -w
use strict;
use warnings;
use Module::Build;

my $build = new Module::Build(
               module_name   => 'QVD::Client',
	       author        => 'QVD Team <qvd@qindel.com>',
	       version	     => '3.1'.$ENV{BUILD_NUMBER},
	       abstract_from => 'lib/QVD/Client.pm',
	       PL_files      => {},
	       pl_files      => [ qw(bin/qvd-client.pl bin/qvd-gui-client.pl) ],
	       configure_requires => { 'Module::Build' => 0.38  },
	       requires      => {
				  'Crypt::OpenSSL::X509' => 0,
				  'File::Spec' => 0, 
				  'Cwd' => 0,
				  'IO::Socket::Forwarder' => 0,
				  'IO::Socket::SSL' => 0,
				  'JSON' => 0,
				  'MIME::Base64' => 0,
				  'parent' => 0,
				  'Proc::Background' => 0,
				  'QVD::Config' => 0,
				  'QVD::HTTP' => 0,
				  'QVD::HTTPC' => 0,
				  'Test::More' => 0,
				  'URI::Escape' => 0,
				  'Wx' => 0,
				  'X11::Protocol' => 0,
			      },
		xpm_files    => { 
		                  'pixmaps/qvd.xpm' => 'pixmaps/qvd.xpm',
		                },
		ico_files    => {
				  'pixmaps/qvd.ico' => 'pixmaps/qvd.ico',
		                },
		svg_files    => {
		                  'pixmaps/qvd.svg' => 'pixmaps/qvd.svg',
		                },
		png_files    => {
		                  'pixmaps/qvd-logo.png' => 'pixmaps/qvd-logo.png'
		                },
);

$build->install_path('pixmaps' => $build->config()->{installprefix} . "/pixmaps");

$build->add_build_element('xpm');
$build->add_build_element('ico');
$build->add_build_element('svg');
$build->add_build_element('png');

$build->create_build_script;

