package QVD::Admin4::CLI::Grammar;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Grammar::Rule;
use QVD::Admin4::CLI::Grammar::Response;

my $ROOT_LABEL = { label => 'ROOT', saturated => 1 };

my $UNKNOWN_TAG = 'UNKNOWN';

my $RULES =
[

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'get', saturated => 1 } ],
   meaning   => sub { 'get' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'set', saturated => 1  } ],
   meaning   => sub { 'update' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'new', saturated => 1  } ],
   meaning   => sub {  'new' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'del', saturated => 1  } ],
   meaning   => sub { 'delete' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'start', saturated => 1  } ],
   meaning   => sub { 'start' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 } ,
   right_side => [ { label => 'stop', saturated => 1  } ],
   meaning   => sub { 'stop' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 } ,
   right_side => [ { label => 'disconnect', saturated => 1  } ],
   meaning   => sub { 'disconnect' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'block', saturated => 1 } ],
   meaning   => sub { 'block' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'unblock', saturated => 1 } ],
   meaning   => sub { 'unblock' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'assign', saturated => 1 } ],
   meaning   => sub { 'assign' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'unassign', saturated => 1 } ],
   meaning   => sub { 'unassign' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'tag', saturated => 1 } ],
   meaning   => sub { 'tag' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'untag', saturated => 1 } ],
   meaning   => sub { 'untag' }  },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 } ,
   right_side => [{ label => 'config', saturated => 1 }],
   meaning   => sub { 'config' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'tenant', saturated => 1 } ],
   meaning   => sub { 'tenant'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'role', saturated => 1 } ],
   meaning   => sub {'role'}},

 { left_side => { label => $UNKNOWN_TAG, , saturated => 0 }, 
   right_side => [ { label => 'acl', saturated => 1 } ],
   meaning   => sub {'acl'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 } ,
   right_side => [ { label => 'admin', saturated => 1 } ],
   meaning   => sub { 'admin' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 } ,
   right_side => [ { label => 'tag', saturated => 1 } ],
   meaning   => sub { 'di_tag'} },

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'property', saturated => 1 } ],
   meaning   => sub { 'property' }},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'vm', saturated => 1 } ],
   meaning   => sub { 'vm'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'user', saturated => 1 } ],
   meaning   => sub { 'user'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'host', saturated => 1 } ],
   meaning   => sub { 'host'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'osf', saturated => 1 } ],
   meaning   => sub {'osf'}},

 { left_side => { label => $UNKNOWN_TAG, saturated => 0 }, 
   right_side => [ { label => 'di', saturated => 1 } ],
   meaning   => sub {'di'}},

# COMMANDS

## COMMANDS

# GET & SET COMMANDS have been implemented as bare words
# at the beginning of ROOT rules (see the end of the grammar)


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
   meaning   => sub {  'new' }},

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

# WITH INDIRECT OBJECT 

 { left_side => { label => 'QVD_OBJECT', saturated => 1, in => 0 },
   right_side => [ { label => 'QVD_OBJECT', saturated => 1, in => 1 },
                   { label => 'IN', saturated => 1 } ],
   meaning   => sub { my ($c0,$c1) = @_;  { obj2 => $c1, %$c0}}},


###################
###################

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

 { left_side => { label => 'QVD_OBJECT', saturated => 0 } ,
   right_side => [{ label => 'config', saturated => 1 }],
   meaning   => sub { 'config' }},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'tenant', saturated => 1 } ],
   meaning   => sub { 'tenant'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'role', saturated => 1 } ],
   meaning   => sub {'role'}},

 { left_side => { label => 'QVD_OBJECT', , saturated => 0 }, 
   right_side => [ { label => 'acl', saturated => 1 } ],
   meaning   => sub {'acl'}},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 } ,
   right_side => [ { label => 'admin', saturated => 1 } ],
   meaning   => sub { 'admin' }},

 { left_side => { label => 'QVD_OBJECT', saturated => 0 } ,
   right_side => [ { label => 'tag', saturated => 1 } ],
   meaning   => sub { 'di_tag'} },

 { left_side => { label => 'QVD_OBJECT', saturated => 0 }, 
   right_side => [ { label => 'property', saturated => 1 } ],
   meaning   => sub { 'property' }},

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

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}, 
		   { label => "ITEM", saturated => 1, feature => 1 } ],
   meaning => sub { my ($c0,$c1) = @_; { qvd_object => $c0, filters => $c1 }}},

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}, 
		   { label => "ITEM", saturated => 1, feature => 0 } ],
   meaning => sub { my ($c0,$c1) = @_; { qvd_object => $c0, filters => { name => [ fields($c1,'-and') ] } }}},

 { left_side => { label => "QVD_OBJECT", saturated => 1 }, 
   right_side => [ { label => 'QVD_OBJECT', saturated => 0}],
   meaning => sub { my $c0 = shift; { qvd_object => $c0}}},


