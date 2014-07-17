package QVD::Admin4::REST;
use strict;
use warnings;
use Moose;
use QVD::Admin4;
use QVD::Admin4::REST::Request;
use QVD::Admin4::REST::Response;

my $QVD_ADMIN;

sub _auth
{
    my ($self,$json) = @_;

    unless ($QVD_ADMIN)
    {
	my %creds = map { $_ => $json->{$_} } qw(user database host password);
	eval { $QVD_ADMIN = QVD::Admin4->new(%creds) };
    }

    QVD::Admin4::REST::Response->new(status => ($@ ? 401 : 0))->json;
}

sub _admin
{
   my ($self,$json) = @_;

   my $request = QVD::Admin4::REST::Request->new(json => $json);

   my $rows = eval { my $action = $request->action;
		     my $table = $request->table;
		     my $filters = $request->filters; 
		     my $arguments = $request->arguments; 
		     [$QVD_ADMIN->action($table,$action,$filters,$arguments)] } // [];

   my $response = QVD::Admin4::REST::Response->new(message    => ($@ ? "$@" : ""),
                                                   status     => ($@ ? 1 : 0),
                                                   rows       => $rows )->json;
}



1;
