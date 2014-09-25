package QVD::Admin4::DBConfigProvider;
use strict;
use warnings;
use Moose;

my $DB;

sub BUILD 
{
    my $self = shift;
    $DB = QVD::DB->new();
}

sub db {  $DB;  }

sub get_custom_properties_keys
{
    my ($self,$qvd_object_table) = @_;
    my $properties_table = $qvd_object_table."_Property";
    my @properties_keys;
    
    eval { my %properties_keys = map {$_->key => 1 } 
	   $self->db->resultset($properties_table)->search()->all;
	   @properties_keys = keys %properties_keys };

    @properties_keys;
}

1;
