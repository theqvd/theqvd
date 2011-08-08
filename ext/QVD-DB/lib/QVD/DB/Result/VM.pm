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

__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');
__PACKAGE__->belongs_to(osf  => 'QVD::DB::Result::OSF',  'osf_id' );

__PACKAGE__->has_one (vm_runtime => 'QVD::DB::Result::VM_Runtime',  'vm_id');
__PACKAGE__->has_many(properties => 'QVD::DB::Result::VM_Property', 'vm_id');

__PACKAGE__->has_many(dis => 'QVD::DB::Result::DI', { 'foreign.tags.tag' => 'self.di_tag',
                                                      'foreign.osf_id' => 'self.osf_id' });

## perl -Mlib::glob=*/lib QVD-Admin/bin/qvd-admin.pl vm del -f id=1
## Error: DBI Exception: DBD::Pg::st execute failed: ERROR:  missing FROM-clause entry for table "di_tags"
## LINE 1: ...."path", "me"."version" FROM "dis" "me" WHERE ( ( "di_tags"....
##                                                              ^ [for Statement "SELECT "me"."id", "me"."osf_id", "me"."path", "me"."version" FROM "dis" "me" WHERE ( ( "di_tags"."tag" = ? AND "me"."osf_id" = ? ) )"

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
    warn "tag: $tag";
    $self->osf->di_by_tag($tag);
}

1;
