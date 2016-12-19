package QVD::DB::Result::Host;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('hosts');
__PACKAGE__->add_columns(
	id       => { data_type => 'integer', is_auto_increment => 1 },
                          name     => { data_type => 'varchar(127)' },
	description => { data_type => 'varchar(32768)', is_nullable => 1 },
                          address  => { data_type => 'varchar(127)' },
			  frontend => { data_type => 'boolean' },
			  backend  => { data_type => 'boolean' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(['address']);

__PACKAGE__->has_many(properties => 'QVD::DB::Result::Host_Property', 'host_id', {join_type => 'LEFT', order_by => {'-asc' => 'property_id'}});
__PACKAGE__->has_many(vms        => 'QVD::DB::Result::VM_Runtime',    'host_id',  { cascade_delete => 0 });
__PACKAGE__->has_many(vm_l7rs    => 'QVD::DB::Result::VM_Runtime',    'l7r_host_id', { cascade_delete => 0 }); 
__PACKAGE__->has_one (runtime    => 'QVD::DB::Result::Host_Runtime',  'host_id');
__PACKAGE__->has_one (counters   => 'QVD::DB::Result::Host_Counter',  'host_id');

######### FOR LOG ##################################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
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

####### TRIGGERS ############################################################################

sub get_procedures
{
	my @procedures_array = ();

	# Define procedures to listen and notify
	my @notify_procs_array = (
		{
			name => 'host_blocked_or_unblocked_notify',
			sql  => '$function$ BEGIN listen host_blocked_or_unblocked; notify host_blocked_or_unblocked; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'host_changed_notify',
			sql  => '$function$ BEGIN listen host_changed; notify host_changed; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'host_created_notify',
			sql  => '$function$ BEGIN listen host_created; notify host_created; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'host_deleted_notify',
			sql  => '$function$ BEGIN listen host_deleted; notify host_deleted; RETURN NULL; END; $function$',
			parameters => [],
		},
	);

	for my $proc (@notify_procs_array){
		$proc->{replace} = 1;
		$proc->{language} = 'plpgsql';
		$proc->{returns} = 'trigger';
	}

	push @procedures_array, @notify_procs_array;

	# Return all procedures
	return @procedures_array;
}

sub get_triggers
{
	my @triggers_array = ();

	my @notify_triggers_array = (
		{
			name => 'host_blocked_or_unblocked_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [qw/blocked/],
			on_table  => 'host_runtimes',
			condition => undef,
			procedure => 'host_blocked_or_unblocked_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'host_runtime_changed_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [qw/state/],
			on_table  => 'host_runtimes',
			condition => undef,
			procedure => 'host_changed_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'host_changed_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [],
			on_table  => 'hosts',
			condition => undef,
			procedure => 'host_changed_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'host_created_trigger',
			when => 'AFTER',
			events => [qw/INSERT/],
			fields    => [],
			on_table  => 'hosts',
			condition => undef,
			procedure => 'host_created_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'host_deleted_trigger',
			when => 'AFTER',
			events => [qw/DELETE/],
			fields    => [],
			on_table  => 'hosts',
			condition => undef,
			procedure => 'host_deleted_notify',
			parameters => [],
			scope  => 'ROW',
		},
	);

	push @triggers_array, @notify_triggers_array;

	return @triggers_array;
}

#####################################################################################################


sub load { return undef; }

sub vms_connected 
{ 
    my $self = shift;
    my $count = 0;
    for my $vm ($self->vms->all)
    {
		$count++ if ($vm->user_state && $vm->user_state eq 'connected');
    }
    $count;
}

sub vms_count 
{ 
    my $self = shift;
    $self->vms->count;
}


1;
