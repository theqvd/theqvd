#!/usr/bin/perl -w
use strict;
use warnings;
use Module::Build;

my $mod = Module::Build->subclass(
	class => 'QVD::ModuleBuilder',
	code => q {

		sub ACTION_locale_files {
			my ($self) = @_;
			use File::Path qw(mkpath);
			use Locale::Msgfmt;

			my @po_files = glob("po/*.po");
			foreach my $po_file (@po_files) {
				my ($lang) = ( $po_file =~ /po\/(.*?)\.po$/ );
				my $d = "blib/locale/$lang/LC_MESSAGES";
				mkpath($d) unless (-d $d);
				Locale::Msgfmt::msgfmt({ in => $po_file, out => "$d/qvd-gui-client.mo" });

			}
		}

		sub ACTION_build {
			my ($self) = @_;
			$self->depends_on('locale_files');
			$self->SUPER::ACTION_build(@_);
		}
	}
);

my $build = $mod->new (
           module_name   => 'QVD::Client',
	       author        => 'QVD Team <qvd@qindel.com>',
	       dist_version  => '3.3'.$ENV{BUILD_NUMBER},
	       abstract_from => 'lib/QVD/Client.pm',
	       PL_files      => {},
	       pl_files      => [ qw(bin/qvd-client.pl bin/qvd-gui-client.pl bin/qvd-slaveclient bin/qvd-open bin/qvd-client-slaveserver) ],
	       configure_requires => {
                  'Module::Build'  => 0.38,
                  'Locale::Msgfmt' => 0,
                  'File::Path'     => 0
           },
	       requires      => {
				  'Crypt::OpenSSL::X509' => 0,
				  'Cwd' => 0,
				  'File::Spec' => 0,
				  'IO::Socket::Forwarder' => 0,
				  'IO::Socket::SSL' => 0,
				  'JSON' => 0,
				  'MIME::Base64' => 0,
				  'parent' => 0,
				  'Proc::Background' => 0,
				  'QVD::Config' => 0,
				  'QVD::HTTP' => 0,
				  'QVD::HTTPC' => 0,
# Needed for qvd-client-slaveserver
#				  'QVD::HTTPD' => 0,
				  'QVD::Log' => 0,
				  'Test::More' => 0,
				  'URI::Escape' => 0,
				  'Wx' => 0,
				  'X11::Protocol' => 0,
                  'Locale::gettext' => 0,
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
		                  'pixmaps/qvd-small.png' => 'pixmaps/qvd-small.png',
		                  'pixmaps/qvd-big.png' => 'pixmaps/qvd-big.png' ,
		                },
		desktop_files => {
				  'desktop/qvd.desktop' => 'desktop/qvd.desktop'
		}, 
);

$build->install_path('pixmaps' => $build->config()->{installprefix} . "/pixmaps");
$build->install_path('desktop' => $build->config()->{installprefix} . "/share/applications");
$build->install_path('locale'  => $build->config()->{installprefix} . "/share/locale");

$build->add_build_element('xpm');
$build->add_build_element('ico');
$build->add_build_element('svg');
$build->add_build_element('png');
$build->add_build_element('desktop');
$build->add_build_element('po');

$build->create_build_script;
