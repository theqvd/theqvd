package QVD::L7R::Authenticator;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use Carp;

my $case_sensitive_login = cfg('model.user.login.case-sensitive');

my @plugin_modules;
for (split /\s*,\s*/, cfg('l7r.auth.plugins')) {
    s/^\s+//;
    s/\s+$//;
    /^\w+$/ or croak "bad plugin name $_";
    s/^(.)/uc $1/e;
    my $module = "QVD::L7R::Authenticator::Plugin::$_";
    eval "require $module; 1"
        or croak "unable to load $module: $@";
    push @plugin_modules, $module;
}

sub new {
    my $class = shift;
    my $auth = { modules => [@plugin_modules],
                 params  => {},
                 login   => undef,
                 user_id => undef };
    bless $auth, $class;
    $_->init($auth) for @plugin_modules;
    $auth;
}

sub _set_login {
    my ($auth, $login, $passwd) = @_;
    $auth->{login} = $login;
    $auth->{passwd} = $passwd;
    $auth->{params}{'qvd.vm.user.name'} = $login;
}

sub _normalize_login {
    my ($auth, $login) = @_;
    defined $login ? ($case_sensitive_login ? $login : lc $login) : undef;
}

sub recheck_authentication_basic {
    my ($auth, $login, $passwd, $l7r) = @_;
    my $login_normalized = $auth->_normalize_login;

    $auth->{login} eq $login and $auth->{passwd} eq $passwd;
}

sub authenticate_basic {
    my ($auth, $login, $passwd, $l7r) = @_;

    my $login_normalized = $auth->_normalize_login($login);

    DEBUG "authenticating user $login ($login_normalized) with modules @{$auth->{modules}}";
    for (@{$auth->{modules}}) {
        if ($_->authenticate_basic($auth, $login_normalized, $passwd, $l7r)) {
            $auth->_set_login($login_normalized, $passwd);
            return 1;
        }
    }
    return ();
}

sub login { shift->{login} // croak "internal error: user not authenticated yet!" }

sub params { %{shift->{params}} }

sub before_connect_to_vm {
    my $auth = shift;
    DEBUG "calling before_connect_to_vm hook";
    $_->before_connect_to_vm($auth) for @{$auth->{modules}};
}

sub before_list_of_vms {
    my $auth = shift;
    DEBUG "calling before_list_of_vms hook";
    $_->before_list_of_vms($auth) for @{$auth->{modules}};
}

sub allow_access_to_vm {
    my ($auth, $vm) = @_;
    DEBUG "calling allow_access_to_vm hook";
    for (@{$auth->{modules}}) {
        $_->allow_access_to_vm($auth, $vm) or return;
    }
    return 1;
}

1;
