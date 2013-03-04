package QVD::L7R::Authenticator::Plugin::Auto;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::Admin;

use parent qw(QVD::L7R::Authenticator::Plugin);

my $osf_id = cfg('auth.auto.osf_id');
my $di_tag = cfg('auth.auto.di_tag', 0) // 'default';
my $maxvms = cfg('auth.auto.max_vms', 0) // 5;

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

    if (rs(VM)->search({user_id => $user_id, osf_id => $osf_id})->count == 0) {
	INFO "Auto provisioning VM for user $login ($user_id) with OSF $osf_id";
	my $admin = QVD::Admin->new;
	for my $ix (1..$maxvms) {
	    my $name = "$login-$ix";
	    my $ok;
	    if (rs(VM)->search({name => $name})->count == 0) {
		$admin->cmd_vm_add(name    => $name,
				   user_id => $user_id,
				   osf_id  => $osf_id,
                                   di_tag  => $di_tag);
		$ok = 1;
	    }
	    return if $ok;
	}
	die "Too many VM name collisions on auto provisioning for user $login";
    }
}

1;

__END__

=head1 NAME

QVD::L7R::Authenticator::Plugin::Auto - qvd-l7r authentication plugin that provisions a user account and virtual machine automatically.

=head1 DESCRIPTION

When QVD is configured to authenticate against an external source such as LDAP,
it is likely that QVD doesn't have any record on users who log in. If this
plugin is enabled, the user record is created automatically. User records
created this way are provided with a default virtual machine.

To enable the plugin, add "auto" to C<l7r.auth.plugins>. Set
C<auth.auto.osf_id> to the id to choose the OSF from which the user's virtual
machine is created and optionally C<auth.auto.di_tag> to select the DI tag.

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2011 Qindel FormaciE<oacute>n y Servicios SL.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

=cut

