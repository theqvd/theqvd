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

=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
