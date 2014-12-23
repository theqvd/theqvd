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

#################

sub get_roles_with_its_acls_info
{
    my $self = shift;    
    my $out = {};

    for ($self->acls_tree->get_role_names_ids)
    {
	$out->{$_->{id}}->{fixed} = $_->{fixed};
	$out->{$_->{id}}->{internal} = $_->{internal};
	$out->{$_->{id}}->{name} = $_->{name};
	$out->{$_->{id}}->{acls} = [ sort $self->acls_tree->get_all_acl_names($_->{id}) ];
    }

    $out; 
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

sub get_positive_and_negative_acls_info
{
    my $self = shift;
    my $out = { positive => [], negative => []};
    $out->{positive} = [ sort $self->acls_tree->get_positive_own_acl_names ];
    $out->{negative} = [ sort $self->acls_tree->get_negative_own_acl_names ];
    $out; 
}


sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my %acls = map { $_ => 1 } $self->acls_tree->get_all_acl_names($self->id);
    defined $acls{$acl_name} ? return 1 : return 0;
}

sub get_all_acl_names
{
    my $self = shift;
    $self->acls_tree->get_all_acl_names($self->id);
}

######

sub reload_acls_tree
{
    my $self = shift;

    $self->{acls_tree} = 
	$self->load_acls_tree;

    $self->{acls_tree};
}

sub acls_tree
{
    my $self = shift;

    $self->{acls_tree} //= 
	$self->load_acls_tree;

    $self->{acls_tree};
}

sub load_acls_tree
{
    my $self = shift;

    $DB //= QVD::DB->new();
    my $tree_obj = $DB->resultset('Acls_Tree_For_Role')->search(
	{},{bind => [$self->id]})->first;
}

1;

