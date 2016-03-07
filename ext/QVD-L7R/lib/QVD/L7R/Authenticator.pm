package QVD::L7R::Authenticator;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use Carp;

sub _split_plugin_list {
    my ($auth, $list) = @_;
    my @plugins;
    for (split /\s*,\s*/, $list) {
        s/^\s+//;
        s/\s+$//;
        /^\w+$/ or croak "bad plugin name $_";
        s/^(.)/uc $1/e;
        push @plugins, "QVD::L7R::Authenticator::Plugin::$_";
    }
    DEBUG "split_plugin_list($list) => @plugins";
    DEBUG "wantarray => ".wantarray;
    @plugins
}

sub new {
    my $class = shift;
    my $auth = { params  => {},
                 login   => undef,
                 user_id => undef };
    bless $auth, $class;
    $auth->_reload_plugins;
    $auth;
}

sub _reload_plugins {
    my $auth = shift;
    my $tenant_id = $auth->{tenant_id} // 0;
    # We use a sandwich strategy here so that some plugins usage may
    # be enforced by the superadmins:
    my @plugins = ( $auth->_split_plugin_list(cfg('l7r.auth.plugins.head')),
                    $auth->_split_plugin_list(cfg('l7r.auth.plugins', 1, $tenant_id)),
                    $auth->_split_plugin_list(cfg('l7r.auth.plugins.tail')) );
    DEBUG "loading authenticaion plugins for tenant id $tenant_id: @plugins";
    for (@plugins) {
        eval "require $_; 1"
            or croak "unable to load $_: $@";
    }
    $auth->{plugins} = \@plugins;
    $_->init($auth) for @plugins;
    1;
}

# find_tenant works in a first-found fashion
sub _find_tenant {
    my ($auth, $login, $l7r) = @_;
    $login //= '';
    for (@{$auth->{plugins}}) {
        if (my ($tenant, $login1) = $_->find_tenant($auth, $login, $l7r)) {
            return ($tenant, $login1);
        }
    }
    ERROR "unable to find tenant name inside login '$login'";
    ()
}

sub _normalize_tenant {
    my ($auth, $tenant, $l7r) = @_;
    $tenant //= '';
    my $normalized_tenant = (cfg('model.user.login.case-sensitive') ? $tenant : lc $tenant);
    $normalized_tenant =~ s/^\s+//;
    $normalized_tenant =~ s/\s+$//;
    $normalized_tenant = $_->normalize_tenant($auth, $normalized_tenant, $l7r) for @{$auth->{plugins}};
    if (defined $normalized_tenant) {
        $auth->{normalized_tenant} = $normalized_tenant;
        return 1;
    }
    ERROR "tenant normalization for '$tenant' failed";
    ()
}

sub _normalize_login {
    my ($auth, $login, $l7r) = @_;
    $login //= '';
    my $normalized_login = (cfg('model.user.login.case-sensitive', 1, $auth->{tenant_id})
                            ? $login
                            : lc $login);
    $normalized_login =~ s/^\s+//;
    $normalized_login =~ s/\s+$//;
    $normalized_login = $_->normalize_login($auth, $normalized_login, $l7r) for @{$auth->{plugins}};
    if (defined $normalized_login) {
        $auth->{normalized_login} = $normalized_login;
        return 1;
    }
    ERROR "login normalization for '$login' failed";
    ()
}

sub _validate_tenant {
    my ($auth, $name) = @_;
    # Tenant autoprovisioning? not yet!
    # Just check that the tenant exists on the database
    if (defined (my $tenant = rs('Tenant')->search({name => $name})->first)) {
        my $id = $tenant->id;
        if ($id == 0) {
            ERROR "tenant lookup for '$name' returned reserved id 0";
            return;
        }
        if ($tenant->blocked) {
            ERROR "tenant $id ($name) is blocked";
            return;
        }
        $auth->{tenant_id} = $id;
        DEBUG "tenant '$name' found, id: $id";
        return 1;
    }
    ERROR "tenant '$name' not found in database";
    ()
}

sub recheck_authentication_basic {
    my ($auth, $login, $passwd, $l7r) = @_;
    $auth->{login} eq $login and $auth->{passwd} eq $passwd and $auth->{authenticated}
}

sub authenticate_basic {
    my ($auth, $login, $passwd, $l7r) = @_;
    delete $auth->{autenticated};
    $auth->{login} = $login;
    $auth->{passwd} = $passwd;

    # We find the tenant first...
    DEBUG "authenticate_basic('$login', '*****')";
    if (my ($tenant, $login1) = $auth->_find_tenant($login)) {
        if ($auth->_normalize_tenant($tenant)) {
            if ($auth->_validate_tenant($tenant)) {
                $auth->_reload_plugins;

                # Now, go for the user authentication...
                if ($auth->_normalize_login($login1)) {
                    DEBUG "authenticating user $login1 ($auth->{normalized_login}) at $tenant ($auth->{normalized_tenant}) ".
                        " with plugins @{$auth->{plugins}}";
                    for (@{$auth->{plugins}}) {
                        if ($_->authenticate_basic($auth, $auth->{normalized_login}, $passwd, $l7r)) {
                            # note that some backend (i.e. LDAP) may have changed
                            # $auth->{normalized_login} so we can not use our
                            # cached copy in $normalized_login
                            $auth->{params}{'qvd.vm.user.name'} = $auth->{normalized_login};
                            $auth->after_authenticate_basic($auth->{normalized_login}, $l7r);
                            $auth->{authenticated} = 1;
                            return 1;
                        }
                    }
                }
            }
        }
    }
    ();
}

sub normalized_tenant { shift->{normalized_tenant} // croak "internal error: user not authenticated yet!" }

sub normalized_login { shift->{normalized_login} // croak "internal error: user not authenticated yet!" }

sub login { shift->{login} // croak "internal error: user not authenticated yet!" }

sub user_id { shift->{user_id} // croak "internal error: user not authenticated yet!" }

sub tenant_id { shift->{tenant_id} // croak "internal error: user not authenticated yet!" }

sub params { %{shift->{params}} }

sub after_authenticate_basic {
    my ($auth, $login, $l7r) = @_;
    DEBUG "calling after_authenticate_basic hook";
    $_->after_authenticate_basic($auth, $login, $l7r) for @{$auth->{plugins}};
}

# FIXME, pass $l7r object along in the methods bellow
sub before_connect_to_vm {
    my ($auth) = @_;
    DEBUG "calling before_connect_to_vm hook";
    $_->before_connect_to_vm($auth) for @{$auth->{plugins}};
}

sub before_list_of_vms {
    my $auth = shift;
    DEBUG "calling before_list_of_vms hook";
    $_->before_list_of_vms($auth) for @{$auth->{plugins}};
}

sub list_of_vm {
    my ($auth) = @_;
    for (@{$auth->{plugins}}) {
        if ($_->can('list_of_vm')) {
            INFO "Listing VMs using auth module $_";
            return $_->list_of_vm(@_);
        }
    }
    INFO "No VMs found by auth plugins; listing VMs for user ".$auth->{user_id};
    my @vm_list = (rs(VM)->search({user_id => $auth->{user_id}}));
    INFO "Number of available VMs: ".scalar @vm_list;
    return @vm_list;
}

sub allow_access_to_vm {
    my ($auth, $vm) = @_;
    DEBUG "calling allow_access_to_vm hook";
    for (@{$auth->{plugins}}) {
        return 1 if $_->allow_access_to_vm($auth, $vm);
    }
    return ();
}

1;
