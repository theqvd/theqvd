package QVD::Admin::Web::Controller::Vm;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';
use Data::FormValidator::Constraints qw(:closures);
use List::MoreUtils qw/uniq/;
use Data::Dumper;

use QVD::DB::Simple;


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

QVD::Admin::Web::Controller::Vm - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path  {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    delete($c->session->{vm_add});
    $c->go('list', @_);
}

sub view : Local :Args(1){
    my ( $self, $c, $id) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    
    my $vm = $model->vm_find($id);
    $c->stash(vm => $vm);
    
    $c->stash->{vmrt => $vm->vm_runtime};
}

sub edit : Local Form :Args(1){
    my ( $self, $c, $id) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $form  = $self->formbuilder;
    my $model = $c->model('QVD::Admin::Web');
    
    my $vm = $model->vm_find($id);
    $c->stash(vm => $vm);

    my @tags = sort uniq map { $_->tag_list } $vm->osf->dis;
    $c->stash(tags => \@tags);

    if ( $form->submitted ) {
        if ( $form->validate ) {
            $model->admin->set_filter (id => $id);
            my %params =
                map { $_ => $c->req->body_params->{$_} }
                grep { defined $c->req->body_params->{$_} }
                qw/name ip di_tag vm_ssh_port vm_vnc_port vm_serial_port/;
            my $count = $model->vm_edit (\%params);

            ## I'd like to return to "/vm/view/$id" but this redirect seems to be ignored
            ## I leave it as "/users" to show that it doesn't work
            $c->response->redirect( $c->uri_for( $self->action_for("/users") ) );
        }
    }
}

sub list : Local {
    my ( $self, $c, $s ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
      
    $s = $c->req->parameters->{s};

   
    my $filter = "";
    if ((defined $s) && !($s eq "")) {
        $filter = {-or => [{name => { ilike => "%".$s."%" }}, {"user.login" => { ilike => "%".$s."%" }}]};
    }
    
    my $rs = $model->vm_list($filter, {join => ["user"]});
    $c->stash->{vm_list} = $rs;
    $c->stash->{s} = $s;
}

sub jlist : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->vm_list("", {join => ["user"]});
    
    my @list;
    my $host;
    my $name = "";
    for (@$rs) {
        $host = rs('Host')->find({id => $_->vm_runtime->host_id});
        if ($host) {
            $name = $host->name;
        } else {
            $name = "";
        }
        push(@list, [$_->vm_runtime->vm_id , $_->vm_runtime->vm_state , $_->vm_runtime->vm_cmd , '' , '' , $_->vm_runtime->user_state , $_->vm_runtime->user_cmd, $_->vm_runtime->blocked, $_->vm_runtime->host_id, $name]);
    }
    $c->stash->{vm_list} = \@list;
    $c->stash->{current_view} = 'JSON';
}

