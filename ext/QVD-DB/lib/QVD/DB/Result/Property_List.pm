package QVD::DB::Result::Property_List;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('properties_list');
__PACKAGE__->add_columns( id   => { data_type => 'integer' },
			  key   => { data_type => 'varchar(1024)' },
			  tenant_id  => { data_type         => 'integer' },
                          description   => { data_type => 'varchar(1024)' } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->might_have(properties => 'QVD::DB::Result::Host_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::OSF_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::DI_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::User_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::VM_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_many(properties => 'QVD::DB::Result::OSF_Property', 'property_id', { cascade_delete => 0 });

sub tenant_name
{
    my $self = shift;
    $self->tenant->name;
}

sub property_id 
{
    my $self = shift;
    $self->id;
}

sub in_user 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('User_Property_List')->search({property_id=>$args->id})->all;
}

sub in_vm 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('VM_Property_List')->search({property_id=>$args->id})->all;
}

sub in_host 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('Host_Property_List')->search({property_id=>$args->id})->all;
}

sub in_osf 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('OSF_Property_List')->search({property_id=>$args->id})->all;
}

sub in_di
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('DI_Property_List')->search({property_id=>$args->id})->all;
}

1;
