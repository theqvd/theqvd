package QVD::Admin::Web::Controller::Hosts;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';
use Data::FormValidator::Constraints qw(:closures);
use Data::Dumper;

__PACKAGE__->config(
    'Controller::FormBuilder' => {
        new => {
            method     => 'post',
            stylesheet => 1,

        },

        #template_type => 'HTML::Template',
        #source_type   => 'CGI::FormBuilder::Source::File',
    }
);

=head1 NAME

QVD::Admin::Web::Controller::Hosts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    $c->go('list', @_);
}

sub view : Local : Args(1) {
    my ( $self, $c, $id ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    my $host  = $model->host_find($id);
    $c->stash( host => $host );
}

sub list : Local {
    my ( $self, $c, $s ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    
    $s = $c->req->parameters->{s};
   
    my $filter = "";
    if ((defined $s) && !($s eq "")) {
	$filter = {-or => [{name => { ilike => "%".$s."%" }}, {address => { ilike => "%".$s."%" }}]};
    }
    
    my $rs = $model->host_list($filter);
    
    $c->stash->{host_list} = $rs;
    $c->stash->{s} = $s;
}

sub jlist : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->host_list("");
    
    my @list;
    for (@$rs) {
	push(@list, [$_->id , $_->name , $_->address , $_->runtime->state, $_->runtime->blocked]);

    }
    $c->stash->{vm_list} = \@list;
    $c->stash->{current_view} = 'JSON';
}

sub add : Local Form {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $form = $self->formbuilder;

    my $model = $c->model('QVD::Admin::Web');
    if ( $form->submitted ) {
        if ( $form->validate ) {
            my $name    = $form->field('name');
            my $address = $form->field('address');
            if ( my $id = $model->host_add( $name, $address ) ) {
                $c->flash->{response_type} = "success";
                $c->flash->{response_msg} =
                  "$name added succesfully with id $id";
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
            $c->stash->{invalid_fields} =
              [ grep { !$_->validate } $form->fields ];
        }
    }
}

sub del : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['selected']
    );

    if ( !$result->success ) {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    }
    else {
        my $list = $c->req->body_params->{selected};
	for (ref $list ? @$list : $list) {
	    my $host = $model->host_find($_);
	    my $host_name = $host->name; 
	    if ( my $countdel = $model->host_del($_) ) {
		if ($c->flash->{response_type} ne "error") {
		    $c->flash->{response_type} = "success";
		}
		$c->flash->{response_msg}  .= "$host_name ($_) deleted. ";
	    }
	    else {

		# FIXME response_type must be an enumerated
		$c->flash->{response_type} = "error";
		$c->flash->{response_msg}  .= $model->error_msg;
	    }
	}
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
}

sub block : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['selected']
    );

    if ( !$result->success ) {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    }
    else {
        my $list = $c->req->body_params->{selected};
	for (ref $list ? @$list : $list) {
	    my $host = $model->host_find($_);
	    my $host_name = $host->name; 
	    if ( my $countdel = $model->host_block($_) ) {
		if ($c->flash->{response_type} ne "error") {
		    $c->flash->{response_type} = "success";
		}
		$c->flash->{response_msg}  .= "$host_name ($_) blocked. ";
	    }
	    else {

		# FIXME response_type must be an enumerated
		$c->flash->{response_type} = "error";
		$c->flash->{response_msg}  .= $model->error_msg;
	    }
	}
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
}

sub unblock : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['selected']
    );

    if ( !$result->success ) {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    }
    else {
        my $list = $c->req->body_params->{selected};
	for (ref $list ? @$list : $list) {
	    my $host = $model->host_find($_);
	    my $host_name = $host->name; 
	    if ( my $countdel = $model->host_unblock($_) ) {
		if ($c->flash->{response_type} ne "error") {
		    $c->flash->{response_type} = "success";
		}
		$c->flash->{response_msg}  .= "$host_name ($_) unblocked. ";
	    }
	    else {

		# FIXME response_type must be an enumerated
		$c->flash->{response_type} = "error";
		$c->flash->{response_msg}  .= $model->error_msg;
	    }
	}
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
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

=head1 AUTHOR

QVD,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut

1;
