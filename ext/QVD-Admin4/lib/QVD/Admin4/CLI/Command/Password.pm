package QVD::Admin4::CLI::Command::Password;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;


sub usage_text { 
"======================================================================================================
                                             PASSWORD COMMAND USAGE
======================================================================================================

  password (Starts a form intended to change the current QVD administrator session)

"


sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $id = $app->cache->get('admin_id'); 

    my $password = $self->read_password;

    my $res = $self->ask_api(
	{ action => 'myadmin_update',
	  filters => { id => { '=' => $id }}, 
	  arguments => { password => $password }});

}

1;
