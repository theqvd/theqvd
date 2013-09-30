package QVD::L7R::Authenticator::Plugin::VMPoolAppServerAuthenticator;

use strict;
use warnings;

use QVD::Config;
use QVD::DB::Simple;
use QVD::Log;
use QVD::URI qw(uri_query_split);
use URI::Split qw(uri_split);

use parent 'QVD::L7R::Authenticator::Plugin';

my $dummy_user_id = cfg('l7r.auth.plugin.vm_pool.ephemeral_vm_owner_id');

sub allow_access_to_vm { 
    my ($self, $auth, $vm) = @_;
    $vm->discard_changes;
    return $vm->user_id == $dummy_user_id 
        && $vm->vm_runtime->real_user_id == $auth->{user_id};
}

sub list_of_vm {
    my ($self, $auth, $url, $headers) = @_;
    my $query = (uri_split $url)[3];
    my %params = uri_query_split $query;
    my $file_name = delete $params{file_name};
    INFO "url: $url auth: $auth auth->params: ".$auth->params;
    return () unless ($file_name);

    $auth->{params}{'qvd.client.open_file'} = $file_name;
    my ($file_ext) = ($file_name =~ /([^.]*)$/);
    my @rs = (rs(VM)->search({
            user_id             => $dummy_user_id,
            real_user_id        => undef,
            'properties.key'    => 'qvd.app.file_exts',
            'properties.value'  => {like => "%$file_ext%"}
        },
        {join => ['properties', 'vm_runtime']}));

    INFO "Number of available VMS: ".scalar @rs;

    return ($rs[rand(scalar @rs)]);
}

'dummy';

