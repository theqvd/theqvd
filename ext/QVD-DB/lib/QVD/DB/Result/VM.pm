package QVD::DB::Result::VM;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vms');
__PACKAGE__->add_columns( 
			  id      => { data_type         => 'integer',
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
__PACKAGE__->has_many(properties => 'QVD::DB::Result::VM_Property', \&custom_join_condition, 
		      {join_type => 'LEFT', order_by => {'-asc' => 'key'}});

sub combined_properties {
    my $vm = shift;

    my $current_di = $vm->vm_runtime->current_di;

    map { $_->key, $_->value } ( $vm->osf->properties,
                                 ($current_di ? $current_di->properties : ()),
				 $vm->user->properties,
				 $vm->properties );
}

sub di {
    my $self = shift;
    my $tag = eval { $self->di_tag } // 'default';
    #warn "tag: $tag";
    $self->osf->di_by_tag($tag);
}

sub get_has_many { qw(properties); }
sub get_has_one { qw(vm_runtime counters); }
sub get_belongs_to { qw(user osf); }

sub custom_join_condition
{ 
    my $args = shift; 
    my $key = $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION};

    { "$args->{foreign_alias}.vm_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.key"     => ($key ? { '=' => $key } : { -ident => "$args->{foreign_alias}.key"}) };
}

1;
