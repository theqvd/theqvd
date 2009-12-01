package QVD::Admin::Web::Controller::Hosts;

use strict;
use warnings;
use parent 'Catalyst::Controller';
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
}

sub del_submit :Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');
    my $id = $c->req->body_params->{id}; # only for a POST request
    if (my $countdel = $model->host_del($id)) {
	$c->stash->{response_type} = "success";
	$c->stash->{response_msg} = "$id eliminado correctamente";
    } else {
# FIXME response_type must be an enumerated	
	$c->stash->{response_type} = "error";
	$c->stash->{response_msg} = $model->error_msg;
    }
    $c->go('list');
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
