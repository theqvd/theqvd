package QVD::Admin::Web::Controller::Users;

use strict;
use warnings;
use base 'Catalyst::Controller::FormBuilder';

__PACKAGE__->config(
    'Controller::FormBuilder' => {
        new => {
            method     => 'post',
            stylesheet => 1,
            #messages   => '/locale/fr_FR/form_messages.txt',
			messages => ':es_ES'
        },
        #template_type => 'HTML::Template',
        #source_type   => 'CGI::FormBuilder::Source::File',
    }
);

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

sub view : Local :Args(1){
	my ( $self, $c, $userid) = @_;
	my $model = $c->model('QVD::Admin::Web');
	my $rs = $model->vm_list({user_id => $userid});
	$c->stash->{vm_list} = $rs;
	
	my $user = $model->user_find($userid );
	$c->stash(user => $user);
}

sub add : Local Form {
    my ( $self, $c ) = @_;
    my $form  = $self->formbuilder;
    my $model = $c->model('QVD::Admin::Web');

	$form->field(
		name => 'confirm_password',
		validate => {javascript => '!= form.password.value'},
	);


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
