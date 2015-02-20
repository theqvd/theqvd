package QVD::Admin4::CLI::Command::Login;
use base qw( QVD::Admin4::CLI::Command );
use Term::ReadKey;
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $ua  = $app->cache->get('user_agent'); 
    my $url  = $app->cache->get('api_info_url'); 

    my $multitenant = eval {
	$ua->get("$url")->res->json('/multitenant')
    };

    my $login = $self->_read('Name');
    my $tenant = $multitenant ? $self->_read('Tenant') : undef;
    my $password = $self->read_password;

    $app->cache->set( login => $login );
    $app->cache->set( tenant_name => $tenant );
    $app->cache->set( password => $password );
    $app->cache->set( sid => undef );

    my $res = $self->ask_api(
	{ action => 'current_admin_setup'});

    my $sid = $res->json('/sid');
    my $admin_id = $res->json('/admin_id');
    my $tenant_id = $res->json('/tenant_id');

    $app->cache->set( sid => $sid );
    $app->cache->set( admin_id => $admin_id );
    $app->cache->set( tenant_id => $tenant_id );
}


sub read_password
{
    my $self = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\n";
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
