package QVD::Admin::Web::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';

#use parent 'Catalyst::Controller';

=head1 NAME

QVD::Admin::Web::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->go('list');

}

sub list : Local {
    my ( $self, $c ) = @_;

    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->user_list("");
    $c->stash->{user_list} = $rs;
}

sub add : Local Form {
    my ( $self, $c ) = @_;
    my $form  = $self->formbuilder;
    my $model = $c->model('QVD::Admin::Web');

    if ( $form->submitted ) {
        if ( $form->validate ) {
            my $login = $form->field('login');
            my $pass  = $form->field('password');
            my $pass2 = $form->field('confirm_password');

            if ( my $id = $model->user_add( $login, $pass ) ) {
                $c->flash->{response_type} = "success";
                $c->flash->{response_msg} = "$login añadido correctamente con id $id";
            }
            else {
                # FIXME response_type must be an enumerated
                $c->flash->{response_type} = "error";
                $c->flash->{response_msg}  = $model->error_msg;
            }
            $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
        }
        else {
            $c->stash->{ERROR} = "INVALID FORM";
            $c->stash->{invalid_fields} = [ grep { !$_->validate } $form->fields ];
        }
    }
}

=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
