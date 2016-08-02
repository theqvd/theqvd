
package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
	id          => { data_type => 'integer', is_auto_increment => 1 },
	description => { data_type => 'varchar(32768)', is_nullable => 1 },
			  tenant_id  => { data_type         => 'integer' },
			  login      => { data_type         => 'varchar(64)' },
	blocked     => { data_type => 'boolean', default_value => 0 },
                          # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
	password    => { data_type  => 'varchar(64)', is_nullable => 1 },
    language    => { data_type  => 'language_enum', default_value => 'default' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login', 'tenant_id']);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::User_Property', 'user_id', {join_type => 'LEFT', order_by => {'-asc' => 'property_id'}});
__PACKAGE__->might_have(workspaces => 'QVD::DB::Result::Workspace', 'user_id');
__PACKAGE__->might_have(token => 'QVD::DB::Result::User_Token', 'user_id');
__PACKAGE__->has_one(connection => 'QVD::DB::Result::User_Connection', 'id');

######### FOR LOG ###########################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

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

####### TRIGGERS ############################################################################

sub get_procedures
{
	my @procedures_array = ();

	# Define procedures to listen and notify
	my @notify_procs_array = (
		{
			name => 'user_blocked_or_unblocked_notify',
			sql  => '$function$ BEGIN listen user_blocked_or_unblocked; PERFORM pg_notify(\'user_blocked_or_unblocked\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'user_changed_notify',
			sql  => '$function$ BEGIN listen user_changed; PERFORM pg_notify(\'user_changed\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'user_created_notify',
			sql  => '$function$ BEGIN listen user_created; PERFORM pg_notify(\'user_created\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'user_deleted_notify',
			sql  => '$function$ BEGIN listen user_deleted; PERFORM pg_notify(\'user_deleted\', \'tenant_id=\' || OLD.tenant_id::text); RETURN NULL; END; $function$',
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
			name => 'user_blocked_or_unblocked_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [qw/blocked/],
			on_table  => 'users',
			condition => undef,
			procedure => 'user_blocked_or_unblocked_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'user_changed_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [],
			on_table  => 'users',
			condition => undef,
			procedure => 'user_changed_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'user_created_trigger',
			when => 'AFTER',
			events => [qw/INSERT/],
			fields    => [],
			on_table  => 'users',
			condition => undef,
			procedure => 'user_created_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'user_deleted_trigger',
			when => 'AFTER',
			events => [qw/DELETE/],
			fields    => [],
			on_table  => 'users',
			condition => undef,
			procedure => 'user_deleted_notify',
			parameters => [],
			scope  => 'ROW',
		},
	);

	push @triggers_array, @notify_triggers_array;

	return @triggers_array;
}

#############################################################################################


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

sub name 
{
    my $self = shift;
    $self->login;
}

1;
