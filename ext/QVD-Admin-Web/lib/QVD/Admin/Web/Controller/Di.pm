package QVD::Admin::Web::Controller::Di;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';
#use Data::FormValidator::Constraints qw(:closures);
use Data::Dumper;
use QVD::Config;

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

QVD::Admin::Web::Controller::Di - Catalyst Controller

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

sub list : Local {
    my ( $self, $c, $s ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    
    $s = $c->req->parameters->{s};
    
    my $filter = "";
    if ((defined $s) && !($s eq "")) {
        $filter = {path => { ilike => "%".$s."%" }};
    }
    
    my $rs = $model->di_list($filter);
    $c->stash->{di_list} = $rs;
    
    $rs = $model->vmrt_list("", {join => ["user"]});  ## dserrano: I don't think I fully understand this join
    $c->stash->{vmrt_list} = $rs;
    
    $c->stash->{s} = $s;
}

sub view : Local :Args(1){
    my ( $self, $c, $id) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;
    
    my $model = $c->model('QVD::Admin::Web');
    my $di = $model->di_find($id);
    $c->stash(di => $di);
}

sub add : Local Form {
    my ( $self, $c ) = @_;
    $c->go('Root', 'login', @_) unless $c->user_exists;

    my $model = $c->model('QVD::Admin::Web');
    
    my $path = cfg('path.storage.staging');
    my @file_list = split("\n",qx/ls -1 $path/);
    $c->stash->{di_file_list} = \@file_list;

    $c->stash->{osfs} = $model->osf_list;

    if ($c->request->param('_submitted_add')) {
        my $disk_image = $path."/".$c->request->param('disk_image');

        my %params = (
            osf_id => $c->request->param('osf_id'),
            path => $disk_image,
        );

        if ( my $id = $model->di_add( \%params ) ) {
            $c->flash->{response_type} = "success";
            $c->flash->{response_msg} = "DI added successfully";
        } else {
            # FIXME response_type must be an enumerated
            $c->flash->{response_type} = "error";
            $c->flash->{response_msg}  = $model->error_msg;
        }

        # Delete image
        if ($c->request->param('delete') eq "on") {
            qx/rm $disk_image /;
        }

        $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
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
        $c->flash->{response_msg} = "Error in parameters: " . $model->build_form_error_msg ($result);
    } else {
        my $list = $c->req->body_params->{selected};
        for (ref $list ? @$list : $list) {
            my $di = $model->di_find($_);

            if (!defined $di) {
                # FIXME response_type must be an enumerated
                $c->flash->{response_type} = "error";
                $c->flash->{response_msg}  .= 'DI not found';
            } else {
                my $id = $di->id;
                
                if ( my $countdel = $model->di_del($_) ) {
                    $c->flash->{response_type} = "success";
                    $c->flash->{response_msg} .= "DI $id successfully deleted";
                } else {
                    # FIXME response_type must be an enumerated
                    $c->flash->{response_type} = "error";
                    $c->flash->{response_msg}  .= $model->error_msg;
                }
            }
        }
    }

    $c->response->redirect( $c->uri_for( $self->action_for('list') ) );
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