# OPERATORS
# There are operator intended to identify keys with their values '='
# and operators intended to join sets of key/values or lists of keys or values

 { left_side => { label => 'RANGE', saturated => 0 }, 
   right_side => [ { label => '-', saturated => 1 } ],
   meaning => sub { '-between' }},

 { left_side => { label => 'RANGE', saturated => 0 }, 
   right_side => [ { label => ':', saturated => 1 } ],
   meaning => sub { '-between' }},

 { left_side => { label => 'IDOP', saturated => 1 }, 
   right_side => [ { label => '=', saturated => 1 } ],
   meaning => sub { '=' }},

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
   meaning => sub { 'not' }},

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
		    ($c1,$c2) = ('-between',$c2->{'-between'}) 
			if eval { $c2->{'-between'}}; 
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
		    return { $c1->{operator} => [ map { ref($_) ? each %$_ : $_  } @{$c1->{operands}} ] }; }},

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



# PHRASES


# TO introduces the indirect object in an indirect relation
# Ex: ASSIGN property TO vm

 { left_side => { label => 'TO', saturated => 1 }, 
   right_side => [ { label => 'to', saturated => 1 }, 
		   { label =>  "QVD_OBJECT", saturated => 1} ],
   meaning => sub { my ($c0,$c1) = @_; $c1; }},

# IN

 { left_side => { label => 'IN', saturated => 1 }, 
   right_side => [ { label => 'in', saturated => 1}, 
		   { label =>  "QVD_OBJECT", saturated => 1} ],
   meaning => sub { my ($c0,$c1) = @_; $c1; }  },

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
   meaning => sub { my ($c0,$c1) = @_;  { field => [ fields($c1,'-and') ] }}},

 { left_side => { label => 'ORDER', saturated => 1 }, 
   right_side => [ { label => 'order', saturated => 0 },
		   { label => 'DIR', saturated => 1},  
		   { label => 'ITEM', saturated => 1, feature => 0 } ],
   meaning => sub { my ($c0,$c1,$c2) = @_;  { order => $c1, field => $c2 }}},

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
		   { label => 'set', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'assign', obj1 => $c0, obj2 => $c2}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'del', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'unassign', obj1 => $c0, obj2 => $c2}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'assign', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'assign', obj1 => $c0, obj2 => $c2}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'unassign', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'unassign', obj1 => $c0, obj2 => $c2}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'tag', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'assign', obj1 => $c0, obj2 => $c2}}},

 { left_side => { label => 'ROOT', saturated => 1 }, 
   right_side => [ { label => "QVD_OBJECT", saturated => 1 },
		   { label => 'untag', saturated => 1 },
		   { label => "QVD_OBJECT", saturated => 1 }],
   meaning => sub { my ($c0,$c1,$c2) = @_; { command => 'unassign', obj1 => $c0, obj2 => $c2}}}

];

my $KNOWN_TAGS = {};

sub BUILD
{
    my $self = shift;
    $self->{rules} = [];

    for my $rule_args (@$RULES)
    {
	my $rule = QVD::Admin4::CLI::Grammar::Rule->new(%$rule_args);
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



sub fields
{
    my ($item,$OPERATOR) = @_;
    return $item unless ref($item);
    die "Bad item in fields"  if ref($item) eq 'HASH' && 
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

    die "Bad item in arguments";
}

sub response
{
    my ($self,$hash) = @_;
    QVD::Admin4::CLI::Grammar::Response->new(response => $hash);
}
1;

