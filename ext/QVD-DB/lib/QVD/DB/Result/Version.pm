package QVD::DB::Result::Version;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('versions');
__PACKAGE__->add_columns( component => { data_type => 'varchar(100)' },
                          version   => { data_type => 'varchar(100)' } );
__PACKAGE__->set_primary_key('component');

sub get_has_many { qw(); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(); }


1;
