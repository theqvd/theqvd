package QVD::Admin4::CLI::Command::Login;
use base qw( QVD::Admin4::CLI::Command );
use Term::ReadKey;
use strict;
use warnings;

sub validate
{
    my ($self, $opts, @args) = @_;
    die "No admin name provided" 
	unless defined $args[0];
}

sub run 
{
    my ($self, $opts, @args) = @_;
    my $login = shift @args;
    my $password = $self->read_password;
    my $app = $self->get_app;

    $app->cache->set( login => $login );
    $self->cache->set( password => $password );
    $self->cache->set( sid => undef );

    my $res = $self->ask_api(
	{ action => 'current_admin_setup', 
	  filters => { name => $login }});

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

1;
