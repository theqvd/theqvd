package QVD::DB::Result::Role_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('role_views');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
WITH roles_with_inheritance AS
(
WITH inherited_roles_with_all_acls AS

 ( SELECT DISTINCT json_agg(a.name)::text as acls, r.* 
   FROM   all_acl_role_relations i JOIN roles r ON i.inheritor_id=r.id JOIN acls a ON i.acl_id=a.id 
   GROUP BY r.id
 )  

SELECT DISTINCT i.inheritor_id as id, json_agg(DISTINCT(r.*))::text AS roles_json, 
       json_agg(DISTINCT(pa.name))::text as positive_acls_json,
       json_agg(DISTINCT(na.name))::text as negative_acls_json
FROM inherited_roles_with_all_acls r 
JOIN role_role_relations i ON i.inherited_id=r.id
LEFT JOIN acl_role_relations pj ON i.inheritor_id=pj.role_id AND pj.positive='1'
LEFT JOIN acls pa ON pa.id=pj.acl_id
LEFT JOIN acl_role_relations nj ON i.inheritor_id=nj.role_id AND nj.positive='0'
LEFT JOIN acls na ON na.id=nj.acl_id

GROUP BY i.inheritor_id
)
SELECT r.id as id, 
       CASE WHEN (i.roles_json IS NULL) THEN '[]' ELSE i.roles_json END AS roles_json,
       CASE WHEN (i.positive_acls_json IS NULL) THEN '[]' ELSE i.positive_acls_json END AS positive_acls_json,
       CASE WHEN (i.negative_acls_json IS NULL) THEN '[]' ELSE i.negative_acls_json END AS negative_acls_json
FROM roles r LEFT JOIN roles_with_inheritance i ON i.id=r.id

"

);

__PACKAGE__->add_columns(

    id  => { data_type => 'integer' },
    roles_json  => { data_type => 'JSON' },
    positive_acls_json  => { data_type => 'JSON' },
    negative_acls_json  => { data_type => 'JSON' },
);

__PACKAGE__->set_primary_key( qw/ id / );



sub roles
{
    my $self = shift;
    return $self->{roles} if defined $self->{roles}; 
    my $roles = decode_json $self->roles_json;
    my $out = {};

    for my $role (@$roles)
    {
	my $id = delete $role->{id};
	my $acls = decode_json $role->{acls};
	my @acls = sort grep { defined $_ } @$acls;
	$role->{acls} = \@acls;
	$out->{$id} = $role;
    }

    $self->{roles} = $out;
}

sub acls
{
    my $self = shift;
    my $posotive_acls = decode_json $self->positive_acls_json;
    my $negative_acls = decode_json $self->negative_acls_json;
    my $out = { positive => [], negative => []};
    $out->{positive} = [ sort grep { defined $_ } @$posotive_acls  ];
    $out->{negative} = [ sort grep { defined $_ } @$negative_acls  ];
    $out; 
}

sub number_of_inherited_acls
{
    my $self = shift;
    my $roles = $self->roles;
    my %acls;

    while (my ($role_id,$role_info) = each %$roles)
    {
	@acls{@{$role_info->{acls}}} = @{$role_info->{acls}};
    }

    my @acls = keys %acls;
    my $acls = @acls;
}


sub number_of_acls
{
    my $self = shift;
    my $roles_with_its_acls = $self->acls_tree->get_roles_with_its_acls_info;
    my %acls;

    while (my ($role_id,$role_info) = each %$roles_with_its_acls)
    {
	@acls{@{$role_info->{acls}}} = @{$role_info->{acls}};
    }

    my @acls = keys %acls;
    my $acls = @acls;
}


1;
