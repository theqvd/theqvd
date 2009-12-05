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


sub _get_add_param {
    my ($self, $c, $param) = @_;
    my $result = defined($c->req->body_params->{$param}) ?
	$c->req->body_params->{$param} : $c->session->{vm_add}->{$param};
    $c->session->{vm_add}->{$param} = $result;
    return $result;
}
sub add : Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');
    my $form  = $self->formbuilder;

    # Body parameters take precedence over session params
    my $vm_name = $self->_get_add_param($c, 'vm_name');
    my $vm_ip = $self->_get_add_param($c, 'vm_ip');
    my $vm_storage = $self->_get_add_param($c, 'vm_storage');
    my $user_id = $self->_get_add_param($c, 'user_id');
    my $osi_id = $self->_get_add_param($c, 'osi_id');

    my ($steps_array, $num_steps, $current_step);
    if (exists($c->session->{vm_add}->{steps}))
    {
	#We are already in a session
	# Next step, define our local vars
	$steps_array = $c->session->{vm_add}->{steps};
	$num_steps = $c->session->{vm_add}->{num_steps};
	$current_step = $c->session->{vm_add}->{current_step};
	print STDERR "Current session:".Dumper($c->session->{vm_add});
    }
    else
    {
	my @a;
	$steps_array = \@a;
	push @{$steps_array}, 'add_vm_name' 
	    if (!defined($vm_name) || $vm_name eq ''
		|| !defined($vm_ip) || $vm_ip eq '');
	push @{$steps_array}, 'add_vm_user_id' if (!defined($user_id) || $user_id eq '');
	push  @{$steps_array}, 'add_vm_osi_id' if (!defined($osi_id) || $osi_id eq '');
	$num_steps = $#{$steps_array} + 1;
	$current_step = 0;
	$c->session->{vm_add}->{steps} = $steps_array;
	$c->session->{vm_add}->{num_steps} = $num_steps;
	$c->session->{vm_add}->{current_step} = 1; # For the next iteration, our loop counter is $current_step
	print STDERR "New session:".Dumper($c->session->{vm_add});
    }
    

    if ( $current_step == $num_steps ) 
    {
	# Last step
	# No extra steps needed, create the user
	print STDERR "End step:".Dumper($c->session->{vm_add});
	# Delete the session parameters
	delete($c->session->{vm_add});

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
	print STDERR "New step:".Dumper($c->session->{vm_add});
	$c->flash->{current_step} = $current_step + 1;
	$c->flash->{num_steps} = $num_steps;
	# Invoke next step
	$c->session->{vm_add}->{current_step} = $current_step + 1;
	print STDERR "New step2:".Dumper($c->session->{vm_add});
	$c->response->redirect( $c->uri_for( $self->action_for($$steps_array[$current_step]) ) );
    }
}

sub add_vm_name : Local Form {
    my ( $self, $c ) = @_;

    $self->formbuilder->action('/vm/add');
#    $self->formbuilder->{action}= $c->uri_for( $self->action_for('add'));
#    $self->formbuilder->script_name($c->uri_for( $self->action_for('add')));
    print STDERR "add_vm_name:".Dumper($c->session->{vm_add}, $self->formbuilder);
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
	if (!exists($c->flash->{current_step}));
    
}


sub add_vm_user_id : Local Form {
    my ( $self, $c ) = @_;

    $self->formbuilder->action('/vm/add');
    print STDERR "add_vm_user_id:".Dumper($c->session->{vm_add});
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
	if (!exists($c->flash->{current_step}));
    
}

sub add_vm_osi_id :Local Form {
    my ( $self, $c ) = @_;

    $self->formbuilder->action('/vm/add');
    print STDERR "add_vm_osi_id:".Dumper($c->session->{vm_add});
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
	if (!exists($c->flash->{current_step}));
    
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
