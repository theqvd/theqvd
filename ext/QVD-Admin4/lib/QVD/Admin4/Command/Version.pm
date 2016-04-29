package QVD::Admin4::Command::Version;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $ua  = $app->cache->get('user_agent'); 
    my $url  = $app->cache->get('api_info_url'); 

    my $version = eval {
	$ua->get("$url")->res->json('/version/database')
    } // 'Unknown';
    print $version . "\n";
}

1;
