package QVD::Admin4::CLI::Grammar;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Grammar::Rule;

my $UNKNOWN_TAG = 'UNKNOWN';

my $RULES =
[

# SIMPLE WORDS

## COMMANDS

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'get_list', %{@{$rs}[1]->get_api} });}},

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''", 'ORDER_BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'get_list', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'set', "QVD_OBJECT'", 'WITH' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'update', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}});}},

 { left_side => 'CMD', 
   right_side => [ 'del' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'delete'});}},

 { left_side => 'ROOT', 
   right_side => [ 'new', 'QVD_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'create', %{@{$rs}[1]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'new', 'QVD_OBJECT', 'WITH' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'create', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}});}},

 { left_side => 'CMD', 
   right_side => [ 'block' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'update', 
				arguments => { blocked => 1}});}},

 { left_side => 'CMD', 
   right_side => [ 'unblock' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'update', 
				arguments => { blocked => 0}});}},

 { left_side => 'CMD', 
   right_side => [ 'start' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'start'});}},

 { left_side => 'CMD', 
   right_side => [ 'stop' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'stop'});}},

 { left_side => 'CMD', 
   right_side => [ 'disconnect' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'disconnect'});}},

# COMMANDS WITH INDIRECT RELATIONS:
# Take both a direct object and an indirect object
# and assign the first one to the second one as an argument
# Ex: ASSIGN property TO vm

 { left_side => 'IND_CMD', 
   right_side => [ 'assign' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'assign'});}},

 { left_side => 'IND_CMD', 
   right_side => [ 'unassign' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'unassign'});}},

 { left_side => 'IND_CMD', 
   right_side => [ 'set' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'assign'});}},

 { left_side => 'IND_CMD', 
   right_side => [ 'del' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'unassign'});}},

# COMMANDS WITH DIRECT RELATIONS
# Take both a direct object and an indirect object
# and assign the second one to the first one as an argument
# Ex: TAG di AS default

 { left_side => 'DIT_CMD', 
   right_side => [ 'tag' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'assign'});}},

 { left_side => 'DIT_CMD', 
   right_side => [ 'untag' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'unassign'});}},

# INDIVIDUALS (OBJECTS IN QVD UNIVERSE)


 { left_side => 'QVD_OBJECT', 
   right_side => [ 'tenant' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'tenant'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'role' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'role'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'acl' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'acl'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'admin' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'admin'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'tag' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'di_tag'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'property' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'property'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'vm' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'vm'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'user' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'user'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'host' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'host'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'osf' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'osf'});}},

 { left_side => 'QVD_OBJECT', 
   right_side => [ 'di' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => 'di'});}},


# OPERATORS
# There are operator intended to identify keys with their values '='
# and operators intended to join sets of key/values or lists of keys or values

 { left_side => 'EQUAL', 
   right_side => [ '=' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'COORD', 
   right_side => [ ',' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

# FILTERS AND ARGUMENTS

# A token that is not a reserved word
# is allways considered as a key or a value
# This unknown tokens can be combined with identification or
# coordination operators in order to build key/value sets or keys (or values) lists

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

# PHRASES

# PREPOSITIONAL PHRASES

# WITH marks key/values sets as arguments
# Ex: SET vms 1,2,3 WITH user_id=2
 
 { left_side => 'WITH', 
   right_side => [ 'with', 'KEY_VALUE' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ arguments => @{$rs}[1]->get_api });}},

# AS introduces a list of keys to be assigned as tags
# Ex: TAG dis 2 AS default

 { left_side => 'AS', 
   right_side => [ 'as', 'KEY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

# TO introduces the indirect object in an indirect relation
# Ex: ASSIGN property TO vm

 { left_side => 'TO', 
   right_side => [ 'to', "QVD_OBJECT'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

# BY introduces the list of criteria in an order by secuence
# Ex: GET vms ORDER BY tenant_id, name

 { left_side => 'BY', 
   right_side => [ 'by', 'KEY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

# OF is uses as a join element that joins a qvd object with an explicit list
# of fields to be retrieved
# Ex: GET tenant_id, name OF vms 2,3,4

 { left_side => 'OF', 
   right_side => ['of'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[0]->get_api);}},

# ORDER BY PHRASES
# order by tenant_id,name
# order asc by tenant_id,name
# order desc by tenant_id,name

 { left_side => 'ORDER', 
   right_side => [ 'order' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({});}},

 { left_side => 'DIR', 
   right_side => [ 'asc' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api('-asc');}},

 { left_side => 'DIR', 
   right_side => [ 'desc' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api('-desc');}},

 { left_side => 'ORDER_BY', 
   right_side => [ 'ORDER', 'BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order_by => { field => @{$rs}[1]->get_api }});}},

 { left_side => 'ORDER_BY', 
   right_side => [ 'ORDER', 'DIR', 'BY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({order_by => { order => @{$rs}[1]->get_api, 
					     field => @{$rs}[2]->get_api }});}},

# NOMINAL PHRASES (INDIVIDUALS IN QVD UNIVERSE)

# QVD_OBJECT specified with key/value filters

 { left_side => "QVD_OBJECT'", 
   right_side => [ 'QVD_OBJECT', 'KEY_VALUE' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

# QVD_OBJECT specified with a list of possible value filters
# The key of this filters must be a default one (typically id or name)

 { left_side => "QVD_OBJECT'", 
   right_side => [ 'QVD_OBJECT', 'KEY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

 { left_side => "QVD_OBJECT''", 
   right_side => ['KEY', 'OF', "QVD_OBJECT'"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ fields => @{$rs}[0]->get_api, %{@{$rs}[2]->get_api}});}},

# Free projections of QVD_OBJECTS to bare individuals (Ex: get vm)

 { left_side => "QVD_OBJECT'", 
   right_side => [ 'QVD_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[0]->get_api);}},


 { left_side => "QVD_OBJECT''", 
   right_side => [ "QVD_OBJECT'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[0]->get_api);}},


# TOP PHRASES (ROOT)

 { left_side => 'ROOT', 
   right_side => [ 'CMD', "QVD_OBJECT'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api},
                            %{@{$rs}[1]->get_api}});}},


 { left_side => 'ROOT', 
   right_side => [ 'IND_CMD', "QVD_OBJECT'", 'TO' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api}, arguments => @{$rs}[1]->get_api, 
                            %{@{$rs}[2]->get_api}});}},

 { left_side => 'ROOT', 
   right_side => [ 'DIT_CMD', "QVD_OBJECT'", 'AS' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ %{@{$rs}[0]->get_api}, %{@{$rs}[1]->get_api},
				arguments => { qvd_object => 'di_tag', 
					       filters => @{$rs}[2]->get_api }});}},


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
