package QVD::Admin4::Grammar;
use strict;
use warnings;
use Moo;
use QVD::Admin4::Grammar::Rule;
use QVD::Admin4::Grammar::Response;

# This is the definition of the axiom of the grammar

my $ROOT_LABEL = { label => 'ROOT', saturated => 1 };

# This is the tag by convention that will be used for
# constituentes built from unknown strings 

my $UNKNOWN_TAG = 'UNKNOWN';

# This is the descriptive implementation of the grammar
# The grammar is an array of rules
# Every hash in the array is a rule
# Every rule has:
# a) left_side: the constituent that the rule defines.
# b) right_side: the list of constituents that must be joined
#    in order to create the left side constituent
# c) meaning: The function intended to build the meaning of
#    the left side constituent from the meanings of the right
#    side constituents 

my $RULES =
[

# All key words are defined as  ambiguous in the grammar.
# They can be either the reserved word or a free value
# (i.e. user name=user get id).

# So these are the rules that create the free versions of the key
# words

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'default', saturated => 1 } ],
   meaning   => sub { 'default' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'get', saturated => 1 } ],
   meaning   => sub { 'get' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'can', saturated => 1 } ],
   meaning   => sub { 'can' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'set', saturated => 1  } ],
   meaning   => sub { 'set' }},

	{
		left_side => { label => $UNKNOWN_TAG, saturated => 1 },
		right_side => [ { label => 'ssl', saturated => 1  } ],
		meaning   => sub { 'ssl' }
	},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'new', saturated => 1  } ],
   meaning   => sub {  'new' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'del', saturated => 1  } ],
   meaning   => sub { 'del' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'start', saturated => 1  } ],
   meaning   => sub { 'start' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 } ,
   right_side => [ { label => 'stop', saturated => 1  } ],
   meaning   => sub { 'stop' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 } ,
   right_side => [ { label => 'disconnect', saturated => 1  } ],
   meaning   => sub { 'disconnect' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'block', saturated => 1 } ],
   meaning   => sub { 'block' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'unblock', saturated => 1 } ],
   meaning   => sub { 'unblock' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'assign', saturated => 1 } ],
   meaning   => sub { 'assign' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'unassign', saturated => 1 } ],
   meaning   => sub { 'unassign' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'tag', saturated => 1 } ],
   meaning   => sub { 'tag' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'untag', saturated => 1 } ],
   meaning   => sub { 'untag' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'log', saturated => 1 } ],
   meaning   => sub { 'log'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'config', saturated => 1 } ],
   meaning   => sub { 'config'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'tenant', saturated => 1 } ],
   meaning   => sub { 'tenant'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'role', saturated => 1 } ],
   meaning   => sub {'role'}},

 { left_side => { label => $UNKNOWN_TAG, , saturated => 1 }, 
   right_side => [ { label => 'acl', saturated => 1 } ],
   meaning   => sub {'acl'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 } ,
   right_side => [ { label => 'admin', saturated => 1 } ],
   meaning   => sub { 'admin' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'vm', saturated => 1 } ],
   meaning   => sub { 'vm'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'user', saturated => 1 } ],
   meaning   => sub { 'user'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'host', saturated => 1 } ],
   meaning   => sub { 'host'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'osf', saturated => 1 } ],
   meaning   => sub {'osf'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 1 }, 
   right_side => [ { label => 'di', saturated => 1 } ],
   meaning   => sub {'di'}},

