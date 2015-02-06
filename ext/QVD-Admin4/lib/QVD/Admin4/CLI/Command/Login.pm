package QVD::Admin4::CLI::Command::Login;
use base qw( CLI::Framework::Command::Meta );
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
    $self->cache->set( login => $login );
    my $app = $self->get_app;

    my $password = $self->read_password;
    $self->cache->set( password => $password );
    $self->cache->set( sid => undef );
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
