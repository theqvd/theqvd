package QVD::DB::Result::DI;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('dis');
__PACKAGE__->add_columns(
	id          => { data_type => 'integer', is_auto_increment => 1 },
                          osf_id => { data_type => 'integer' },
	blocked     => { data_type => 'boolean', default_value => 0 },
	description => { data_type => 'varchar(32768)', is_nullable => 1},
	# Value taken from PATH_MAX variable defined in
                          # /usr/src/linux-headers-2.6.28-15/include/linux/limits.h:
                          path  => { data_type => 'varchar(4096)' },
                          version => { data_type => 'varchar(64)' },
 );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(osf => 'QVD::DB::Result::OSF', 'osf_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::DI_Property', 'di_id', {join_type => 'LEFT', order_by => {'-asc' => 'property_id'}});
__PACKAGE__->has_many(vm_runtimes => 'QVD::DB::Result::VM_Runtime', 'current_di_id', { cascade_delete => 0 });
__PACKAGE__->has_many(tags => 'QVD::DB::Result::DI_Tag', 'di_id', { order_by => { '-desc' => 'tag' }});

__PACKAGE__->add_unique_constraint(['osf_id', 'version']);

######### FOR LOG ########################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'di' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='di' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

####### TRIGGERS ############################################################################

sub get_procedures
{
	my @procedures_array = ();

	# Define procedures to listen and notify
	my @notify_procs_array = (
		{
			name => 'di_blocked_or_unblocked_notify',
			sql  => '$function$ BEGIN listen di_blocked_or_unblocked; notify di_blocked_or_unblocked; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'di_changed_notify',
			sql  => '$function$ BEGIN listen di_changed; notify di_changed; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'di_created_notify',
			sql  => '$function$ BEGIN listen di_created; notify di_created; RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'di_deleted_notify',
			sql  => '$function$ BEGIN listen di_deleted; notify di_deleted; RETURN NULL; END; $function$',
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
			name => 'di_blocked_or_unblocked_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [qw/blocked/],
			on_table  => 'dis',
			condition => undef,
			procedure => 'di_blocked_or_unblocked_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'di_changed_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [],
			on_table  => 'dis',
			condition => undef,
			procedure => 'di_changed_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'di_created_trigger',
			when => 'AFTER',
			events => [qw/INSERT/],
			fields    => [],
			on_table  => 'dis',
			condition => undef,
			procedure => 'di_created_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'di_deleted_trigger',
			when => 'AFTER',
			events => [qw/DELETE/],
			fields    => [],
			on_table  => 'dis',
			condition => undef,
			procedure => 'di_deleted_notify',
			parameters => [],
			scope  => 'ROW',
		},
	);

	push @triggers_array, @notify_triggers_array;

	return @triggers_array;
}

############################################################################################

sub tag_list {
    my $di = shift;
    sort (map $_->tag, $di->tags);
}

sub has_tag {
    my ($di, $tag) = @_;
    my $ditag = $di->tags->search({tag => $tag})->first;
    return !!$ditag;
}

sub delete_tag {
    my $di = shift;
    my $tag = shift;
    my $ditag = $di->tags->search({tag => $tag})->first;
    $ditag->delete if $ditag;
}

sub tags_get_columns
{
    my $self = shift;
    [ sort { $a->{tag} cmp $b->{tag} }
      map { { $_->get_columns } } $self->tags ];
}

sub tenant_id
{
    my $self = shift;
    $self->osf->tenant_id;
}

sub tenant_name
{
    my $self = shift;
    $self->osf->tenant->name;
}

sub tenant
{
    my $self = shift;
    $self->osf->tenant;
}


sub name
{
    my $self = shift;
    $self->path;
}

1;
