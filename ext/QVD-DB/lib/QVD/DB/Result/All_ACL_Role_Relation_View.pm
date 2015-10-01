package QVD::DB::Result::All_ACL_Role_Relation_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('all_acl_role_relations');
__PACKAGE__->result_source_instance->is_virtual(0);
__PACKAGE__->result_source_instance->view_definition("
	WITH RECURSIVE all_acls_role_relations(inheritor_id, inherited_id, acl_id) AS (
		SELECT a.inheritor_id,
			a.inherited_id,
			b.acl_id
		FROM role_role_relations a
			 JOIN acl_role_relations b ON b.role_id = a.inherited_id
		WHERE b.positive = true AND NOT (b.acl_id IN ( SELECT c.acl_id
				FROM acl_role_relations c
				WHERE c.positive = false AND c.role_id = a.inheritor_id))
		UNION
		SELECT d.inheritor_id,
			d.inherited_id,
			e.acl_id
		FROM role_role_relations d
			JOIN all_acls_role_relations e ON d.inherited_id = e.inheritor_id
		WHERE NOT (e.acl_id IN ( SELECT f.acl_id
				FROM acl_role_relations f
				WHERE f.positive = false AND f.role_id = d.inheritor_id))
		)
	SELECT all_acls_role_relations.inheritor_id,
		all_acls_role_relations.inherited_id,
		all_acls_role_relations.acl_id
	FROM all_acls_role_relations
	UNION
	SELECT acl_role_relations.role_id AS inheritor_id,
		acl_role_relations.role_id AS inherited_id,
		acl_role_relations.acl_id
	FROM acl_role_relations
	WHERE acl_role_relations.positive = true;
"
);
__PACKAGE__->add_columns(
	'inheritor_id' => { data_type => 'integer' },
	'inherited_id' => { data_type => 'integer' },
	'acl_id'       => { data_type => 'integer' },
);

1;