# ACTIONS

 { left_side => { label => 'CMD', saturated => 0 }, 
   right_side => [ { label => 'get', saturated => 1, 
		     order => 1, of => 1, to => 0, with => 0  } ],
   meaning   => sub { 'get' }  },

 { left_side => { label => 'CMD', saturated => 0 }, 
   right_side => [ { label => 'set', saturated => 1,
		     order => 0, of => 0, to => 1, with => 1  } ],
   meaning   => sub { 'update' }},

 { left_side => { label => 'CMD', saturated => 0 }, 
   right_side => [ { label => 'new', saturated => 1,
		     order => 0, of => 0, to => 0, with => 1  } ],
   meaning   => sub {  'create' }},

	{
		left_side => { label => 'CMD', saturated => 0 },
		right_side => [
			{ label => 'default', saturated => 1, order => 0, of => 0, to => 0, with => 0 },
		],
		meaning   => sub { 'default' }
	},

	{
		left_side => { label => 'CMD', saturated => 0 },
		right_side => [
			{ label => 'ssl', saturated => 1, order => 0, of => 0, to => 0, with => 1 },
		],
		meaning   => sub { 'ssl' }
	},

 { left_side => { label => 'CMD', saturated => 0 }, 
   right_side => [ { label => 'del', saturated => 1,
		     order => 0, of => 0, to => 0, with => 0  } ],
   meaning   => sub { 'delete' }},

 { left_side => { label => 'CMD', saturated => 0 }, 
   right_side => [ { label => 'start', saturated => 1,
		     order => 0, of => 0, to => 0, with => 0  } ],
   meaning   => sub { 'start' }},

 { left_side => { label => 'CMD', saturated => 0 } ,
   right_side => [ { label => 'stop', saturated => 1,
		     order => 0, of => 0, to => 0, with => 0  } ],
   meaning   => sub { 'stop' }},

 { left_side => { label => 'CMD', saturated => 0 } ,
   right_side => [ { label => 'disconnect', saturated => 1,
		     order => 0, of => 0, to => 0, with => 0  } ],
   meaning   => sub { 'disconnect' }},

 { left_side => { label => 'CMD', saturated => 1, order => '#order', of => '#of', to => '#to', with => '#with' } ,
   right_side => [ { label => 'QVD_OBJECT', saturated => 1 },
		   { label => 'CMD', saturated => 0, order => '#order', of => '#of', to => '#to', with => '#with' }],
   meaning   => sub { my ($c0,$c1) = @_; { command => $c1, obj1 => $c0};}},

 { left_side => { label => 'CMD', saturated => 1, order => '#order', of => 0, to => 0, with => 0 } ,
   right_side => [ { label => 'QVD_OBJECT', saturated => 1 },
		   { label => 'CMD', saturated => 0, order => '#order', of => 1, to => 0, with => 0 },
                   { label => 'ITEM', saturated => 1, feature => 0 }],
   meaning   => sub { my ($c0,$c1,$c2) = @_; { command => $c1, fields => [ reverse fields($c2,'-and') ], obj1 => $c0}}},

# ORDER BY

 { left_side => { label => 'CMD', saturated => 1, order => 0, of => 0, with => 0 },
   right_side => [ { label => 'CMD', saturated => 1, order => 1, of => 0, with => 0 },
                   { label => 'ORDER', saturated => 1 } ],
   meaning   => sub { my ($c0,$c1) = @_; { order_by => $c1, %$c0}}},


# REGULAR SET

 { left_side => { label => 'CMD', saturated => 1, order => 0, of => 0, with => 0 },
   right_side => [ { label => 'CMD', saturated => 1, order => 0, of => 0, with => 1 },
                   { label => 'ITEM', saturated => 1, feature => 1 } ],
   meaning   => sub { my ($c0,$c1) = @_; return { arguments => { arguments($c1,'-and','=') }, %$c0}}},

# INDIVIDUALS (OBJECTS IN QVD UNIVERSE)

# QVD_OBJECT specified with key/value filters

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'log', saturated => 1 } ],
   meaning   => sub { 'log'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'tenant', saturated => 1 } ],
   meaning   => sub { 'tenant'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'role', saturated => 1 } ],
   meaning   => sub {'role'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'acl', saturated => 1 } ],
   meaning   => sub {'acl'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 } ,
   right_side => [ { label => 'admin', saturated => 1 } ],
   meaning   => sub { 'admin' }},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'vm', saturated => 1 } ],
   meaning   => sub { 'vm'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'user', saturated => 1 } ],
   meaning   => sub { 'user'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'host', saturated => 1 } ],
   meaning   => sub { 'host'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'osf', saturated => 1 } ],
   meaning   => sub {'osf'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'di', saturated => 1 } ],
   meaning   => sub {'di'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 },
 right_side => [ { label => 'config', saturated => 1 } ],
 meaning   => sub {'config'}},

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}, 
		   { label => "ITEM", saturated => 1, feature => 1 } ],
   meaning => sub { my ($c0,$c1) = @_; { qvd_object => $c0, filters => $c1 }}},

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}, 
		   { label => "ITEM", saturated => 1, feature => 0 } ],
   meaning => sub { my ($c0,$c1) = @_; { qvd_object => $c0, filters => { name => [ fields($c1,'-and') ] }}}},

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}],
   meaning => sub { my $c0 = shift; { qvd_object => $c0}}},

