package QVD::Admin::Web::Controller::Hosts;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::FormValidator::Constraints qw(:closures);
use Data::Dumper;


=head1 NAME

QVD::Admin::Web::Controller::Hosts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->go('list');
}

sub list :Local {
    my ( $self, $c ) = @_;
 
    my $model = $c->model('QVD::Admin::Web');
    my $rs = $model->host_list("");
    $c->stash->{host_list} = $rs;
}

sub add :Local {
    my ( $self, $c ) = @_;
}

sub add_submit :Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
	required => ['name', 'address'],
	constraint_methods => {
	    'name' => qr/^..*$/,
	    'address' => ip_address()
	}
	);

    if (!$result->success || $result->has_unknown) {
	$c->stash->{response_type} = "error";
	$c->stash->{response_msg} = "Error in parameters: ".$model->build_form_error_msg($result);
	$c->go('list');
    }

    my $name = $c->req->body_params->{name}; # only for a POST request
    my $address = $c->req->body_params->{address};

    
    if (my $id = $model->host_add($name, $address)) {
	$c->stash->{response_type} = "success";
	$c->stash->{response_msg} = "$name añadido correctamente con id $id";
    } else {
# FIXME response_type must be an enumerated	
	$c->stash->{response_type} = "error";
	$c->stash->{response_msg} = $model->error_msg;
    }
    $c->go('list');
    # $c->
}

#sub add_submit_json :Local {
#    $c->stash->{current_view} = 'JSON';
#    $c->view('JSON')->{expose_stash} = [ qw(id) ];
#    my $hostname = $c->req->body_params->{hostname}; # only for a POST request
#    my $mac = $c->req->body_params->{mac}; # only for a POST request
#    my $console = $c->req->body_params->{console}; # only for a POST request
#    $c->stash
#        (
#         id => $id,
#        );
#}

sub del_submit :Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
	   required => ['id'],
       constraint_methods => {
	      'id' => qr/^\d+$/,
	   
	 );

    if (!$result->success) {
       $c->stash->{response_type} = "error";
	   $c->stash->{response_msg} = "Error in parameters: ".$model->build_form_error_msg($result);
    } else { 
       my $id = $c->req->body_params->{id}; # only for a POST request
       if (my $countdel = $model->host_del($id)) {
	      $c->stash->{response_type} = "success";
	      $c->stash->{response_msg} = "$id eliminado correctamente";
       } else {
          # FIXME response_type must be an enumerated	
	      $c->stash->{response_type} = "error";
	      $c->stash->{response_msg} = $model->error_msg;
       }
    }
    $c->forward('list');
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
