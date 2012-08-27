package QVD::Admin::Web;

use strict;
use warnings;

use QVD::Config;
BEGIN { $QVD::Log::DAEMON_NAME = "wat" };
use QVD::Log;

use Catalyst::Runtime 5.70;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/ConfigLoader
                Static::Simple
                StackTrace
                Unicode
                FormValidator
                Session
                Session::Store::FastMmap
                Session::State::Cookie
                Authentication
               /;
                #-Debug
                #FormBuilder

our $VERSION = sprintf "1.%04d", q$Revision: 6173 $ =~ /(\d+)/xg;
#our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in qvd_admin_web.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( 
        name => 'QVD::Admin::Web',
        session => {flash_to_stash => 1}
     );

my $username = cfg('wat.admin.login');
my $password = cfg('wat.admin.password');

__PACKAGE__->config( 'Plugin::Authentication' =>
            {
                default => {
                    credential => {
                        class => 'Password',
                        password_field => 'password',
                        password_type => 'clear'
                    },
                    store => {
                        class => 'Minimal',
                        users => {
                            $username => {
                                password => $password,
                                editor => 'yes',
                                roles => [qw/admin/],
                            }
                        }
                    }
                }
            }
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

QVD::Admin::Web - Catalyst based application

=head1 SYNOPSIS

    script/qvd_admin_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<QVD::Admin::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Nito Martinez,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut

1;