# OPERATORS
# There are operator intended to identify keys with their values '='
# and operators intended to join sets of key/values or lists of keys or values

 { left_side => { label => 'RANGE', saturated => 0 }, 
   right_side => [ { label => ':', saturated => 1 } ],
   meaning => sub { '-between' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '=', saturated => 1 } ],
   meaning => sub { '=' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '!=', saturated => 1 } ],
   meaning => sub { '!=' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '>', saturated => 1 } ],
   meaning => sub { '>' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '<', saturated => 1 } ],
   meaning => sub { '<' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '>=', saturated => 1 } ],
   meaning => sub { '>=' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '<=', saturated => 1 } ],
   meaning => sub { '<=' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '~', saturated => 1 } ],
   meaning => sub { 'LIKE' }},

 { left_side => { label => 'LOP', saturated => 1 }, 
   right_side => [ {label => ',', saturated => 1 } ],
   meaning => sub { '-and' }},

 { left_side => { label => 'LOP', saturated => 1 }, 
   right_side => [ {label => ';', saturated => 1 } ],
   meaning => sub { '-or' }},

 { left_side => { label => 'NOT', saturated => 1 }, 
   right_side => [ {label => '!', saturated => 1 } ],
   meaning => sub { '-not' }},

 { left_side => { label => 'OP', saturated => 1 }, 
   right_side => [ { label => '(', saturated => 1 } ],
   meaning => sub { '(' }},

 { left_side => { label => 'CP', saturated => 1 }, 
   right_side => [ {label => ')', saturated => 1 } ],
   meaning => sub { ')' }},

 { left_side => { label => 'OB', saturated => 1 }, 
   right_side => [ { label => '[', saturated => 1 } ],
   meaning => sub { '[' }},

 { left_side => { label => 'CB', saturated => 1 }, 
   right_side => [ {label => ']', saturated => 1 } ],
   meaning => sub { ']' }},

# FILTERS AND ARGUMENTS

# A token that is not a reserved word
# is allways considered as a key or a value
# This unknown tokens can be combined with identification or
# coordination operators in order to build key/value sets or keys (or values) lists

# Keys and Sets are items

 { left_side => { label => 'ITEM', saturated => 1, feature => 0, coordinated => 0}, 
   right_side => [ { label => $UNKNOWN_TAG, saturated => 1 } ],
   meaning => sub {my $c0 = shift;  return $c0 }},

 { left_side => { label => 'ITEM', saturated => 1, feature => 1, coordinated => 0 }, 
   right_side => [ { label => $UNKNOWN_TAG, saturated => 1}, 
		   { label => 'IDOP', saturated => 1}, 
		   {label => 'ITEM', saturated => 1, feature => 0, coordinated => 0}],
   meaning => sub { my ($c0,$c1,$c2) = @_; 
		    ($c1,$c2) = ('-between',$c2->{'-between'}) if eval { $c2->{'-between'}}; 
		    return { $c0 => $c2 } if ref($c2) && ref($c2) eq 'ARRAY' && $c1 ne '-between';
		    return { $c0 =>  { $c1 =>  $c2 }}; }},

# Items can be coordinated

 { left_side => { label => "ITEM", saturated => 1, feature => '#feature', coordinated => 1 }, 
   right_side => [ { label => 'NOT', saturated => 1}, 
		   { label => 'ITEM', saturated => 1, feature => '#feature'}],
   meaning => sub { no strict; my ($c0,$c1) = @_; $c1 = [$c1] unless ref($c1)  && ref($c1) eq 'ARRAY'; 
		    return  { $c0 => [ map { ref($_) ? each %$_ : $_ } @$c1 ] }}},

 { left_side => { label => "ITEM", saturated => 0, feature => '#feature', coordinated => 1 }, 
   right_side => [ { label => 'LOP', saturated => 1}, 
		   { label => 'ITEM', saturated => 1, feature => '#feature'}],
   meaning => sub { my ($c0,$c1) = @_; $c1 = [$c1] unless ref($c1) && ref($c1) eq 'ARRAY'; return { operator => $c0, operands => $c1} } },

 { left_side => { label => "ITEM", saturated => 1,  feature => '#feature', coordinated => 1 }, 
   right_side => [ { label => 'ITEM', saturated => 1, feature => '#feature', coordinated => 0 }, 
		   { label => "ITEM", saturated => 0, feature => '#feature'} ],
   meaning => sub { no strict; my ($c0,$c1) = @_; push @{$c1->{operands}}, $c0; 
		    return { $c1->{operator} => [ map { ref($_) && ref($_) eq 'HASH' ? each %$_ : $_  } @{$c1->{operands}} ] }; }},

