package QVD::Admin::Web::Controller::Vm;

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
            #messages   => '/locale/fr_FR/form_messages.txt',
			messages => ':es_ES'
        },
        #template_type => 'HTML::Template',
        #source_type   => 'CGI::FormBuilder::Source::File',
    }
);

=head1 NAME

QVD::Admin::Web::Controller::Vm - Catalyst Controller

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

sub view : Local :Args(1){
	my ( $self, $c, $id) = @_;
	my $model = $c->model('QVD::Admin::Web');
	
	my $vm = $model->vm_find($id);
	$c->stash(vm => $vm);
	
	#my $vm = $model->vmrt_find($id);
	$c->stash->{vmrt => $vm->vm_runtime};
	#die();

}


sub list : Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->vm_list("");
    $c->stash->{vm_list} = $rs;
}

sub start_vm : Local {
   my ( $self, $c ) = @_;
   my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['id'],
        constraint_methods => { 'id' => qr/^\d+$/, }
    );

    if ( !$result->success ) 
    {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    } else 
    {
        my $id = $c->req->body_params->{id};    # only for a POST request
	my $vm = $model->vm_find($id );
	my $name = $vm->name; 
        if ( my $countstart = $model->vm_start($id) ) 
	{
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg}  = "$name ($id) arrancando";
        }
        else {

            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = $model->error_msg;
        }
    }

    #$c->forward('list');
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
   
}


sub stop_vm : Local {
   my ( $self, $c ) = @_;
   my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['id'],
        constraint_methods => { 'id' => qr/^\d+$/, }
    );

    if ( !$result->success ) 
    {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    } else 
    {
        my $id = $c->req->body_params->{id};    # only for a POST request
	my $vm = $model->vm_find($id );
	my $name = $vm->name; 
        if ( my $countstop = $model->vm_stop($id) ) 
	{
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg}  = "$name ($id) parando";
        }
        else {

            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = $model->error_msg;
        }
    }

    #$c->forward('list');
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
   
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
        my $id = $c->req->body_params->{id};    # only for a POST request
	my $vm = $model->vm_find($id );
	my $vm_name = $vm->name; 
        if ( my $countdel = $model->vm_del($id) ) {
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg}  = "$vm_name ($id) eliminado correctamente";
        }
        else {

            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = $model->error_msg;
        }
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
}


sub add : Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');

    my $vm_name = $c->req->body_params->{vm_name};
    my $vm_ip = $c->req->body_params->{vm_ip};
    my $vm_storage = $c->req->body_params->{vm_storage};
    my $user_id = $c->req->body_params->{user_id};
    my $osi_id = $c->req->body_params->{osi_id};

    # If any parameter is defined we skip that step
    my @steps;
    push @steps, 'add_vm_name' 
	if (!defined($vm_name) || $vm_name eq ''
	  || !defined($vm_ip) || $vm_ip eq '');
    push @steps, 'add_vm_user_id' if (!defined($user_id) || $user_id eq '');
    push @steps, 'add_vm_osi_id' if (!defined($osi_id) || $osi_id eq '');

    if ( $#steps == -1 ) 
    {
	# No extra steps needed, create the user
	print STDERR "steps is 0\n";
	my %parameters = (
	    name => $vm_name,
	    user_id => $user_id,
	    osi_id => $osi_id,
	    ip => $vm_ip
	    );
	$parameters{storage} = $vm_storage if (defined($vm_storage) && $vm_storage ne '');
	if (my $id = $model->vm_add(\%parameters))
	{
	    print STDERR "called vm_add ".Dumper($id).Dumper(\%parameters);
	    $c->flash->{response_type} = "success";
	    $c->flash->{response_msg} = "$vm_name añadido correctamente con id $id";
	}
	else 
	{
	    print STDERR "vm_add called with error".Dumper($id);
	    # FIXME response_type must be an enumerated
	    $c->flash->{response_type} = "error";
	    $c->flash->{response_msg}  = $model->error_msg;
	}
	$c->response->redirect( $c->uri_for( $self->action_for('list') ) );
    }
    else 
    {
	$c->flash->{steps} = \@steps;
	$c->flash->{num_steps} = $#steps + 1;
	$c->flash->{current_step} = 1;
	$c->response->redirect( $c->uri_for( $self->action_for($steps[0]) ) );
    }
}

sub add_vm_name : Local {
    my ( $self, $c ) = @_;
    
}


sub add_vm_user_id : Local {
    my ( $self, $c ) = @_;
}

sub add_vm_osi_id :Local {
    my ( $self, $c ) = @_;
}

sub vnc : Local :Args(1){
    my ( $self, $c, $id) = @_;

    my $model = $c->model('QVD::Admin::Web');

    if ( !defined($id) ) 
    {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} = "Error in parameters.";
    } else 
    {
	my $vm = $model->vm_find($id);
	my $name = $vm->name; 
	$c->stash(vm_runtime => $vm->vm_runtime);
    }   

}

=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
