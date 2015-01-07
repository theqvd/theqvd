package QVD::DB::Result::Acls_Tree_For_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
WITH direct_inherited_roles AS

 ( SELECT json_agg(a.name)::text  as acls, r.* 
   FROM   all_acl_role_relations i JOIN roles r ON i.inheritor_id=r.id JOIN acls a ON i.acl_id=a.id 
   WHERE  r.id IN (SELECT inherited_id FROM role_role_relations WHERE inheritor_id = ? )
   GROUP BY r.id
 )  

SELECT json_agg(j.*) AS roles_json, json_agg(w.*) as acls_json, json_agg(y.name) as operative_acls_json 
FROM direct_inherited_roles j, all_acl_role_relations k
JOIN acl_role_relations w ON w.role_id = ?,
JOIN acl 




SELECT a.id           as acl_id, 
       a.name         as acl_name,
       json_agg(.*)::text  as roles_json,
       i.inheritor_id as role_id 

FROM   all_acl_role_relations i 
JOIN   acls a on a.id=i.acl_id
JOIN   roles r on r.id=i.inherited_id

GROUP BY i.inheritor_id, a.id





"

);

__PACKAGE__->add_columns(

    tree_json  => { data_type => 'JSON' },
);

__PACKAGE__->set_primary_key( qw/ tree_json / );

my $TREE;

sub tree
{
    my $self = shift;
    return $TREE if $TREE;
 
    for my $row (@{decode_json $self->tree_json})
    {
	$TREE->{$row->{inherited_id}}->{id} //= $row->{inherited_id};
	$TREE->{$row->{inherited_id}}->{name} //= $row->{inherited_name};
	$TREE->{$row->{inherited_id}}->{fixed} //= $row->{inherited_fixed};
	$TREE->{$row->{inherited_id}}->{internal} //= $row->{inherited_internal};
	$TREE->{$row->{inherited_id}}->{roles} //= {};
	$TREE->{$row->{inherited_id}}->{acls} //= { 1 => {}, 0 => {}};

	$TREE->{$row->{inheritor_id}}->{id} //= $row->{inheritor_id};
	$TREE->{$row->{inheritor_id}}->{name} //= $row->{inheritor_name};
	$TREE->{$row->{inheritor_id}}->{fixed} //= $row->{inheritor_fixed};
	$TREE->{$row->{inheritor_id}}->{internal} //= $row->{inheritor_internal};
	$TREE->{$row->{inheritor_id}}->{roles} //= {};
	$TREE->{$row->{inheritor_id}}->{acls} //= { 1 => {}, 0 => {}};

	$TREE->{$row->{inheritor_id}}->{roles}->{$row->{inherited_id}} = $TREE->{$row->{inherited_id}}
	unless $row->{inheritor_id} eq $row->{inherited_id};

	next unless defined $row->{acl_id};

	$TREE->{$row->{inherited_id}}->{acls}->{$row->{acl_positive}}->{$row->{acl_id}} = { id => $row->{acl_id}, name => $row->{acl_name}};
	$TREE->{$row->{inherited_id}}->{acls}->{$row->{acl_positive}}->{$row->{acl_id}}->{roles}->{$row->{inherited_id}}->{id} = $row->{inherited_id}; 
	$TREE->{$row->{inherited_id}}->{acls}->{$row->{acl_positive}}->{$row->{acl_id}}->{roles}->{$row->{inherited_id}}->{name} = $row->{inherited_name}; 
    }

    $self->percolate_acls_in_inherited_roles_tree($TREE->{$_}) 
	for keys %$TREE;
    $TREE;
}

sub percolate_acls_in_inherited_roles_tree
{
    my ($self,$current_role) = @_;

    $current_role->{acls}->{1} //= {};    
    $current_role->{acls}->{0} //= {};
    my @inherited_acls;

    push @inherited_acls, $self->percolate_acls_in_inherited_roles_tree($_) for
	values %{$current_role->{roles}};
    
    $current_role->{iacls}->{$_->{id}} = { id => $_->{id}, name => $_->{name}  }
    for @inherited_acls, values %{$current_role->{acls}->{1}};

    delete $current_role->{iacls}->{$_} for keys %{$current_role->{acls}->{0}};

    return values %{$current_role->{iacls}};
} 

