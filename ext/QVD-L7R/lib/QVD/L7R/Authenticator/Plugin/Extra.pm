package QVD::L7R::Authenticator::Plugin::Extra;

use strict;
use warnings;

use QVD::DB::Simple;

sub before_vm_connect {
    my ($plugin, $auth) = @_;
    my $user_id = $auth->user_id or die "user_id not set in authenticator";
    my $extra = rs(User_Extra)->find($user_id);
    for my $key (qw(department telephone email)) {
	my $val = $extra->$key;
	$auth->{params}{"user.extra.$key"} = $val if defined $val;
    }
}

1;
