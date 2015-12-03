package QVD::DB::Result::Property_List;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('properties_list');
__PACKAGE__->add_columns(
	id          => { data_type => 'integer', is_auto_increment => 1 },
			  key   => { data_type => 'varchar(1024)' },
			  tenant_id  => { data_type         => 'integer' },
	description => { data_type => 'varchar(1024)', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['key', 'tenant_id']);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_many(properties => 'QVD::DB::Result::QVD_Object_Property_List', 'property_id', { cascade_delete => 1 });

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

sub description 
{
    my $self = shift;
    $self->description;
}

sub in_user 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('QVD_Object_Property_List')->search({property_id=>$args->id, qvd_object=>'user'})->all;
}

sub in_vm 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('QVD_Object_Property_List')->search({property_id=>$args->id, qvd_object=>'vm'})->all;
}

sub in_host 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('QVD_Object_Property_List')->search({property_id=>$args->id, qvd_object=>'host'})->all;
}

sub in_osf 
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('QVD_Object_Property_List')->search({property_id=>$args->id, qvd_object=>'osf'})->all;
}

sub in_di
{ 
    my $args = shift; 
    my $DB = QVD::DB::Simple::db();

    $DB->resultset('QVD_Object_Property_List')->search({property_id=>$args->id, qvd_object=>'di'})->all;
}

1;
