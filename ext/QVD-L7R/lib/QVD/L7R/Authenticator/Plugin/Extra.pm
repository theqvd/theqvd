package QVD::L7R::Authenticator::Plugin::Extra;

use strict;
use warnings;

use QVD::DB::Simple;

use parent qw(QVD::L7R::Authenticator::Plugin);

sub before_vm_connect {
    my ($plugin, $auth) = @_;
    my $login = $auth->{login};
    my $user = rs(User)->search({login => $login})->first
	// die "Authenticated user $login does not exist in database";
    if (my $extra = $user->extra) {
	for my $key (qw(department telephone email)) {
	    my $val = $extra->$key;
	    $auth->{params}{"user.extra.$key"} = $val if defined $val;
	}
    }
}

1;
