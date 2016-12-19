package QVD::Admin4::Command::Logout;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;

sub usage_text { 
"======================================================================================================
                                             LOGOUT COMMAND USAGE
======================================================================================================

  logout (Removes the current QVD administrator session)

"
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->ask_api_standard(
        $self->get_app->cache->get('api_default_path') . '/logout',
        { }
    );
    
    $self->cache->set( login => undef );
    $self->cache->set( password => undef );
    $self->cache->set( sid => undef );
}
1;