sub start_vm : Local {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['selected']
    );

    if ( !$result->success ) 
    {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    } else 
    {
        my $list = $c->req->body_params->{selected};
        for (ref $list ? @$list : $list) {
            my $vm = $model->vm_find($_);
            my $name = $vm->name; 
            if ( my $countstart = $model->vm_start($_) ) 
            {
                if ($c->flash->{response_type} ne "error") {
                    $c->flash->{response_type} = "success";
                }
                $c->flash->{response_msg}  .= "$name ($_) starting. ";
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


sub stop_vm : Local {
   my ( $self, $c ) = @_;
   $c->go('Root', 'login', @_) unless $c->user_exists;
   
   my $model = $c->model('QVD::Admin::Web');

    my $result = $c->form(
        required           => ['selected']
    );


    if ( !$result->success ) 
    {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} =
          "Error in parameters: " . $model->build_form_error_msg($result);
    } else 
    {
        my $list = $c->req->body_params->{selected};
        for (ref $list ? @$list : $list) {
            my $vm = $model->vm_find($_);
            my $name = $vm->name; 
            if ( my $countstop = $model->vm_stop($_) ) 
            {
                if ($c->flash->{response_type} ne "error") {
                        $c->flash->{response_type} = "success";
                    }
                $c->flash->{response_msg}  .= "$name ($_) stopping. ";
            }
            else {

                # FIXME response_type must be an enumerated
                $c->flash->{response_type} = "error";
                $c->flash->{response_msg} .= $model->error_msg;
            }
        }
    }
    #$c->forward('list');
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
   
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
            my $vm = $model->vm_find($_);
            my $vm_name = $vm->name; 
            if ( my $countdel = $model->vm_del($_) ) {
                if ($c->flash->{response_type} ne "error") {
                    $c->flash->{response_type} = "success";
                }
                $c->flash->{response_msg}  .= "$vm_name ($_) successfully deleted. ";
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

sub disconnect_user : Local {
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
            my $vm = $model->vm_find($_);
            my $vm_name = $vm->name; 
            if ( my $countdel = $model->vm_disconnect_user($_) ) {
                if ($c->flash->{response_type} ne "error") {
                    $c->flash->{response_type} = "success";
                }
                $c->flash->{response_msg}  .= "$vm_name ($_) successfully disconnected. ";
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
            my $vm = $model->vm_find($_);
            my $vm_name = $vm->name; 
            if ( my $countdel = $model->vm_block($_) ) {
                if ($c->flash->{response_type} ne "error") {
                    $c->flash->{response_type} = "success";
                }
                $c->flash->{response_msg}  .= "$vm_name ($_) blocked. ";
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
            my $vm = $model->vm_find($_);
            my $vm_name = $vm->name; 
            if ( my $countdel = $model->vm_unblock($_) ) {
                if ($c->flash->{response_type} ne "error") {
                    $c->flash->{response_type} = "success";
                }
                $c->flash->{response_msg}  .= "$vm_name ($_) unblocked. ";
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


sub _get_add_param {
    my ($self, $c, $param) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $result = defined($c->req->body_params->{$param}) ?
        $c->req->body_params->{$param} : $c->session->{vm_add}->{$param};
    $c->session->{vm_add}->{$param} = $result;
    return $result;
}

=head2

add:

Input:

=over 4

=item * First iteration. Might optionally receive one of the following
POST parameters:

=over 4

=item - vm_name and vm_ip and vm_storage: 
        If vm_name and vm_ip are not defined then the url /vm/add_vm_name is added as a step to gather that info.

=item - user_id:
        If user_id is not defined then the url /vm/add_vm_user_id is added as a step to gather the user_id

=item - osf_id
        If osf_id is not defined then the url /vm/add_vm_osf_id is added as a step to gather the osf_id

=back

Depending on the POST parameters received the session information stores the number of steps needed
to get more information, and the url to get that information.

=item * Next iterations. The step number is increaded and the next url is called to get further parameters
In the last step the VM is added

=back

Output:

The virtual machine is added

=cut
sub add : Local {
    my ( $self, $c ) = @_;
    my $model = $c->model('QVD::Admin::Web');
    my $form  = $self->formbuilder;

    # Body parameters take precedence over session params
    my $vm_name = $self->_get_add_param($c, 'vm_name');
    my $vm_storage = $self->_get_add_param($c, 'vm_storage');
    my $user_id = $self->_get_add_param($c, 'user_id');
    my $osf_id = $self->_get_add_param($c, 'osf_id');

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
        # No previous session info found
        # New session, define the steps needed.
        my @a;
        $steps_array = \@a;
        push @{$steps_array}, 'add_vm_name' 
            if (!defined($vm_name) || $vm_name eq '');
        push @{$steps_array}, 'add_vm_user_id' if (!defined($user_id) || $user_id eq '');
        push  @{$steps_array}, 'add_vm_osf_id' if (!defined($osf_id) || $osf_id eq '');
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

        # TODO
        # Validate all the parameters confirming that they exist

        print STDERR "End step:".Dumper($c->session->{vm_add});
        # Delete the session parameters
        delete($c->session->{vm_add});

        my %parameters = (
            name => $vm_name,
            user_id => $user_id,
            osf_id => $osf_id,
            ip => "",
        );
        $parameters{storage} = $vm_storage if (defined($vm_storage) && $vm_storage ne '');


        if (my $id = $model->vm_add(\%parameters))
        {
            print STDERR "called vm_add ".Dumper($id).Dumper(\%parameters);
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg} = "$vm_name added successfully with id $id";
        }
        else 
        {
            print STDERR "vm_add called with error".Dumper($id);
            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = "A virtual machine of same name already exists.";   ## huh?
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
        $c->response->redirect($c->uri_for($self->action_for($steps_array->[$current_step]) ) );
    }
}

sub add_vm_name : Local Form {
    my ( $self, $c ) = @_;

    $self->formbuilder->action('/vm/add');
    #    $self->formbuilder->{action}= $c->uri_for( $self->action_for('add'));
    #    $self->formbuilder->script_name($c->uri_for( $self->action_for('add')));
    print STDERR "add_vm_name:".Dumper($c->session->{vm_add});
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
        unless exists($c->flash->{current_step});
}

sub add_vm_user_id : Local {
    my ( $self, $c ) = @_;

    #    $self->formbuilder->action('/vm/add');
    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->user_list("");
    $c->stash->{user_list} = $rs;
    print STDERR "add_vm_user_id:".Dumper($c->session->{vm_add});
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
        unless exists($c->flash->{current_step});
}

sub add_vm_osf_id : Local {
    my ( $self, $c ) = @_;

    #    $self->formbuilder->action('/vm/add');
    my $model = $c->model('QVD::Admin::Web');
    my $rs    = $model->osf_list("");
    $c->stash->{osf_list} = $rs;
    print STDERR "add_vm_osf_id:".Dumper($c->session->{vm_add});
    # TODO Check if this should be a pre action
    # To avoid browser refresh or reload
    $c->response->redirect( $c->uri_for( $self->action_for('list') ) )
        if (!exists($c->flash->{current_step}));
}

sub vnc : Local Args(1) {
    my ($self, $c, $id) = @_;
    my $model = $c->model('QVD::Admin::Web');

    if (defined $id) {
        $c->flash->{response_type} = "error";
        $c->flash->{response_msg} = "Error in parameters.";
    }
    else {
        my $vm = $model->vm_find($id);
        my $name = $vm->name; 
        $c->stash(vm_runtime => $vm->vm_runtime);
    }
}

=head1 AUTHOR

QVD,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut

1;
