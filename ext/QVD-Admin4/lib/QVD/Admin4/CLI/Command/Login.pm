package QVD::Admin4::CLI::Command::Login;
use base qw( CLI::Framework::Command::Meta );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

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
    my $password = read_password($app);
    $self->cache->set( password => $password );
    $self->cache->set( sid => undef );
    $app->render("Hello $login\n");
}

1;
