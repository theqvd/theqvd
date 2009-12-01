package QVD::Admin::Web::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

QVD::Admin::Web::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched QVD::Admin::Web::Controller::Users in Users.');
}


=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1;