# Parenthesis

 { left_side => { label => "ITEM", saturated => 1, coordinated => 0, feature => '#feature' }, 
   right_side => [ { label => 'OP', saturated => 1}, 
		   { label => "ITEM", saturated => 1, feature => '#feature' }, 
		   { label => 'CP', saturated => 1 } ],
   meaning => sub { my ($c0,$c1,$c2) = @_; return $c1; }},

# Brackets

 { left_side => { label => "ITEM", saturated => 1, coordinated => 0, brackets => 1 }, 
   right_side => [ { label => 'OB', saturated => 1}, 
		   { label => "ITEM", saturated => 1, feature => 0, brackets => 0 }, 
		   { label => 'CB', saturated => 1 } ],
   meaning => sub { my ($c0,$c1,$c2) = @_; return [ fields($c1,'-and')]; }},

 { left_side => { label => "ITEM", saturated => 1, coordinated => 0, brackets => 1 }, 
   right_side => [ { label => 'OB', saturated => 1}, 
		   { label => "RANGE", saturated => 0 }, 
		   { label => 'CB', saturated => 1 } ],
   meaning => sub { my ($c0,$c1,$c2) = @_; return $c1; }},

 { left_side => { label => "RANGE", saturated => 0 }, 
   right_side => [ { label => 'ITEM', saturated => 1, feature => 0, coordinated => 0, brackets => 0 },
		   { label => 'RANGE', saturated => 0}, 
		   { label => 'ITEM', saturated => 1, feature => 0, coordinated => 0, brackets => 0 }],
   meaning => sub { my ($c0,$c1,$c2) = @_;  return { $c1 => [$c0,$c2] }}},

# ORDER BY PHRASES
# order by tenant_id,name
# order asc by tenant_id,name
# order desc by tenant_id,name

 { left_side => { label => 'DIR', saturated => 1 }, 
   right_side => [ { label => 'asc', saturated => 1} ],
   meaning => sub { '-asc' }},

 { left_side => { label => 'DIR', saturated => 1 }, 
   right_side => [ { label => 'desc', saturated => 1} ],
   meaning => sub { '-desc' }},

 { left_side => { label => 'ORDER', saturated => 1 }, 
   right_side => [ { label => 'order', saturated => 0 },
		   { label => 'ITEM', saturated => 1, feature => 0 } ],
   meaning => sub { my ($c0,$c1) = @_;  { field => [ reverse fields($c1,'-and') ] }}},

 { left_side => { label => 'ORDER', saturated => 1 }, 
   right_side => [ { label => 'order', saturated => 0 },
		   { label => 'DIR', saturated => 1},  
		   { label => 'ITEM', saturated => 1, feature => 0 } ],
   meaning => sub { my ($c0,$c1,$c2) = @_;  { order => $c1, field => [ reverse fields($c2,'-and') ] }}},

# TOP PHRASES (ROOT)

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => 'CMD', saturated => 1, order => 0, in => 0, of => 0, to => 0, with => 0 } ],
   meaning => sub { my $c0 = shift; $c0 }},

