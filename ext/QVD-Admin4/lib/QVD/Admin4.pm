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
    my $result;

    if ($query->filter)
    { 
	my $filter = $query->filter;
	$result = $self->$filter($query->request);
    }	

    my $action = $query->action;

    $result = $self->$action($query->request,$result);

    $result;
}

###############################
########### ACTIONS  ##########
###############################

### BASIC SQL QUERIES

sub select
{
    my ($self,$request) = @_;

    my $rs = $DB->resultset($request->table)->search($request->filters,
						     $request->modifiers);

    { total => ($rs->is_paged ? $rs->pager->total_entries : undef), 
      rows => [$rs->all]} ;
}

sub update
{  
    my ($self,$request,$result) = @_;  

    my $rows = $result->{rows};
    $result->{rows} = [ map { {$_->update($request->arguments)->get_columns} } @$rows ]; 
    $result;
}

sub add
{
    my ($self,$request) = @_;  
     
    { total => 1, rows => [ $DB->resultset($request->table)->create($request->arguments) ]}; 
}

sub delete 
{  
    my ($self,$request,$result) = @_;  
    my $rows = $result->{rows};
    $result->{rows} = [ map { $_->delete }  @$rows ];
    $result;
}

### RELATIONS BETWEEN TABLES

sub relation     
{  
    my ($self,$request,$result) = @_;  
    my $relation = $request->arguments->{'relation'} // 
	die "No relation specified";
    my $rows = $result->{rows};
    $result->{rows} = [ map { {$_->$relation->get_columns} } @$rows ]; 
    $result;
}

### RETRIEVES THE VALUE OF AN SPECIFIC COLUMN

sub property    
{  
    my ($self,$request,$result) = @_;  
    my $property = $request->arguments->{'property'} // 
	die "No property specified";
    my $rows = $result->{rows};
    $result->{rows} = [ map { {$property => $_->$property} } @$rows ]; 
    $result;
}

sub empty
{
    [];
}

sub get_columns
{
    my ($self,$request,$result) = @_;
    my $rows = $result->{rows};
    $result->{rows} = [map { {$_->get_columns} } @$rows];
    $result;
}

sub count
{
    my ($self,$request,$result) = @_;
    $result->{rows} = [];
    $result;
}

sub collapse
{
    my ($self,$request,$result) = @_;
    my $relations = $request->arguments->{'relations'} // {}; 
    my $rows = $result->{rows};
    my @nrows; 

    for my $row (@$rows)
    {
	my $nrows = {$row->get_columns};

	while (my ($table, $columns) = each %$relations)
	{ 
	        for my $obj ($row->$table)
		{
		    $nrows->{$table} //= []; 
		    push @{$nrows->{$table}}, { map { $_ => $obj->$_ } @$columns };
		}
	}
	
	push @nrows, $nrows;
    }

    $result->{rows} = [ @nrows ];
    $result;
}


1;
