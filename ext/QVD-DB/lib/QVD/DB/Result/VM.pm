package QVD::DB::Result::VM;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vms');
__PACKAGE__->add_columns( id      => { data_type         => 'integer',
				       is_auto_increment => 1 },
			  name    => { data_type         => 'varchar(64)' },
			  user_id => { data_type         => 'integer' },
			  osf_id  => { data_type         => 'integer' },
                          di_tag  => { data_type         => 'varchar(128)' },
			  ip      => { data_type         => 'varchar(15)',
				       is_nullable       => 1 },
			  storage => { data_type         => 'varchar(4096)',
				       is_nullable       => 1 } );
__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(['ip']);

__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id', { cascade_delete => 0 });
__PACKAGE__->belongs_to(osf  => 'QVD::DB::Result::OSF',  'osf_id',  { cascade_delete => 0 });

__PACKAGE__->has_one (vm_runtime => 'QVD::DB::Result::VM_Runtime',  'vm_id');
__PACKAGE__->has_one (counters   => 'QVD::DB::Result::VM_Counter',  'vm_id');
__PACKAGE__->has_many(properties => 'QVD::DB::Result::VM_Property', 'vm_id');

sub combined_properties {
    my $vm = shift;

    my $current_di = $vm->vm_runtime->current_di;

    map { $_->key, $_->value } ( $vm->osf->properties,
                                 ($current_di ? $current_di->properties : ()),
				 $vm->user->properties,
				 $vm->properties );
}

__PACKAGE__->belongs_to(di => 'QVD::DB::Result::DI',
			sub {
  			  my $args = shift;
 			  my $in = <<EOIN;
 IN ( SELECT dis.id from dis, di_tags
       WHERE di_tags.di_id = dis.id
         AND di_tags.tag = $args->{self_alias}.di_tag )
EOIN
  			  return { "$args->{foreign_alias}.osf_id" => {-ident => "$args->{self_alias}.osf_id"},
				   "$args->{foreign_alias}.id" => \$in };
			});

1;
