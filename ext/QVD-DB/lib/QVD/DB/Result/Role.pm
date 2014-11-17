package QVD::DB::Result::Role;
use base qw/DBIx::Class/;
use strict;
use warnings;
use QVD::DB;
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('roles');
__PACKAGE__->add_columns(id => { data_type => 'integer',
                                 is_auto_increment => 1 },
                          name => { data_type => 'varchar(64)' },
                          internal => { data_type => 'boolean' },
                          fixed => { data_type => 'boolean' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(admin_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'role_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(acl_rels => 'QVD::DB::Result::ACL_Role_Relation', 'role_id');
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Role_Relation', 'inheritor_id', { cascade_delete => 0 } );

my $DB;
# FUNCTIONS TO GET DIRECT INFO FROM
# THE ROLE OBJECT ITSELF

#################

sub get_roles_with_its_acls_info
{
    my $self = shift;
    
    my $out = {};

    for ($self->get_role_names_ids)
    {
	$out->{$_->{id}}->{name} = $_->{name};
	$out->{$_->{id}}->{acls} = [ sort $self->get_all_acl_names($_->{id}) ];
    }

    $out; 
}

sub number_of_acls
{
    my $self = shift;
    my $roles_with_its_acls = $self->get_roles_with_its_acls_info;
    my %acls;

    while (my ($role_id,$role_info) = each %$roles_with_its_acls)
    {
	@acls{@{$role_info->{acls}}} = @{$role_info->{acls}};
    }

    my @acls = keys %acls;
    my $acls = @acls;
}

sub get_positive_and_negative_acls_info
{
    my $self = shift;
    my $out = { positive => [], negative => []};
    $out->{positive} = [ sort $self->get_positive_own_acl_names ];
    $out->{negative} = [ sort $self->get_negative_own_acl_names ];
    $out; 
}

#####################
#### NEW VERSION ####
#####################

sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my %acls = map { $_ => 1 } $self->get_all_acl_names($self->id);
    defined $acls{$acl_name} ? return 1 : return 0;
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

    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{name}} values %{$tree->{$role_id}->{iacls}};
}

sub get_all_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{name}} values %{$tree->{$role_id}->{iacls}};
}

sub get_all_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;

    my $tree = $self->get_full_acls_inheritance_tree;
    values %{$tree->{$role_id}->{iacls}};
}

sub get_inherited_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree; 
    my $out;

    for my $role_info (values %{$tree->{$role_id}->{roles}})
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
    my $tree = $self->get_full_acls_inheritance_tree; 
    my $out;

    for my $role_info (values %{$tree->{$role_id}->{roles}})
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
    my $tree = $self->get_full_acls_inheritance_tree; 
    my $out;

    for my $role_info (values %{$tree->{$role_id}->{roles}})
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
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{name}} values %{$tree->{$role_id}->{acls}->{1}};
}

sub get_positive_own_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{id}} values %{$tree->{$role_id}->{acls}->{1}};
}

sub get_positive_own_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    values %{$tree->{$role_id}->{acls}->{1}};
}

sub get_negative_own_acl_names
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{name}} values %{$tree->{$role_id}->{acls}->{0}};
}

sub get_negative_own_acl_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{id}} values %{$tree->{$role_id}->{acls}->{0}};
}

sub get_negative_own_acl_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    values %{$tree->{$role_id}->{acls}->{0}};
}


sub get_role_names
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{name} } values %{$tree->{$role_id}->{roles}};
}

sub get_role_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;
    map { $_->{id} } values %{$tree->{$role_id}->{roles}};
}

sub get_role_names_ids
{
    my $self = shift;
    my $role_id = shift // $self->id;
    my $tree = $self->get_full_acls_inheritance_tree;

    values %{$tree->{$role_id}->{roles}};
}

sub get_all_inherited_role_ids
{
   my $self = shift;
   my $tree = $self->get_full_acls_inheritance_tree;
   keys %$tree;
}

sub get_all_inherited_role_names
{
   my $self = shift;
   my $tree = $self->get_full_acls_inheritance_tree;
   map { $_->{name} } values %$tree;
}


sub get_all_inherited_role_names_ids
{
   my $self = shift;
   my $tree = $self->get_full_acls_inheritance_tree;
   map {{ name => $_->{name}, 
	  id   => $_->{id}    }} values %$tree;
}

######

sub reload_full_acls_inheritance_tree
{
    my $self = shift;

    $self->{full_acls_inheritance_tree} = 
	$self->load_full_acls_inheritance_tree;

    $self->{full_acls_inheritance_tree};
}

sub get_full_acls_inheritance_tree
{
    my $self = shift;

    $self->{full_acls_inheritance_tree} //= 
	$self->load_full_acls_inheritance_tree;

    $self->{full_acls_inheritance_tree};
}

sub load_full_acls_inheritance_tree
{
    my $self = shift;

    my $sql_role_ids = $self->id; 
    my $sql = "
      with recursive all_role_role_relations(inheritor_id, inherited_id) as ( 
        
          select inheritor_id, inherited_id 
          from role_role_relations 
          where inheritor_id in ($sql_role_ids) 

          union 

          select p.inheritor_id, p.inherited_id 
          from all_role_role_relations pr, role_role_relations p 
          where pr.inherited_id=p.inheritor_id  ) 

      select a.inheritor_id, a.inherited_id, d.name, e.name, b.acl_id, c.name, b.positive 
      from all_role_role_relations a 
      left join acl_role_relations b on (a.inherited_id=b.role_id) 
      left join acls c on (c.id=b.acl_id) 
      join roles d on (d.id=a.inheritor_id) 
      join roles e on (e.id=a.inherited_id) 

      union 

      select f.id, f.id, f.name, f.name, g.acl_id, h.name, g.positive 
      from roles f 
      join acl_role_relations g on (f.id=g.role_id) 
      join acls h on (h.id=g.acl_id) 

      where f.id in ($sql_role_ids)";

    $DB //= QVD::DB->new();
    my $dbh = $DB->storage->dbh;
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $ff = $sth->fetchall_arrayref();

    my $tree;
    for my $row (@$ff)
    {
	$tree->{@{$row}[1]}->{id} //= @{$row}[1];
	$tree->{@{$row}[1]}->{name} //= @{$row}[3];
	$tree->{@{$row}[1]}->{roles} //= {};
	$tree->{@{$row}[1]}->{acls} //= { 1 => {}, 0 => {}};

	$tree->{@{$row}[0]}->{id} //= @{$row}[0];
	$tree->{@{$row}[0]}->{name} //= @{$row}[2];
	$tree->{@{$row}[0]}->{roles} //= {};
	$tree->{@{$row}[0]}->{acls} //= { 1 => {}, 0 => {}};

	$tree->{@{$row}[0]}->{roles}->{@{$row}[1]} = $tree->{@{$row}[1]}
	unless @{$row}[0] eq @{$row}[1];

	next unless defined @{$row}[4];

	$tree->{@{$row}[1]}->{acls}->{@{$row}[6]}->{@{$row}[4]} = { id => @{$row}[4], 
								    name => @{$row}[5]};
	$tree->{@{$row}[1]}->{acls}->{@{$row}[6]}->{@{$row}[4]}->{roles}->{@{$row}[1]}->{id} = @{$row}[1]; 
	$tree->{@{$row}[1]}->{acls}->{@{$row}[6]}->{@{$row}[4]}->{roles}->{@{$row}[1]}->{name} = @{$row}[3]; 
    }

    $self->percolate_acls_in_inherited_roles_tree($tree->{$_}) 
	for keys %$tree;
    $tree;
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

1;
