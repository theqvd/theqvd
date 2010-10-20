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
__END__

=head1 NAME

QVD::L7R::LoadBalancer - Load balancer component for QVD

=head1 SYNOPSIS

    my $lb = new QVD::L7R::LoadBalancer();
    my $host_id = $lb->get_free_host;
    
=head1 DESCRIPTION

The QVD load balancer component is used to find a free host for starting
virtual machines on the QVD cluster. It uses a plugin mechanism; the plugins
are subclasses of C<QVD::L7R::LoadBalancer>. Which plugin is used is determined
by the C<l7r.loadbalancer.plugin> configuration setting.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
