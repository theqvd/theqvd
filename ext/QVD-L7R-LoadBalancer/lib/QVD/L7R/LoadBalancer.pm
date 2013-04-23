package QVD::L7R::LoadBalancer;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;

use Carp;

sub _plugin {
    my $name = cfg('l7r.loadbalancer.plugin');
    my ($first, $rest) = $name =~ m/^\s*(\w)(\w*)\s*$/
        or croak "bad plugin name $name";
    my $plugin_module = "QVD::L7R::LoadBalancer::Plugin::". uc($first) . $rest;
    eval "require $plugin_module; 1"
        or croak "unable to load $plugin_module: $@";
    $plugin_module
}

sub new {
    my $class = shift;
    my $plugin = _plugin();
    $plugin->new(@_);
}



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
