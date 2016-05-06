package QVD::DB::Result::Config;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('configs');
__PACKAGE__->add_columns( tenant_id => { data_type => 'integer' },
                          key => { data_type => 'varchar(64)' },
                          value => { data_type => 'varchar(4096)' } );

__PACKAGE__->set_primary_key(qw(tenant_id key));
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant', 'tenant_id', { cascade_delete => 0 });

####### TRIGGERS ############################################################################

sub get_procedures
{
    my @procedures_array = ();

    # Define procedures to listen and notify
    my @notify_procs_array = (
        {
            name => 'config_changed_notify',
            sql  => '$function$ BEGIN listen qvd_config_changed; PERFORM pg_notify(\'qvd_config_changed\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
            parameters => [],
        },
        {
            name => 'config_created_notify',
            sql  => '$function$ BEGIN listen qvd_config_changed; PERFORM pg_notify(\'qvd_config_changed\', \'tenant_id=\' || NEW.tenant_id::text); RETURN NULL; END; $function$',
            parameters => [],
        },
        {
            name => 'config_deleted_notify',
            sql  => '$function$ BEGIN listen qvd_config_changed; PERFORM pg_notify(\'qvd_config_changed\', \'tenant_id=\' || OLD.tenant_id::text); RETURN NULL; END; $function$',
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
            name => 'config_changed_trigger',
            when => 'AFTER',
            events => [qw/UPDATE/],
            fields    => [],
            on_table  => 'configs',
            condition => undef,
            procedure => 'config_changed_notify',
            parameters => [],
            scope  => 'ROW',
        },
        {
            name => 'config_created_trigger',
            when => 'AFTER',
            events => [qw/INSERT/],
            fields    => [],
            on_table  => 'configs',
            condition => undef,
            procedure => 'config_created_notify',
            parameters => [],
            scope  => 'ROW',
        },
        {
            name => 'config_deleted_trigger',
            when => 'AFTER',
            events => [qw/DELETE/],
            fields    => [],
            on_table  => 'configs',
            condition => undef,
            procedure => 'config_deleted_notify',
            parameters => [],
            scope  => 'ROW',
        },
    );

    push @triggers_array, @notify_triggers_array;

    return @triggers_array;
}

1;