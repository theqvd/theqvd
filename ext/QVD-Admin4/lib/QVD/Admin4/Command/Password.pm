package QVD::Admin4::Command::Password;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;


sub usage_text { 
    "======================================================================================================
                                             PASSWORD COMMAND USAGE
======================================================================================================

  password (Starts a form intended to change the current QVD administrator password)

"
}

sub run 
{
    my ($self, $opts, @args) = @_;

    my $password = $self->read_password;

    $self->ask_api(
        $self->get_app->cache->get('api_default_path'),
        {
            action => 'myadmin_update', arguments => { password => $password }
        }
    );
}

1;
