package QVD::Admin4::CLI::Command::Login;
use base qw( QVD::Admin4::CLI::Command );
use Term::ReadKey;
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;
    my $no_credentials = 1;
    my $multitenant = eval {
	$self->ask_api({ action => 'api_info'},
		       $no_credentials)->json('/multitenant')
    };

    my $login = $self->_read('Name');
    my $tenant = $multitenant ? $self->_read('Tenant') : undef;
    my $password = $self->read_password;

    my $app = $self->get_app;
    $app->cache->set( login => $login );
    $app->cache->set( tenant => $tenant );
    $self->cache->set( password => $password );
    $self->cache->set( sid => undef );

    my $res = $self->ask_api(
	{ action => 'current_admin_setup'});

    my $sid = $res->json('/sid');
    my $aid = $res->json('/admin_id');
    my $tid = $res->json('/tenant_id');

    $self->cache->set( sid => $sid );
    $self->cache->set( aid => $aid );
    $self->cache->set( tid => $tid );

    $app->render("Hello $login\n");
}


sub read_password
{
    my $self = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\r";
    $pass;
}


sub _read
{
    my ($self,$msg) = @_;
    print STDERR "$msg: ";
    my $read = <>; 
    chomp $read;
    print STDERR "\r";
    $read;
}

1;
