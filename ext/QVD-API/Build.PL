use strict;
use warnings;
use Module::Build;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

my $build = Module::Build->new(
    module_name      => 'QVD::API',
    dist_author      => 'QVD Team <qvd@qindel.com',
    dist_version     => '4.2'.$SUF_VERSION,
    dist_abstract    => 'QVD::API - The API of QVD',
    license          => 'gpl',
    requires => {
        'Clone' => 0,
        'Config::Properties' => 0,
        'Data::Page' => 0,
        'Data::Rmap' => 0,
        'DateTime' => 0,
        'DBIx::Error' => 0,
        'Deep::Encode' => 0,
        'Devel::StackTrace' => 0,
        'Devel::StackTrace::Extract' => 0,
        'File::Slurp' => 0,
        'List::Util' => 1.33,
        'Mojo::ByteStream' => 0,,
        'Mojo::IOLoop::ForkCall' => 0,
        'Mojo::JSON' => 0,
        'Mojolicious::Lite' => 0,
        'Mojo::Log' => 0,
        'Mojo::Pg' => 0,
        'Mojolicious::Plugin' => 0,
        'Mojolicious::Plugin::SetUserGroup' => 0,
        'MojoX::Session' => 0,
        'MojoX::Session::Transport' => 0,
        'Moo' => 0,
        'Moose' => 0,
        'QVD::Config' => 0,
        'QVD::Config::Core' => 0,
        'QVD::Config::Network' => 0,
        'QVD::DB::AclsOverwriteList' => 0,
        'QVD::DB::Simple' => 0,
        'QVD::L7R::LoadBalancer' => 0,
        'QVD::VMProxy' => 0,
        'TryCatch' => 0,
        'Try::Tiny' => 0,
    },
    etc_files=> {
        "etc/systemd/system/qvd-api.service"                 => "/etc/systemd/system/qvd-api.service",
    },
    install_path => { 'etc' => '/etc' },
    script_files => [ 'bin/qvd-api.debrc.pl', 'bin/qvd-api.initrc.pl', 'bin/qvd-api.pl' ],
);

$build->create_build_script();
