package QVD::Admin::Web::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

QVD::Admin::Web::Controller::Root - Root Controller for QVD::Admin::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub about :Local {
    my ( $self, $c ) = @_;
    # Hello World
    $c->stash->{data} = $c->model('QVD::Admin::Web');

}

sub propget :Local {
    my ( $self, $c ) = @_;
    # Should be a result of propget, and not implemented here
    # TODO
    my $admin = $c->model('QVD::Admin::Web')->admin;
    $admin->reset_filter();
    my $rs = $admin->get_resultset('user');
    my @props = $rs->search_related('properties', {});
    my @var = map { { login => $_->user->login, key => $_->key, value => $_->value } } @props;
    $c->stash->{propgetvar} = \@var;
    $c->stash->{update_uri} = $c->uri_for('/_update_propget');
}


sub _update_propget : Local {
    my ($self, $c) = @_;
 
    $c->model('QVD::Admin::Web')
      ->find({ login => $c->req->params->{login} })
      ->update({
        $c->req->params->{field} => $c->req->params->{value}
      });
 
    $c->res->body( $c->req->params->{value} );
}


sub propset :Local {
    my ( $self, $c ) = @_;
}

sub propsetButton :Local {
    my ( $self, $c ) = @_;
    # Should be a result of propget, and not implemented here
    # TODO
    my $admin = $c->model('QVD::Admin::Web')->admin;
    my $login = $c->req->body_params->{login}; # only for a POST request
    my $key = $c->req->body_params->{key};
    my $value = $c->req->body_params->{value}; 
    $admin->set_filter("login=$login");
    $admin->{current_object} = 'user';
    $admin->cmd_user_propset("$key=$value");
    $admin->reset_filter();
}


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Nito Martinez,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
