package QVD::DB::Result::DI;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('dis');
__PACKAGE__->add_columns( id     => { data_type => 'integer',
                                      is_auto_increment => 1 },
                          osf_id => { data_type => 'integer' },

                          # Valor tomado de la variable PATH_MAX de
                          # /usr/src/linux-headers-2.6.28-15/include/linux/limits.h:

                          # TODO: rename "path" as "file"
                          path  => { data_type => 'varchar(4096)' },
                          version => { data_type => 'varchar(64)' } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(osf => 'QVD::DB::Result::OSF', 'osf_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::DI_Property',
                      'di_id', { join_type => 'INNER' });

__PACKAGE__->has_many(vm_runtimes => 'QVD::DB::Result::VM_Runtime', 'current_di_id', { cascade_delete => 0 });
__PACKAGE__->has_many(tags => 'QVD::DB::Result::DI_Tag', 'di_id');

__PACKAGE__->add_unique_constraint(['osf_id', 'version']);

sub tag_list {
    my $di = shift;
    sort (map $_->tag, $di->tags);
}

sub has_tag {
    my ($di, $tag) = @_;
    my $ditag = $di->tags->search({tag => $tag})->first;
    return !!$ditag;
}

sub delete_tag {
    my $di = shift;
    my $tag = shift;
    my $ditag = $di->tags->search({tag => $tag})->first;
    $ditag->delete if $ditag;
}
sub get_has_many { qw(properties tags vm_runtimes); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(osf); }



1;
