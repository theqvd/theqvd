package QVD::Admin4::CLI::Grammar;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Grammar::Rule;

my $UNKNOWN_TAG = 'UNKNOWN';

my $RULES =
[

 { left_side => 'KEY', 
   right_side => [ $UNKNOWN_TAG ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api([ @{$rs}[0]->get_api ])}},

 { left_side => 'KEY', 
   right_side => [ 'KEY', 'COORD', 'KEY'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(
		     [ @{@{$rs}[0]->get_api}, @{@{$rs}[2]->get_api} ]);}},

 { left_side => 'KEY_VALUE', 
   right_side => [ $UNKNOWN_TAG, 'EQUAL', $UNKNOWN_TAG],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ @{$rs}[0]->get_api => @{$rs}[2]->get_api })}},

 { left_side => 'KEY_VALUE', 
   right_side => [ 'KEY_VALUE', 'COORD', 'KEY_VALUE'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(
		     { %{@{$rs}[0]->get_api}, %{@{$rs}[2]->get_api} });}},

 { left_side => 'BY', 
   right_side => [ 'by', 'KEY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ field => @{$rs}[1]->get_api });}},

 { left_side => 'ORDER', 
   right_side => [ 'order' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'DIR', 
   right_side => [ 'asc' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order => '-asc'});}},

 { left_side => 'DIR', 
   right_side => [ 'desc' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order => '-desc'});}},

 { left_side => 'ORDER_BY', 
   right_side => [ 'ORDER', 'BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order_by => @{$rs}[1]->get_api });}},

 { left_side => 'ORDER_BY', 
   right_side => [ 'ORDER', 'DIR', 'BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order_by => { %{@{$rs}[1]->get_api}, 
					     %{@{$rs}[2]->get_api} }});}},

 { left_side => 'EQUAL', 
   right_side => [ '=' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'WITH', 
   right_side => [ 'with' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'TO', 
   right_side => [ 'to' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'OF', 
   right_side => [ 'of' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'COORD', 
   right_side => [ ',' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'DI_CMD', 
   right_side => [ 'assign' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'assign'});}},

 { left_side => 'CMD', 
   right_side => [ 'get' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'get_list'});}},

 { left_side => 'CMD', 
   right_side => [ 'set' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'update'});}},

 { left_side => 'CMD', 
   right_side => [ 'del' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'delete'});}},

 { left_side => 'CMD', 
   right_side => [ 'add' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'create'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'roles' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'role'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'acls' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'acl'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'vms' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'vm'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'users' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'user'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'hosts' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'host'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'osfs' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'osf'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'dis' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'di'});}},

 { left_side => 'ROOT', 
   right_side => [ 'DI_CMD', 'QVD_OBJECT', 'INDIRECT_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api}, nested => @{$rs}[1]->get_api, 
                            %{@{$rs}[2]->get_api}});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'QVD_OBJECT', 'KEY_VALUE' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

 { left_side => 'FIELDS', 
   right_side => [ 'KEY', 'OF','QVD_OBJECT'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ fields => @{$rs}[0]->get_api,
                            %{@{$rs}[2]->get_api}});}},

 { left_side => 'ARGUMENTS', 
   right_side => [ 'WITH', 'KEY_VALUE' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ arguments => @{$rs}[1]->get_api });}},

 { left_side => 'INDIRECT_OBJECT', 
   right_side => [ 'TO', 'QVD_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => 'ROOT', 
   right_side => [ 'CMD', 'QVD_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api},
                            %{@{$rs}[1]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'CMD', 'FIELDS' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api},
                            %{@{$rs}[1]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'ROOT', 'ARGUMENTS' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api},
                            %{@{$rs}[1]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'ROOT', 'ORDER_BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api},
                            %{@{$rs}[1]->get_api}});}}


];

my ($RULES_BY_LEFT_SIDE,$RULES_BY_FIRST_RIGHT_SIDE) = ({},{});

sub BUILD
{
    my $self = shift;

    for my $rule_args (@$RULES)
    {
	my $rule = QVD::Admin4::CLI::Grammar::Rule->new(%$rule_args);
	$RULES_BY_LEFT_SIDE->{$rule->left_side} //= [];
	$RULES_BY_FIRST_RIGHT_SIDE->{$rule->first_daughter->label} //= []; 
	push @{$RULES_BY_LEFT_SIDE->{$rule->left_side}}, $rule;
	push @{$RULES_BY_FIRST_RIGHT_SIDE->{$rule->first_daughter->label}}, $rule; 

    }
}

sub get_rules
{
    my $self = shift;
    my @rule_list;

    push  @rule_list, $self->get_rules_by_left_side($_)
	for keys %$RULES_BY_LEFT_SIDE;
    @rule_list;
}


sub get_rules_by_left_side
{
    my ($self,$left_side) = @_;
    return () unless defined $RULES_BY_LEFT_SIDE->{$left_side}; 
    @{$RULES_BY_LEFT_SIDE->{$left_side}};
}

sub get_rules_by_first_right_side
{
    my ($self,$first_right_side) = @_;
    return () unless defined $RULES_BY_FIRST_RIGHT_SIDE->{$first_right_side}; 
    @{$RULES_BY_FIRST_RIGHT_SIDE->{$first_right_side}};
}

sub unknown_tag
{
    return $UNKNOWN_TAG;
}

1;
