package QVD::DB::Result::OSF;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osfs');
__PACKAGE__->add_columns(
	tenant_id   => { data_type => 'integer' },
	id          => { data_type => 'integer', is_auto_increment => 1 },
                          name        => { data_type => 'varchar(64)' },
	description => { data_type => 'varchar(32768)', is_nullable => 1 },
	memory      => { data_type => 'integer' }, use_overlay => { data_type => 'boolean' },
	user_storage_size => { data_type => 'integer', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'osf_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::OSF_Property', 'osf_id', {join_type => 'LEFT', order_by => {'-asc' => 'property_id'}});
__PACKAGE__->has_many(dis => 'QVD::DB::Result::DI', 'osf_id', { cascade_delete => 0 } );


######### FOR LOG ############################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'osf' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='osf' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

####### TRIGGERS ############################################################################

sub get_procedures
{
	my @procedures_array = ();

	# Define procedures to listen and notify
	my @notify_procs_array = (
		{
			name => 'osf_changed_notify',
			sql  => '$function$ BEGIN listen osf_changed; PERFORM pg_notify(\'osf_changed\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'osf_created_notify',
			sql  => '$function$ BEGIN listen osf_created; PERFORM pg_notify(\'osf_created\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
			parameters => [],
		},
		{
			name => 'osf_deleted_notify',
			sql  => '$function$ BEGIN listen osf_deleted; PERFORM pg_notify(\'osf_deleted\', \'tenant_id=\' || OLD.tenant_id::text); RETURN NULL; END; $function$',
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
			name => 'osf_changed_trigger',
			when => 'AFTER',
			events => [qw/UPDATE/],
			fields    => [],
			on_table  => 'osfs',
			condition => undef,
			procedure => 'osf_changed_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'osf_created_trigger',
			when => 'AFTER',
			events => [qw/INSERT/],
			fields    => [],
			on_table  => 'osfs',
			condition => undef,
			procedure => 'osf_created_notify',
			parameters => [],
			scope  => 'ROW',
		},
		{
			name => 'osf_deleted_trigger',
			when => 'AFTER',
			events => [qw/DELETE/],
			fields    => [],
			on_table  => 'osfs',
			condition => undef,
			procedure => 'osf_deleted_notify',
			parameters => [],
			scope  => 'ROW',
		},
	);

	push @triggers_array, @notify_triggers_array;

	return @triggers_array;
}

##############################################################################################

sub _dis_by_tag {
    my ($osf, $tag, $fixed) = @_;

    my %search = ('tags.tag' => $tag);
    $search{'tags.fixed'} = $fixed if defined $fixed;
    $osf->dis->search(\%search, {join => 'tags'});
}

sub di_by_tag {
    my ($osf, $tag, $fixed) = @_;
    my $first = $osf->_dis_by_tag($tag, $fixed)->first;
    # warn "$osf->di_by_tag($tag, ".($fixed//'<undef>').") => ".($first//'<undef>');
    $first;
}

sub delete_tag {
    my ($osf, $tag) = @_;

    if (my $di = $osf->di_by_tag($tag, 0)) {

        $di->delete_tag($tag);
        # warn "$osf->delete_tag($tag) => $di";
        return 1;
    }
    # warn "$osf->delete_tag($tag) => <undef>";
    return 0;
}

sub vms_count
{
    my $self = shift;
    $self->vms->count;
}

sub dis_count
{
    my $self = shift;
    $self->dis->count;
}

sub tenant_name
{
    my $self = shift;
    $self->tenant->name;
}


1;
