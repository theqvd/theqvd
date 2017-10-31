package QVD::DB::Result::DI_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('di_runtimes');
__PACKAGE__->add_columns(
    di_id                => { data_type => 'integer' },
    state                => { data_type => 'di_generation_state_enum', default_value => 'new' },
    state_ts             => { data_type => 'integer', is_nullable => 1 },
    elapsed_time         => { data_type => 'integer', is_nullable => 1 },
    auto_publish         => { data_type => 'integer', default_value => 0 },
    foreign_id           => { data_type => 'integer', is_nullable => 1 },
    expiration_time_soft => { data_type => 'integer', is_nullable => 1 },
    expiration_time_hard => { data_type => 'integer', is_nullable => 1 },
    percentage           => { data_type => 'real', default_value => 0 },
    error_code           => { data_type => 'integer', is_nullable => 1 },
    status_message       => { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('di_id');
__PACKAGE__->belongs_to('di' => 'QVD::DB::Result::DI', 'di_id', { cascade_delete => 1 } );

####### TRIGGERS ############################################################################

sub get_procedures
{
    my @procedures_array = ();
    
    # Define procedures to listen and notify
    my @notify_procs_array = (
        {
            name => 'di_runtimes_changed_notify',
            sql  => '$function$ BEGIN listen di_changed; notify di_changed; RETURN NULL; END; $function$',
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
            name => 'di_runtimes_changed_trigger',
            when => 'AFTER',
            events => [qw/UPDATE/],
            fields    => [],
            on_table  => 'di_runtimes',
            condition => undef,
            procedure => 'di_runtimes_changed_notify',
            parameters => [],
            scope  => 'ROW',
        },
    );
    
    push @triggers_array, @notify_triggers_array;
    
    return @triggers_array;
}
