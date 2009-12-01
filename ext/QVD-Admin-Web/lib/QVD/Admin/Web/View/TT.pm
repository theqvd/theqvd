package QVD::Admin::Web::View::TT;

use Moose;
extends 'Catalyst::View::TT';
with 'Catalyst::View::Component::jQuery';

__PACKAGE__->config
    (
     TEMPLATE_EXTENSION => '.tt',
     WRAPPER => 'wrapper.tt',
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

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