sub has_own_positive_acl
{
    my ($self,$acl_name,$role_id) = @_;
    my %acls = map { $_ => 1 } $self->get_positive_own_acl_names($role_id);
    defined $acls{$acl_name} ? return 1 : return 0;
}

sub has_own_negative_acl
{
    my ($self,$acl_name,$role_id) = @_;
    my %acls = map { $_ => 1 } $self->get_negative_own_acl_names($role_id);
    defined $acls{$acl_name} ? return 1 : return 0;
}

sub has_inherited_acl
{
    my ($self,$acl_name,$role_id) = @_;
    my %acls = map { $_ => 1 } $self->get_inherited_acl_names($role_id);
    defined $acls{$acl_name} ? return 1 : return 0;
}

sub get_all_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{name}} values %{$self->tree->{$role_id}->{iacls}};
}

sub get_all_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{id}} values %{$self->tree->{$role_id}->{iacls}};
}

sub get_all_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    values %{$self->tree->{$role_id}->{iacls}};
}

sub get_inherited_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;

    my $out;

    for my $role_info (values %{$self->tree->{$role_id}->{roles}})
    {
	for my $acl_info (values %{$role_info->{iacls}})
	{
	    $out->{$acl_info->{name}} = 1;
	}
    }
    keys %$out;
}

sub get_inherited_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    my $out;

    for my $role_info (values %{$self->tree->{$role_id}->{roles}})
    {
	for my $acl_info (values %{$role_info->{iacls}})
	{
	    $out->{$acl_info->{name}} = 1;
	}
    }
    keys %$out;
}

sub get_inherited_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    my $out;

    for my $role_info (values %{$self->tree->{$role_id}->{roles}})
    {
	for my $acl_info (values %{$role_info->{iacls}})
	{
	    $out->{$acl_info->{name}} = $acl_info;
	}
    }
    values %$out;
}

sub get_positive_own_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{name}} values %{$self->tree->{$role_id}->{acls}->{1}};
}

sub get_positive_own_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{id}} values %{$self->tree->{$role_id}->{acls}->{1}};
}

sub get_positive_own_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    values %{$self->tree->{$role_id}->{acls}->{1}};
}

sub get_negative_own_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{name}} values %{$self->tree->{$role_id}->{acls}->{0}};
}

sub get_negative_own_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{id}} values %{$self->tree->{$role_id}->{acls}->{0}};
}

sub get_negative_own_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    values %{$self->tree->{$role_id}->{acls}->{0}};
}


sub get_role_names
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{name} } values %{$self->tree->{$role_id}->{roles}};
}

sub get_role_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    map { $_->{id} } values %{$self->tree->{$role_id}->{roles}};
}

sub get_role_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    values %{$self->tree->{$role_id}->{roles}};
}

sub get_all_inherited_role_ids
{
   my $self = shift;

   keys %{$self->tree};
}

sub get_all_inherited_role_names
{
   my $self = shift;

   map { $_->{name} } values %{$self->tree};
}


sub get_all_inherited_role_names_ids
{
   my $self = shift;

   map {{ name => $_->{name}, 
	  id   => $_->{id}    }} values %{$self->tree};
}


sub get_acls_direct_inheritance
{

    my ($self,$role_id) = @_; 
    my $inheritance;

    for my $acl_info ($self->get_all_acl_names_ids($role_id))
    {
	$inheritance->{$acl_info->{id}}->{$_->{id}} = $_->{name}
	for grep { defined $_->{iacls}->{$acl_info->{id}} }
	values %{$self->tree->{$role_id}->{roles}};
	
	defined $self->tree->{$role_id}->{acls}->{1}->{$acl_info->{id}} || next;
	$inheritance->{$acl_info->{id}}->{roles}->{$role_id} = 
	    $self->tree->{$role_id}->{name};
    }
    $inheritance;
}



1;
