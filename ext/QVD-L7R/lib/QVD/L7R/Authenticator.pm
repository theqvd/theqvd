package QVD::L7R::Authenticator;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;

use Carp;

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
		 user_id => undef };
    bless $auth, $class;
    $_->init($auth) for @plugin_modules;
    $auth;
}

sub authenticate_basic {
    my ($auth, $login, $passwd) = @_;
    DEBUG "authenticating user $login with modules @{$auth->{modules}}";
    for (@{$auth->{modules}}) {
	$_->authenticate_basic($auth, $login, $passwd)
	    and return 1;
    }
    return ();
}

sub user_id { shift->{user_id} // croak "internal error: user not authenticated yet!" }

sub params { %{shift->{params}} }

sub before_connect_to_vm {
    my $auth = shift;
    $_->before_connect_to_vm($auth) for @{$auth->{plugin_modules}};
}

sub before_list_of_vms {
    my $auth = shift;
    $_->auto_provision($auth) for @{$auth->{plugin_modules}};
}

1;
