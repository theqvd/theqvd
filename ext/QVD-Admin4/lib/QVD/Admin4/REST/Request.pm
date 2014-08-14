package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moose;
use QVD::Admin4::Exception;

has 'db',        is => 'ro', isa => 'QVD::DB',     required => 1;
has 'json',      is => 'ro', isa => 'HashRef',     required => 1;
has 'config',    is => 'ro', isa => 'HashRef',     required => 1;
has 'mapper',    is => 'ro', isa => 'Config::Properties';
has 'free',      is => 'ro', isa => 'HashRef',     default => sub { {}; };
has 'modifiers', is => 'ro', isa => 'HashRef',     default => sub { {}; };
has 'dependencies', is => 'ro', isa => 'HashRef',  default => sub { {}; };
has 'customs',   is => 'ro', isa => 'ArrayRef',    default => sub { []; };

sub BUILD
{
    my $self = shift;

    $self->json->{filters} //= {};

    $self->config->{arguments} //= {};

    $self->config->{filters} //= {};
    $self->config->{mandatory} //= {};
    $self->config->{free} //= {};
    $self->config->{order_by} //= {};
    $self->config->{default} //= {};

    $self->json->{tenant} || 
	QVD::Admin4::Exception->throw(code => 6);

    $self->json->{role} || 
	QVD::Admin4::Exception->throw(code => 7);

    QVD::Admin4::Exception->throw(code => 8)
	unless (exists $self->config->{roles}->{$self->json->{role}} ||
		exists $self->config->{roles}->{'all'});

    $self->json->{filters}->{tenant} = $self->json->{tenant}
    if exists $self->config->{filters}->{tenant};

    $self->modifiers->{page} = $self->json->{offset} // 1; 
    $self->modifiers->{rows}  = $self->json->{block} // 10000; 
    $self->modifiers->{distinct} = 1;
}

sub action 
{
    my $self = shift;
    $self->json->{action};
}

sub table 
{
    my $self = shift;
    $self->config->{table};
}

sub filters 
{
    my $self = shift;
    my $filters = {};

    for (keys %{$self->json->{filters}})
    {
	QVD::Admin4::Exception->throw(code => 9)
	    unless exists $self->config->{filters}->{$_};
    }

    for (keys %{$self->config->{mandatory}})
    {
	QVD::Admin4::Exception->throw(code => 10)
	    unless exists $self->json->{filters}->{$_};
    }	

    for my $filter (keys %{$self->json->{filters}})
    {
	my $mfil = $self->mapper->getProperty($filter) // 
	QVD::Admin4::Exception->throw(code => 11);
		
	if ($self->config->{free}->{$filter})
	{
	    $filters->{$mfil} = { like => "%".$self->json->{filters}->{$filter}."%"};
	}
	else
	{
	    $filters->{$mfil} = $self->json->{filters}->{$filter};
	}
    }
    $filters;
}

sub arguments 
{
    my $self = shift;
    my %modifiers = @_;
    my $arguments = {};

    return ($self->json->{arguments}->{properties} || {}) 
	if $modifiers{custom};

     exists $self->config->{arguments}->{$_} ||
	 $_ eq 'properties'                  ||
	QVD::Admin4::Exception->throw(code => 12)
        for keys %{$self->json->{arguments}};


    for my $argument (keys %{$self->json->{arguments}})
    {
	next if $argument eq 'properties';
        my $marg = $self->mapper->getProperty($argument) //
	    QVD::Admin4::Exception->throw(code => 13);

        my ($table,$column) = $marg =~ /^(.+)\.(.+)$/;

        if ($modifiers{related})
        {
            next if $table eq 'me';
            $arguments->{$table}->{$column} =
                $self->json->{arguments}->{$argument};
        }
        else
        {
            next unless $table eq 'me';
            $arguments->{$column} =
                $self->json->{arguments}->{$argument};
        }
    }

    if ($modifiers{default})
    {
	for my $argument (keys %{$self->config->{default}})
	{
	    my $marg = $self->mapper->getProperty($argument) //
		QVD::Admin4::Exception->throw(code => 13);
	    my ($table,$column) = $marg =~ /^(.+)\.(.+)$/;

	    if ($modifiers{related})
	    {
		next if $table eq 'me';
		$arguments->{$table}->{$column} //= $self->config->{default}->{$argument};
	    }
	    else
	    {
		next unless $table eq 'me';
		$arguments->{$column} //= $self->config->{default}->{$argument};
	    }
	}
    }

    $arguments;
}

sub order_by
{
    my $self = shift;
    $self->json->{order_by} || return;
    my $field = $self->json->{order_by}->{field} // return;
    my $order = $self->json->{order_by}->{order} // '-asc';

    $field = $self->mapper->getProperty($field) // 	    
	QVD::Admin4::Exception->throw(code => 14);

    $self->modifiers->{order_by} = {$order => $field};
}

sub get_customs
{
    my ($self,$table) = @_;
    my $n = 1;
    $self->{customs} = [keys %{{map {$_->key => 1 } $self->db->resultset($table)->all}}];
    for (@{$self->customs})
    {
	if (exists $self->json->{arguments}->{$_} ||
	    exists $self->json->{filters}->{$_} ||
	    (exists $self->json->{order_by}->{field} &&
	     $self->json->{order_by}->{field} eq $_))
	{ 
	    my $pr = $n eq '1' ? "properties" : "properties_$n";	   
	    $self->modifiers->{join} //= [];
	    push @{$self->modifiers->{join}}, 'properties';

	    $self->{mapper} //= Config::Properties->new();
	    $self->mapper->setProperty("$pr.key","$pr.key");
	    $self->mapper->setProperty("$pr.value","$pr.value");

	    if (exists $self->json->{filters}->{$_})
	    {
		$self->json->{filters}->{"$pr.key"} = $_;
		$self->json->{filters}->{"$pr.value"} = { like => "%".$self->json->{filters}->{$_}."%" };
		delete $self->json->{filters}->{$_};
		@{$self->config->{filters}}{"$pr.key","$pr.value"} = qw(1 1);
	    }

	    if (exists $self->json->{arguments}->{$_})
	    {
		$self->json->{arguments}->{"$pr.key"} = $_;
		$self->json->{arguments}->{"$pr.value"} = $self->json->{arguments}->{$_};
		delete $self->json->{arguments}->{$_};
		@{$self->config->{arguments}}{"$pr.key","$pr.value"} = qw(1 1);
	    }

	    if (exists $self->json->{order_by}->{field} &&
		$self->json->{order_by}->{field} eq $_)
	    {
		$ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION} = $_;
		$self->json->{order_by}->{field} = "$pr.value";
	    }

	    $n++;
	}
   }
}

sub default_system
{
    my $self = shift;

    my $SYSTEM = delete $self->{config}->{default}->{SYSTEM} // {};

    while (my ($default,$method) = each %$SYSTEM)
    {
	$self->{config}->{default}->{$default} = $self->$method;
    }
}

1;
