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

sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my %acls = map { $_ => 1 } $self->acls;
    defined $acls{$acl_name} ? return 1 : return 0;
}

######

sub reload_acls
{
    my $self = shift;

    $self->{acls} = 
	$self->load_acls;

    $self->{acls};
}

sub acls
{
    my $self = shift;

    $self->{acls} //= 
	$self->load_acls;

    @{$self->{acls}};
}

sub load_acls
{
    my $self = shift;

    $DB //= QVD::DB->new();
    my $rs = $DB->resultset('Operative_Acls_In_Role')->search()->search(
	{'me.role_id' => $self->id});

    my @acls = map { $_->acl_name } $rs->all; 
    \@acls;
}

1;

