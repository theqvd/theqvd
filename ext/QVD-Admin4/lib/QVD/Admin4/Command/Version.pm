package QVD::Admin4::Command::Version;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;

    my $version = $self->ask_api_standard(
        $self->get_app->cache->get('api_info_path'),
        { }
    )->json('/version/database')  // 'Unknown';
    print $version . "\n";
}

1;
