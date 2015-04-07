package QVD::DB::Result::Host;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('hosts');
__PACKAGE__->add_columns( id       => { data_type => 'integer',
                                       is_auto_increment => 1 },
                          name     => { data_type => 'varchar(127)' },
                          address  => { data_type => 'varchar(127)' },
			  frontend => { data_type => 'boolean' },
			  backend  => { data_type => 'boolean' },
 );

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(['address']);

__PACKAGE__->has_many(properties => 'QVD::DB::Result::Host_Property', \&custom_join_condition, 
		      {join_type => 'LEFT', order_by => {'-asc' => 'key'}});
__PACKAGE__->has_many(vms        => 'QVD::DB::Result::VM_Runtime',    'host_id',  { cascade_delete => 0 });
__PACKAGE__->has_many(vm_l7rs    => 'QVD::DB::Result::VM_Runtime',    'l7r_host_id', { cascade_delete => 0 }); #FIXME COMMENTED BECAUSE TRIGGERS ERROR WHEN ASKING DB
__PACKAGE__->has_one (runtime    => 'QVD::DB::Result::Host_Runtime',  'host_id');
__PACKAGE__->has_one (counters   => 'QVD::DB::Result::Host_Counter',  'host_id');

######### Log info

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'host' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='host' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

###################


sub load { return undef; }
sub creation_admin { return undef; }
sub creation_date { return undef; }
sub vms_connected 
{ 
    my $self = shift;
    my $count = 0;
    for my $vm ($self->vms->all)
    {
	$count++ if ($vm->user_state &&
		     $vm->user_state eq 'connected');
    }
    $count;
}

sub vms_count 
{ 
    my $self = shift;
    $self->vms->count;
}

sub custom_join_condition
{ 
    my $args = shift; 
    my $key = $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION};

    { "$args->{foreign_alias}.host_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.key"     => ($key ? { '=' => $key } : { -ident => "$args->{foreign_alias}.key"}) };
}


sub get_properties_key_value
{
    my $self = shift;

    ( properties => { map {  $_->key => $_->value  } $self->properties->all });
} 

1;
