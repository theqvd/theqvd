
package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns( id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  tenant_id  => { data_type         => 'integer' },
			  login      => { data_type         => 'varchar(64)' },
                          blocked    => { data_type         => 'boolean',
                                          default_value     => 0 },
                          # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
			  password   => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login']);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::User_Property', \&custom_join_condition, 
		      {join_type => 'LEFT', order_by => {'-asc' => 'key'}});

__PACKAGE__->has_many(log_entries => 'QVD::DB::Result::Wat_Log', 'object_id', { cascade_delete => 0 } );

######### Log info

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});
__PACKAGE__->has_one(update_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&update_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'user' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='user' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

###################


sub BEGIN
{
    my $self = shift;
}

sub creation_admin
{ 
    my $self = shift;
    return undef;
}

sub creation_date
{ 
    my $self = shift;
    return undef;
}

sub vms_count
{
    my $self = shift;

    $self->vms->count;
}

sub vms_connected_count
{
    my $self = shift;
    my $count = 0;
    for my $vm ($self->vms->all)
    {
	$count++ if ($vm->vm_runtime->user_state &&
		     $vm->vm_runtime->user_state eq 'connected');
    }
    $count;
}

sub tenant_name

{
    my $self = shift;
    $self->tenant->name;
}

sub custom_join_condition
{ 
    my $args = shift; 
    my $key = $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION};

    { "$args->{foreign_alias}.user_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.key"     => ($key ? { '=' => $key } : { -ident => "$args->{foreign_alias}.key"}) };
}

sub get_properties_key_value
{
    my $self = shift;

    ( properties => { map {  $_->key => $_->value  } $self->properties->all });
} 


sub name 
{
    my $self = shift;
    $self->login;
}
1;
