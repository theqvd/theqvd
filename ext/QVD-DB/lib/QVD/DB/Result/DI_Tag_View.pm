package QVD::DB::Result::DI_Tag_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('dis_tags_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT me.id          as id, 
        json_agg(tags) as tags_json 

 FROM      dis me 
 LEFT JOIN di_tags tags ON(tags.di_id=me.id) 
 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

    'tags_json' => {
	data_type => 'JSON',
    },

    );


sub tags
{
    my $self = shift;

    my $tags = decode_json $self->tags_json;
    my $out = [ sort { $a->{tag} cmp $b->{tag} }  
		map { { id => $_->{id}, tag => $_->{tag}, fixed => $_->{fixed}  } } 
		@$tags ];
}
sub tags
{
    my $self = shift;

    my $tags = decode_json $self->tags_json;
    my $out = [ sort { $a->{tag} cmp $b->{tag} }  
		map { { id => $_->{id}, tag => $_->{tag}, fixed => $_->{fixed}  } } 
		@$tags ];
}

1;
