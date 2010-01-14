package QVD::Admin::Web::Controller::Osi;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';
use Data::FormValidator::Constraints qw(:closures);
use Data::Dumper;
use QVD::Config;

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



=head1 NAME

QVD::Admin::Web::Controller::Osi - Catalyst Controller

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
    my $rs    = $model->osi_list("");
    $c->stash->{osi_list} = $rs;
    
    $rs = $model->vm_list("");
    $c->stash->{vm_list} = $rs;
}

sub view : Local :Args(1){
    my ( $self, $c, $id) = @_;
    my $model = $c->model('QVD::Admin::Web');
    my $osi = $model->osi_find($id);
    $c->stash(osi => $osi);
}

sub add : Local Form {
    my ( $self, $c ) = @_;

    my $model = $c->model('QVD::Admin::Web');
    
    my $path = QVD::Config->get('shared_storage_path');
    my @file_list = split("\n",qx/ls -1 $path/);
    $c->stash->{osi_file_list} = \@file_list;
    
    if ($c->request->param('_submitted_add')) {
	  
	my $name              = $c->request->param('name');
	my $memory            = $c->request->param('memory');
	my $use_overlay       = $c->request->param('use_overlay');
	my $user_storage_size = $c->request->param('user_storage_size');
	my $disk_image        = $path."/".$c->request->param('disk_image');
	
	# Validations
	$memory = undef if ($memory eq "");
	$user_storage_size = undef if ($user_storage_size eq "");
	
	if ($use_overlay eq "on") {
	    $use_overlay = 1;
	} else {
	    $use_overlay = 0;
	}
	

	
	my %params     = (
	    name => $name,
	    disk_image => $disk_image,
	    memory => $memory,
	    use_overlay => $use_overlay,
	    user_storage_size => $user_storage_size
	);
	
	#print Dumper %params;
	
	if ( my $id = $model->osi_add( \%params ) ) {
		$c->flash->{response_type} = "success";
		$c->flash->{response_msg} =
		  "$name añadido correctamente";
	    }
	    else {
		# FIXME response_type must be an enumerated
		$c->flash->{response_type} = "error";
		$c->flash->{response_msg}  = $model->error_msg;
	    }
	
	# Delete osi
	if ($c->request->param('delete') eq "on") {
	    qx/rm $disk_image /;
	}
	$c->response->redirect( $c->uri_for( $self->action_for('list') ) );
	    
    }

}

sub del : Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['id'],
        constraint_methods => { 'id' => qr/^\d+$/, }
    );
    
    if ( !$result->success ) {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    }
    else {
        my $id      = $c->req->body_params->{id};    # only for a POST request
        my $osi     = $model->osi_find($id);
        my $osiname = $osi->name;
	
        if ( my $countdel = $model->osi_del($id) ) {
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg} = "$osiname ($id) eliminado correctamente";
        }
        else {
            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = $model->error_msg;
        }
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
}

=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
