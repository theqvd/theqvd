package QVD::DB::Result::Wat_Log;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('wat_log');


__PACKAGE__->add_columns( id                      => { data_type => 'integer', 
						       is_auto_increment => 1 },
                          administrator_id        => { data_type => 'integer', is_nullable => 1 },
                          administrator_name      => { data_type => 'varchar(80)', is_nullable => 1 },
                          tenant_id               => { data_type => 'integer' },
                          tenant_name             => { data_type => 'varchar(80)' },
                          action                  => { data_type => 'varchar(80)' },
                          type_of_action          => { data_type => 'varchar(80)',       
						              is_enum     => 1,
						       extra       => { list => [qw(vm user osf di host tenant admin role acl config tenant_view admin_view)] } },
                          arguments               => { data_type => 'text', is_nullable => 1 },
                          qvd_object              => { data_type => 'varchar(80)',
						       is_enum     => 1,
						       extra       => { list => [qw(create delete update exec)] } },
                          object_id               => { data_type => 'integer', is_nullable => 1 },
                          object_name             => { data_type => 'varchar(80)', is_nullable => 1 },
                          time                    => { data_type => 'timestamp' },
                          status                  => { data_type => 'integer' },
                          source                  => { data_type => 'varchar(80)', is_nullable => 1 },
                          ip                      => { data_type => 'varchar(80)', is_nullable => 1 },
                          superadmin              => { data_type => 'boolean', is_nullable => 1 },
    );

__PACKAGE__->set_primary_key('id');


sub antiquity
{
    my $self = shift;
    my $time = $self->time;

    $time =~ /^(?<year>[0-9]+)-(?<month>[0-9]+)-(?<day>[0-9]+) (?<hour>[0-9]+):(?<minutes>[0-9]+):(?<seconds>[0-9]+)$/;
    my %time = %+;
    return \%time;
}

1;
