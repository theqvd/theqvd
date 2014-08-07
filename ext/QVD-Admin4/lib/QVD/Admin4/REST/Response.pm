package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moose;

has 'status',  is => 'ro', isa => 'Int', required => 1;
has 'result', is => 'ro', isa => 'HashRef', default => sub {{};};
has 'failures', is => 'ro', isa => 'HashRef', default => sub {{};};

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;
    
    while (my ($id, $code) = each %{$self->failures})
    {
	$self->failures->{$id} = $self->message($code);
	$self->{status} = 1;
    }
}

sub message
{
    my $self = shift;
    my $status = shift // $self->status;
    $mapper->getProperty($status) || 
	'No translation to code '.$status.': ask Batman...';
}

sub json
{
    my $self = shift;
    
   { status  => $self->status,
     message => $self->message,
     result  => $self->result,
     failures  => $self->failures};
}


1;

__DATA__

0 = Successful completion.
1 = Undefined error.
2 = Unable to connect to database.
3 = Unable to log in in database.
4 = Internal server error.
5 = Action non supported.
6 = Unable to assign tenant to user: permissions problem.
7 = Unable to assign role to user: permissions problem.
8 = Forbidden action for this user.
9 = Inappropiate filter for this action.
10 = No mandatory filter for this action.
11 = Unknown filter for this action.
12 = Innapropiate argument for this action
13 = Unknown argument for this action.
14 = Unknown order element.
15 = Syntax errors in input json.
23503 = Foreign Key violation.
23505 = Unique Key violation.

