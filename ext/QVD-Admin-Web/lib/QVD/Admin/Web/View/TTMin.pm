package QVD::Admin::Web::View::TTMin;


use Moose;
extends 'Catalyst::View::TT';
with 'Catalyst::View::Component::jQuery';

__PACKAGE__->config
    (
     TEMPLATE_EXTENSION => '.tt',
     WRAPPER => 'wrappermin.tt',
     'JavaScript::Framework::jQuery' =>
     {
         library =>
         {
             src => [ '/static/jquery/jquery.min.js', '/static/jquery-ui/jquery-ui.js' ],
             css => [ { href => '/static/jquery-ui/themes/css/themes/ui.all.css', media => 'screen' } ],
         }
     },
    );


=head1 NAME

QVD::Admin::Web::View::TT - TT View for QVD::Admin::Web

=head1 DESCRIPTION

TT View for QVD::Admin::Web.

=head1 SEE ALSO

L<QVD::Admin::Web>

=head1 AUTHOR

Nito Martinez,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut

1;
