package QVD::Client::Agent::Controller::Root;
use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

QVD::Client::Agent::Controller::Root - Root Controller for QVD::Client::Agent

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub test :Local {
    my ( $self, $c ) = @_;

}

sub get_rpc_host_port :Local {
    my ( $self, $c ) = @_;

    my $id = $c->req->params->{id} // '';
    my $port = $c->model('Agent')->getPort($id);
    my $host = $c->model('Agent')->host;

    $c->stash->{current_view} = 'Text';
    $c->stash->{'plain'} = {data => "host=$host\nport=$port\n" };
#    $c->stash->{json} =  { host=> '127.0.0.1',	port=> '3111', };
#    $c->stash->{current_view} = 'JSON';
}

sub execute_plugin :Local {
    my ( $self, $c ) = @_;
    my $id = $c->req->params->{'id'} // '';
    my $exec_string = $c->req->params->{'exec'} // '';
    my $pid = $c->model('Agent')->execute($id, $exec_string);
    $c->stash->{current_view} = 'Text';
    $c->stash->{'plain'} = {data => "pid=$pid\n" };
}

sub kill_plugin :Local {
    my ( $self, $c ) = @_;
    my $id = $c->req->params->{'id'} // '';
    my $pid = $c->req->params->{'pid'} // '';
    $pid = $c->model('Agent')->kill_plugin($id, $pid);
    $c->stash->{current_view} = 'Text';
    $c->stash->{'plain'} = {data => "\n" };
}

sub translate :Local {
    my ( $self, $c ) = @_;
    my $id = $c->req->params->{'id'} // '';
    my $windowid = $c->req->params->{'windowid'} // '';
    my $newwindowid = $c->model('Agent')->translate_windowid($id, $windowid);
    $c->stash->{current_view} = 'Text';
    $c->stash->{'plain'} = {data => "windowid=$newwindowid\n" };
}


sub start :Local {
    my ( $self, $c ) = @_;
    my $id = $c->req->params->{id};
    $c->stash->{current_view} = 'JSON';
}


=head2 default

Standard 404 error page

=cut

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

Nito,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
