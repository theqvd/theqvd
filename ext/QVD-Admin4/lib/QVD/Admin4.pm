package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::Admin4::Query;
use Config::Properties;

our $VERSION = '0.01';

has 'database', is => 'ro', isa => 'Str', required => 1;
has 'user', is => 'ro', isa => 'Str', required => 1;
has 'host', is => 'ro', isa => 'Str', required => 1;
has 'password', is => 'ro', isa => 'Str', required => 1;

my $DB;

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB->new(database => $self->database,
		       user     => $self->user,
		       host     => $self->host,
		       password => $self->password) // 
			   die "Unknown database account";
}

sub _exec
{
    my ($self, $query) = @_;
    my $rows;

    if ($query->filter)
    { 
	my $filter = $query->filter;
	$rows = $self->$filter($query->request);
    }	

    my $action = $query->action;
    $rows = $self->$action($query->request,$rows);
}

###############################
########### ACTIONS  ##########
###############################

### BASIC SQL QUERIES
 
sub select
{
    my ($self,$request) = @_;
   
    my $page = delete $request->modifiers->{page};

    [$DB->resultset($request->table)->search($request->filters, 
					     $request->modifiers)->page($page)->all];
}

sub update
{  
    my ($self,$request,$rows) = @_;  

    [ map { $_->update($request->arguments) } @$rows ]; 
}

sub add
{
    my ($self,$request) = @_;  
     
   [ $DB->resultset($request->table)->create($request->arguments) ]; 
}

sub delete 
{  
    my ($self,$request,$rows) = @_;  

    [ map { $_->delete }  @$rows ];
}

### RELATIONS BETWEEN TABLES

sub relation     
{  
    my ($self,$request,$rows) = @_;  
    my $relation = $request->arguments->{'relation'} // 
	die "No relation specified";

    [ map { $_->$relation } @$rows ]; 
}

### RETRIEVES THE VALUE OF AN SPECIFIC COLUMN

sub property    
{  
    my ($self,$request,$rows) = @_;  
    my $property = $request->arguments->{'property'} // 
	die "No property specified";

    [ map { {$property => $_->$property} } @$rows ]; 
}

sub get_columns
{
    my ($self,$request,$rows) = @_;

    [map { {$_->get_columns} } @$rows];
}


sub collapse
{
    my ($self,$request,$rows) = @_;
    my $relations = $request->arguments->{'relations'} // {}; 

    my @result; 

    for my $row (@$rows)
    {
	my $result = {$row->get_columns};

	while (my ($table, $columns) = each %$relations)
	{ 
	    for my $obj ($row->$table)
	    {
		$result->{$table} //= []; 
		push @{$result->{$table}}, { map { $_ => $obj->$_ } @$columns };
	    }
	}
	
	push @result, $result;
    }

    use Data::Dumper; print Dumper [@result];

    [ @result ];
}

1;