# AD HOC TOP PHRASES 

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [  { label => "QVD_OBJECT", saturated => 1 },
		    { label => 'block', saturated => 1 } ],
   meaning => sub { my $c0 = shift; { command => 'update', obj1 => $c0, arguments => { blocked => 1 }}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'unblock', saturated => 1 } ],
   meaning => sub { my $c0 = shift; { command => 'update', obj1 => $c0, arguments => { blocked => 0 }}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'tag', saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'update', obj1 => $c0, arguments => { __tags_changes__ => { create => [fields($c2,'-and')] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'untag', saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'update', obj1 => $c0, arguments => { __tags_changes__ => { delete => [ fields($c2,'-and') ] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'assign', saturated => 1 },
		   { label => "acl", saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2,$c3) = @_; { command => 'update', obj1 => $c0, arguments => { __acls_changes__ => { assign_acls => [ fields($c3,'-and') ] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'unassign', saturated => 1 },
		   { label => "acl", saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2,$c3) = @_; { command => 'update', obj1 => $c0, arguments => { __acls_changes__ => { unassign_acls => [ fields($c3,'-and') ] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'assign', saturated => 1 },
		   { label => "role", saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2,$c3) = @_; { command => 'update', obj1 => $c0, arguments => { __roles_changes__ => { assign_roles => [ fields($c3,'-and') ] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'unassign', saturated => 1 },
		   { label => "role", saturated => 1 },
                   { label => "ITEM", saturated => 1, feature => 0 }],
   meaning => sub { my ($c0,$c1,$c2,$c3) = @_; { command => 'update', obj1 => $c0, arguments => { __roles_changes__ => { unassign_roles => [ fields($c3,'-and') ] }}}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => "can", saturated => 1 },
		   { label => "ITEM", saturated => 1, feature => 0, coordinated => 0 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; return { command => 'can', obj1 => $c0, parameters => { acl_name => $c2 }}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => "can", saturated => 1 }],
   meaning => sub { my ($c0,$c1) = @_; return { command => 'can', obj1 => $c0}}},

];

# Store to easily know if a string is a tag defined in the grammar 
my $KNOWN_TAGS = {};

sub BUILD
{
    my $self = shift;
    $self->{rules} = [];

    # Rules are built as objects and stored in the object

    for my $rule_args (@$RULES)
    {
	my $rule = QVD::Admin4::Grammar::Rule->new(%$rule_args);
	$KNOWN_TAGS->{$_->{label}} = 1 for $rule->daughters;
	push @{$self->{rules}}, $rule;
    }
}

sub get_rules
{
    my $self = shift;
    @{$self->{rules}};
}

sub unknown_tag
{
    return $UNKNOWN_TAG;
}

sub root
{
    my $self = shift;
    return $ROOT_LABEL;
}

sub is_known_tag
{
    my ($self,$tag) = @_;
    exists $KNOWN_TAGS->{$tag} ? 
	return 1 : return 0;
}

# Creates a wrapper for a HASH passed as argument that is supposed
# to be the meaning of a root constituent according the grammar

sub response
{
    my ($self,$hash) = @_;
    QVD::Admin4::Grammar::Response->new(response => $hash);
}

############################

# Functions intended to create constituents in an ad hoc way
# without the use of a rule. They are user by the parser to create
# the initial constituents of the parsing

sub get_labels_for_string
{
    my ($self,$string) = @_;
    my @labels = $self->is_known_tag($string) ? 
	{ label => $string } : { label => $self->unknown_tag };
    return @labels;
}

sub get_meaning_for_string
{
    my ($self,$string) = @_;
    return $string;
}

############################

# Functions used in several of the callbacks of the rules in the grammar
# The give a certain format to complex nested parts of the meanings of the
# constituents

sub fields
{
    my ($item,$OPERATOR) = @_;
    return $item unless ref($item);

    return ()  if ref($item) eq 'HASH' && 
	(not exists $item->{$OPERATOR});
    return fields($item->{$OPERATOR},$OPERATOR) if ref($item) eq 'HASH' 
	&& (exists $item->{$OPERATOR});
    shift @$item if @$item[0] eq $OPERATOR;
    my @out = map { fields($_,$OPERATOR) } @$item;
    return  @out;
}

sub arguments
{
    my ($item,$AND,$EQUAL) = @_;
    return $item unless ref($item);

    if (ref($item) eq 'HASH')
    {
	return arguments($item->{$AND},$AND,$EQUAL) if ref($item) eq 'HASH' 
	    && (exists $item->{$AND});
	return $item->{$EQUAL} if ref($item) eq 'HASH' 
	    && (exists $item->{$EQUAL});
	return map { arguments($_,$AND,$EQUAL) } each %$item;;
    }
    
    if (ref($item) eq 'ARRAY')
    {
	shift @$item if $$item[0] eq $AND; 
	return map { arguments($_,$AND,$EQUAL) } @$item;
    }

    return ();
}

1;

