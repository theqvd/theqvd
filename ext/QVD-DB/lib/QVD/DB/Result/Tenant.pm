package QVD::DB::Result::Tenant;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('tenants');
__PACKAGE__->add_columns( id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                          name        => { data_type => 'varchar(80)' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(users => 'QVD::DB::Result::User', 'tenant_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(osfs => 'QVD::DB::Result::OSF', 'tenant_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(views => 'QVD::DB::Result::Tenant_Views_Setup', 'tenant_id');
__PACKAGE__->has_one (wat_setups   => 'QVD::DB::Result::Wat_Setups_By_Tenant',  'tenant_id');


######### FOR LOG #############################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'tenant' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='tenant' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}


###############################################################################################

1;
