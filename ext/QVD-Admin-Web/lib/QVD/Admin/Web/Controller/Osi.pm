package QVD::Admin::Web::Controller::Osi;

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
}

sub view : Local :Args(1){
	my ( $self, $c, $id) = @_;
	my $model = $c->model('QVD::Admin::Web');
	my $osi = $model->osi_find($id);
	$c->stash(osi => $osi);
}

=head1 AUTHOR

QVD,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
