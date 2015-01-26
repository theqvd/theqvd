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

# GET & SET COMMANDS have been implemented as bare words
# at the beginning of ROOT rules (see the end of the grammar)

 { left_side => 'CMD', 
   right_side => [ 'del' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ command => 'delete'});}},

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


 { left_side => 'CONFIG', 
   right_side => ['config'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[0]->get_api);}},

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

 { left_side => 'LOGICAL', 
   right_side => [ 'and' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api('-and');}},

 { left_side => 'LOGICAL', 
   right_side => [ 'or' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api('-or');}},

 { left_side => 'OP', 
   right_side => [ '(' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api();}},

 { left_side => 'CP', 
   right_side => [ ')' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api();}},


# FILTERS AND ARGUMENTS

# A token that is not a reserved word
# is allways considered as a key or a value
# This unknown tokens can be combined with identification or
# coordination operators in order to build key/value sets or keys (or values) lists


 { left_side => 'KEY', 
   right_side => [ $UNKNOWN_TAG ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my $key = @{$rs}[0]->get_api; $key =~ s/^'//; $key =~ s/'$//;
		 $ls->set_api([ $key ])}},

 { left_side => "KEY'", 
   right_side => [ 'COORD', 'KEY'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(
		     [ @{@{$rs}[1]->get_api} ]);}},

 { left_side => "KEY'", 
   right_side => [ 'COORD', "KEY''"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(
		     [ @{@{$rs}[1]->get_api} ]);}},

 { left_side => "KEY''", 
   right_side => [ 'KEY', "KEY'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(
		     [ @{@{$rs}[0]->get_api}, @{@{$rs}[1]->get_api} ]);}},

 { left_side => 'KEY_VALUE', 
   right_side => [ $UNKNOWN_TAG, 'EQUAL', $UNKNOWN_TAG],
   cb   => sub { my ($ls,$rs) = @_; 
		 my $key = @{$rs}[0]->get_api; $key =~ s/^'//; $key =~ s/'$//;
		 my $value = @{$rs}[2]->get_api; $value =~ s/^'//; $value =~ s/'$//;
		 $ls->set_api({ $key => $value })}},

 { left_side => 'KEY_VALUE', 
   right_side => [ $UNKNOWN_TAG, 'EQUAL', "KEY''"],
   cb   => sub { my ($ls,$rs) = @_; 
		 my $key = @{$rs}[0]->get_api; $key =~ s/^'//; $key =~ s/'$//;
		 $ls->set_api({ $key => @{$rs}[2]->get_api })}},

 { left_side => "KEY_VALUE'", 
   right_side => [ 'COORD', 'KEY_VALUE'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => "KEY_VALUE'", 
   right_side => [ 'COORD', "KEY_VALUE''"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => "KEY_VALUE''", 
   right_side => [ 'KEY_VALUE', "KEY_VALUE'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({%{@{$rs}[0]->get_api}, %{@{$rs}[1]->get_api} });}},

 { left_side => "PARENTHESIS", 
   right_side => [ 'OP', "KEY_VALUE", 'CP' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => "PARENTHESIS", 
   right_side => [ 'OP', "KEY_VALUE''", 'CP' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => "PARENTHESIS", 
   right_side => [ 'OP', "LOGICAL''", 'CP' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => "LOGICAL'", 
   right_side => [ 'LOGICAL', "KEY_VALUE" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ @{$rs}[0]->get_api  => [%{@{$rs}[1]->get_api}] });}},

 { left_side => "LOGICAL'", 
   right_side => [ 'LOGICAL', "KEY_VALUE''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ @{$rs}[0]->get_api  => ['-and' => [%{@{$rs}[1]->get_api}]] });}},

 { left_side => "LOGICAL'", 
   right_side => [ 'LOGICAL', "PARENTHESIS" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ @{$rs}[0]->get_api  => [%{@{$rs}[1]->get_api}] });}},

 { left_side => "LOGICAL'", 
   right_side => [ 'LOGICAL', "LOGICAL''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ @{$rs}[0]->get_api  => [%{@{$rs}[1]->get_api}] });}},

 { left_side => "LOGICAL''", 
   right_side => [ "KEY_VALUE", "LOGICAL'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my @ops = keys  %{@{$rs}[1]->get_api};
		 my $op = $ops[0];
		 my $api = @{$rs}[1]->get_api;
		 unshift @{$api->{$op}}, %{@{$rs}[0]->get_api};
		 $ls->set_api($api);}},

 { left_side => "LOGICAL''", 
   right_side => [ "KEY_VALUE''", "LOGICAL'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my @ops = keys  %{@{$rs}[1]->get_api};
		 my $op = $ops[0];
		 my $api = @{$rs}[1]->get_api;
		 unshift @{$api->{$op}}, %{@{$rs}[0]->get_api};
		 $ls->set_api($api);}},

 { left_side => "LOGICAL''", 
   right_side => [ "PARENTHESIS", "LOGICAL'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my @ops = keys  %{@{$rs}[1]->get_api};
		 my $op = $ops[0];
		 my $api = @{$rs}[1]->get_api;
		 unshift @{$api->{$op}}, %{@{$rs}[0]->get_api};
		 $ls->set_api($api);}},

# PHRASES

# PREPOSITIONAL PHRASES

# WITH marks key/values sets as arguments
# Ex: SET vms 1,2,3 WITH user_id=2
 
 { left_side => 'WITH', 
   right_side => [ 'with', 'KEY_VALUE' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ arguments => @{$rs}[1]->get_api });}},

 { left_side => 'WITH', 
   right_side => [ 'with', "KEY_VALUE''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ arguments => @{$rs}[1]->get_api });}},

# AS introduces a list of keys to be assigned as tags
# Ex: TAG dis 2 AS default

 { left_side => 'AS', 
   right_side => [ 'as', 'KEY' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

 { left_side => 'AS', 
   right_side => [ 'as', "KEY''" ],
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

 { left_side => 'BY', 
   right_side => [ 'by', "KEY''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},

# OF is uses as a join element that joins a qvd object with an explicit list
# of fields to be retrieved
# Ex: GET tenant_id, name OF vms 2,3,4

 { left_side => 'OF', 
   right_side => ['of'],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[0]->get_api);}},

# IN

 { left_side => 'IN', 
   right_side => [ 'in', "QVD_OBJECT'" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api(@{$rs}[1]->get_api);}},


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
   right_side => [ 'QVD_OBJECT', "KEY_VALUE" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

 { left_side => "QVD_OBJECT'", 
   right_side => [ 'QVD_OBJECT', "KEY_VALUE''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

 { left_side => "QVD_OBJECT'", 
   right_side => [ 'QVD_OBJECT', "LOGICAL''" ],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ qvd_object => @{$rs}[0]->get_api->{qvd_object},
                            filters => @{$rs}[1]->get_api });}},

 { left_side => "QVD_OBJECT''", 
   right_side => ['KEY', 'OF', "QVD_OBJECT'"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ fields => @{$rs}[0]->get_api, %{@{$rs}[2]->get_api}});}},

 { left_side => "QVD_OBJECT''", 
   right_side => ["KEY''", 'OF', "QVD_OBJECT'"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ fields => @{$rs}[0]->get_api, %{@{$rs}[2]->get_api}});}},

 { left_side => "QVD_OBJECT''", 
   right_side => ["KEY", 'OF', "LOGICAL''"],
   cb   => sub { my ($ls,$rs) = @_; 
		 $ls->set_api({ fields => @{$rs}[0]->get_api, %{@{$rs}[2]->get_api}});}},

 { left_side => "QVD_OBJECT''", 
   right_side => ["KEY''", 'OF', "LOGICAL''"],
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
   right_side => [ 'new', 'QVD_OBJECT' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my $api = { command => 'create', %{@{$rs}[1]->get_api}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'new', 'QVD_OBJECT', 'WITH' ],
   cb   => sub { my ($ls,$rs) = @_; 
		 my $api = { command => 'create', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'CMD', "QVD_OBJECT'" ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api = { %{@{$rs}[0]->get_api},%{@{$rs}[1]->get_api}}; 
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''", 'IN', 'ORDER_BY' ],
   cb   => sub { my ($ls,$rs) = @_;		 
		 my $api = { command => 'get', %{@{$rs}[1]->get_api}, %{@{$rs}[3]->get_api}};
		 forze_operative_filter_for_acls($api);
		 set_api_action_for_indirect_relations($api,@{$rs}[2]->get_api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''", 'IN' ],
   cb   => sub { my ($ls,$rs) = @_;		 
		 my $api = { command => 'get', %{@{$rs}[1]->get_api}};
		 forze_operative_filter_for_acls($api);
		 set_api_action_for_indirect_relations($api,@{$rs}[2]->get_api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'IND_CMD', "QVD_OBJECT'", 'TO' ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api = { %{@{$rs}[0]->get_api}, %{@{$rs}[2]->get_api}};
		 set_api_nested_query($api,@{$rs}[1]->get_api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'DIT_CMD', "QVD_OBJECT'", 'AS' ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api = { %{@{$rs}[0]->get_api}, %{@{$rs}[1]->get_api}};
		 set_api_nested_query($api,{ qvd_object => 'di_tag', filters => @{$rs}[2]->get_api });
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''" ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api = { command => 'get', %{@{$rs}[1]->get_api} };
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', "QVD_OBJECT''", 'ORDER_BY' ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api = { command => 'get', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}}; 
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'set', "QVD_OBJECT'", 'WITH' ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api =  { command => 'update', %{@{$rs}[1]->get_api}, %{@{$rs}[2]->get_api}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'set', 'CONFIG', "KEY_VALUE" ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api =  { qvd_object => 'config', command => 'update', 
			      arguments => { key => keys %{@{$rs}[2]->get_api}, 
					     value => values %{@{$rs}[2]->get_api}}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', 'CONFIG' ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api =  { qvd_object => 'config', command => 'get'};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', 'CONFIG', "KEY" ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api =  { qvd_object => 'config', command => 'get', 
			      filters => { key => ${@{$rs}[2]->get_api}[0]}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},

 { left_side => 'ROOT', 
   right_side => [ 'get', 'CONFIG', "KEY''" ],
   cb   => sub { my ($ls,$rs) = @_;
		 my $api =  { qvd_object => 'config', command => 'get', 
			      filters => { key => @{$rs}[2]->get_api}};
		 set_api_action_basic($api);
		 $ls->set_api($api);}},


];


my $COMMAND_TO_API_ACTION_MAPPER =
{
    get => { di_tag => 'tag_get_list',
	     config => 'config_get',
	     vm => 'vm_get_list', 
	     user => 'user_get_list', 
	     host => 'host_get_list', 
	     osf => 'osf_get_list', 
	     di => 'di_get_list', 
	     tenant => 'tenant_get_list',
	     role => 'role_get_list',
	     acl => 'acl_get_list',
	     admin => 'admin_get_list' },
    
    update => { config => 'config_set',
		vm => 'vm_update', 
		user => 'user_update', 
		host => 'host_update', 
		osf => 'osf_update', 
		di => 'di_update', 
		tenant => 'tenant_update',
		role => 'role_update',
		admin => 'admin_update' },

    create => { vm => 'vm_create', 
		user => 'user_create', 
		host => 'host_create', 
		osf => 'osf_create', 
		di => 'di_create', 
		tenant => 'tenant_create',
		role => 'role_create',
		admin => 'admin_create' },
	   
    delete => { vm => 'vm_delete', 
		user => 'user_delete', 
		host => 'host_delete', 
		osf => 'osf_delete', 
		di => 'di_delete', 
		tenant => 'tenant_delete',
		role => 'role_delete',
		admin => 'admin_delete' },
	   
    start => { vm => 'vm_start'}, 

    stop => { vm => 'vm_stop'}, 

    disconnect => { vm => 'vm_user_disconnect'}, 

    assign => { vm => 'vm_update', 
		user => 'user_update', 
		host => 'host_update', 
		osf => 'osf_update', 
		di => 'di_update', 
		tenant => 'tenant_update',
		role => 'role_update',
		admin => 'admin_update' },

    unassign => { vm => 'vm_update', 
		  user => 'user_update', 
		  host => 'host_update', 
		  osf => 'osf_update', 
		  di => 'di_update', 
		  tenant => 'tenant_update',
		  role => 'role_update',
		  admin => 'admin_update' },
};


my $COMMAND_TO_API_NESTED_QUERY_MAPPER = {

    assign => { property => [qw(__properties_changes__ set), {}], 
		di_tag => [qw(__tags_changes__ create), []], 
		role => [qw(__roles_changes__ assign_roles), []], 
		acl => [qw(__acls_changes__ assign_acls), []] },

    unassign => { property => [qw(__properties_changes__ delete), {}], 
		  di_tag => [qw(__tags_changes__ delete), []],
		  role => [qw(__roles_changes__ unassign_roles), []], 
		  acl => [qw(__acls_changes__ unassign_acls), []]}
};


my $COMMAND_TO_API_INDIRECT_ACTION_MAPPER =
{
    acl => { role => 'get_acls_in_roles',
	     admin => 'get_acls_in_admins'},
    role => { admin => 'role_get_list' },

    user => { tenant => 'user_get_list' },
    vm => { tenant => 'vm_get_list', 
	    user => 'vm_get_list',
	    host => 'vm_get_list',
            osf => 'vm_get_list',
            di => 'vm_get_list'},
    osf => {  tenant => 'osf_get_list'},
    di => { tenant => 'di_get_list',
	    osf => 'di_get_list'},

    di_tag => { osf => 'tag_get_list', 
		di => 'tag_get_list'}

};

my $OBJECT_PAIRS_RELATORS = {

    acl => { role => 'role_id',
	     admin => 'admin_id'},
    role => { admin => 'admin_id' },

    user => { tenant => 'tenant_id'},
    vm => { tenant => 'tenant_id',
	    user => 'user_id',
	    host => 'host_id',
            osf => 'osf_id',
            di => 'di_id'},
    osf => { tenant => 'tenant_id'},
    di => { tenant => 'tenant_id',
            osf => 'osf_id'},
    di_tag => { osf => 'osf_id', 
		di => 'di_id'}
};


sub get_api_action
{
    my %args = @_;
    my $action = eval { 
	$COMMAND_TO_API_ACTION_MAPPER->{$args{command}}->{$args{qvd_object}} 
    }; 
    $action;
}

sub get_api_indirect_action
{
    my @qvd_objects = @_;
    my $action = eval { 
	$COMMAND_TO_API_INDIRECT_ACTION_MAPPER->{$qvd_objects[0]}->{$qvd_objects[1]}  
    }; 
    $action;
}

sub get_api_nested_query
{
    my %args = @_;
    my $nested_q_info = eval { 
	$COMMAND_TO_API_NESTED_QUERY_MAPPER->{$args{command}}->{$args{qvd_object}} 
    }; 
    @$nested_q_info;

}

sub get_api_object_pair_relator
{
    my @qvd_objects = @_;

    my $relator = eval { 
	$OBJECT_PAIRS_RELATORS->{$qvd_objects[0]}->{$qvd_objects[1]} 
    }; 
    $relator;
}

sub set_api_action_basic
{
    my $api = shift;
    $api->{action} = get_api_action( 
	qvd_object => delete $api->{qvd_object}, 
	command => delete $api->{command});
}

sub set_api_nested_query
{
    my ($api,$ind_qvd_obj) = @_;

    my ($nq_type,$nq_action,$nq_type_of_value) =
	get_api_nested_query(command => $api->{command},
			     qvd_object => $ind_qvd_obj->{qvd_object});

    eval { $api->{arguments}->{$nq_type}->{$nq_action} = 
	       ref($nq_type_of_value) eq ref($ind_qvd_obj->{filters}) ? 
	       $ind_qvd_obj->{filters} : [values %{$ind_qvd_obj->{filters}}] }; 

    set_api_action_basic($api);
}

sub set_api_action_for_indirect_relations
{
    my ($api,$ind_qvd_obj) = @_;
    my $qvd_object =  delete $api->{qvd_object};
    my $type_of_action =  delete $api->{command};
    my $relator = get_api_object_pair_relator($qvd_object,$ind_qvd_obj->{qvd_object});
    eval {  $api->{filters}->{$relator} = $ind_qvd_obj->{filters}->{id};
	    $api->{action} = get_api_indirect_action($qvd_object,$ind_qvd_obj->{qvd_object}) };
}

sub forze_operative_filter_for_acls
{
    my $api = shift;
    return unless $api->{qvd_object} eq 'acl';
    $api->{filters}->{operative} = 1;
}

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

