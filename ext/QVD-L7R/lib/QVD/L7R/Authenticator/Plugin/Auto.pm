package QVD::L7R::Authenticator::Plugin::Auto;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::Admin;

use parent qw(QVD::L7R::Authenticator::Plugin);

my $osi_id = cfg('auth.auto.osi_id');

sub before_list_of_vms {
    my ($plugin, $auth) = @_;
    my $login = $auth->{login};
    my $user = rs(User)->search({login => $login})->first;
    my $user_id;

    if ($user) {
	$user_id = $user->id;
    }
    else {
	INFO "Auto provisioning user $login";
	my $user_id_obj = rs(User)->create({ login => $login})
	    // die "Unable to provision user $login";
        $user_id = $user_id_obj->id;
    }

    if (rs(VM)->search({user_id => $user_id})->count == 0) {
	INFO "Auto provisioning VM for user $login ($user_id)";
	my $admin = new QVD::Admin;
	for my $ix (1..5) {
	    my $name = "$login-$ix";
	    my $ok;
	    if (rs(VM)->search({name => $name})->count == 0) {
		$admin->cmd_vm_add(name    => $name,
				   user_id => $user_id,
				   osi_id  => $osi_id);
		$ok = 1;
	    }
	    return if $ok;
	}
	die "Too many VM name collisions on auto provisioning for user $login";
    }
}

1;
