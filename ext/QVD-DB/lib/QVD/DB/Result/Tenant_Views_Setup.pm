package QVD::DB::Result::Tenant_Views_Setup;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('tenant_views_setups');
__PACKAGE__->add_columns(
	id          => { data_type => 'integer', is_auto_increment => 1 },
                         field  => { data_type => 'varchar(64)' },
			 tenant_id  => { data_type => 'integer' },
                         visible  => { data_type => 'boolean' },
	view_type   => { data_type => 'administrator_and_tenant_views_setups_view_type_enum' },
	device_type => { data_type => 'administrator_and_tenant_views_setups_device_type_enum' },
	qvd_object  => { data_type => 'administrator_and_tenant_views_setups_qvd_object_enum'},
	property    => { data_type => 'boolean'},
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(tenant_id field view_type device_type qvd_object property)]);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant', 'tenant_id');

sub tenant_id
{
    my $self = shift;
    $self->tenant->id;
}

sub tenant_name
{
    my $self = shift;
    $self->tenant->name;
}

1;
