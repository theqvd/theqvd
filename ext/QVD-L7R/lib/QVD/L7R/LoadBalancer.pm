package QVD::L7R::LoadBalancer;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;

use Carp;

my $plugin_module;
for (split /\s*,\s*/, cfg('l7r.loadbalancer.plugin')) {
    s/^\s+//;
    s/\s+$//;
    /^\w+$/ or croak "bad plugin name $_";
    s/^(.)/uc $1/e;
    my $module = "QVD::L7R::LoadBalancer::Plugin::$_";
    eval "require $module; 1"
	or croak "unable to load $module: $@";
    $plugin_module = $module;
}

sub new {
    my $class = shift;
    my $load_balancer = { module => $plugin_module,
		 params  => {} };
    bless $load_balancer, $class;
    $plugin_module->init($load_balancer);
    $load_balancer;
}

sub get_free_host {
    my ($load_balancer) = @_;
    DEBUG "load balancing with module {$load_balancer->{module}}";
    $load_balancer->{module}->get_free_host;
}

sub params { %{shift->{params}} }

1;
