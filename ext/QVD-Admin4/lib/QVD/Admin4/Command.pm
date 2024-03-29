package QVD::Admin4::Command;
use strict;
use warnings;
use base qw( CLI::Framework::Command::Meta );
use Text::SimpleTable::AutoWidth;
use Text::UnicodeTable::Simple;
use Mojo::URL;
use Mojo::JSON qw(encode_json decode_json j);
use Mojo::IOLoop;
use Mojo::Message::Response;
use Encode;
use File::Basename qw(basename dirname);
use Term::ReadKey;
use CLI::Framework::Exceptions;
use utf8::all;
use POSIX;

our $COMMON_USAGE_TEXT = "
======================================================================================================
                                             DEFAULT FILTERS
======================================================================================================

  The filter key 'name', and the operator '=' are consirered as defaults. So the following is a right 
  syntax: 
  
  <QVD OBJECT COMMAND> <QVD OBJECT NAME> <ACTION COMMAND>

  For example:
  vm myVM get (Equal to vm name=myVM get)  
  vm myVM set name=yourVM (Equal to vm name=myVM set name=yourVM)   

======================================================================================================
                                             COMPLEX FILTERS
======================================================================================================

  A filter is a key/value pair. Key and value can be related by means of different kinds of 
  IDENTITY OPERATORS (=, >, <, etc.). Different operators allow different kinds of values 
  (numeric, alphanumeric, arrays, ranges...). Morover, two or more filters can be joined by means 
  of LOGICAL OPERATORS (coordination, disjunction and negation operators).

  DIFFERENT IDENTITY OPERATORS:
  Supported operators:

  =  (equal)
  != (not equal)
  <  (less than)
  >  (greater that)
  <= (less or equal than)
  >= (greater or equal than)
  ~  (matches with a commodins expression: the SQL LIKE operator)

  For example:
  key1 = 1, 
  key1 < 3, 
  key1 > 3, 
  key1 <= 3, 
  key1 >= 3
  key1 = [1,2,3] (key1 must be in (1, 2, 3))
  key1 = [1:3] (key1 must be between 1 and 3)
  key1 = This_is_a_chain
  key1 = 'This is a chain' (A value with blanks must be quoted)
  key1 = \"This is a chain\" (A value with blanks must be quoted)
  key1 ~ %s_is_a_ch% (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ '%s is a ch%' (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ \"%s is a ch%\" (key1 must match the SQL commodins expression %s_is_a_ch%)

  LOGICAL OPERATORS
  Supported operators

  , (the AND operator)
  ; (the OR operator)
  ! (the NOT operator)

  (These operators have left precedence. In order to override this behaviour you must 
   grup filters with '(' and ')')

  For example:
  key1=value, key2=value, key3=value (key1 AND key2 AND key3)
  (key1=value; key2=value), key3=value ((key1 OR key2) AND key3))
  !key1=value (This expresion means: NOT key1)
  !key1=value, key2=value, key3=value (NOT ( key1 AND key2 AND key3))
  (! key1=value), key2=value, key3=value ((NOT key1) AND key2 AND key3))
  
  ORDER CRITERIA
  asc  (Orders in ascendent order)
  desc (Orders in descendent order)
  
  For example:
  asc key1

======================================================================================================
";


###############
## VARIABLES ##
###############


# Alias for retrieved fields

my $FIELDS = {
    vm => {
        user => 'user_name',
        osf => 'osf_name',
        tag => 'di_tag',
        host =>  'host_name',
        di => 'di_name',
        tenant =>  'tenant_name',
        di_in_use => 'di_name_in_use',
    },
    
    user => {
        tenant => 'tenant_name',
    },
    
    host => {
        ip_address => 'address',
    },
    
    osf => {
        tenant =>  'tenant_name',
    },
    
    di => {
        name => 'disk_image',
        osf => 'osf_name',
        tenant => 'tenant_name',
    },
    
    tenant => {
    },
    
    config => {
        default => 'default_value',
        value => 'operative_value'
    },
    
    admin => {
        tenant => 'tenant_name',
    },
    
    role => {
    },
    
    acl => {
    },
    
    log => {
    },
    
};

# Alias for order fields

my $ORDER = $FIELDS;

# Alias for arguments

my $ARGUMENTS = {
    vm => {
        tag => 'di_tag',
    },
    
    user => {
    },
    
    host => {
        ip_address => 'address',
    },
    
    osf => {
    },
    
    di => {
    },
    
    tenant => {
    },
    
    config => {
    },
    
    admin => {
    },
    
    role => {
    },
};

# For every field to retrieve, a callback can be specified.
# When the CLI returns that field, it executes the corresponding
# callback, that processes the original field retrieved by the API
# before it is printed in console

my $FIELDS_CBS = {
	di => {
		tags => sub {
			my $tags = shift;
			  my @tags = map { $_->{tag} } @$tags; 
			return join ', ', @tags;
		}
	},

	admin => {
		roles => sub {
			my $roles = shift;
			      my @roles =  values %$roles; 
			return join "\n", @roles;
		}
	},

	role => {
		roles => sub {
			my $roles = shift;
			     my @roles = map { $_->{name} } values %$roles; 
			return join "\n", @roles;
		},

		acls =>  sub {
			my $acls = shift;
			     my @acls = sort( (map { "$_ (+)" } @{$acls->{positive}}),
					       (map { "$_ (-)" } @{$acls->{negative}})); 
			return join "\n", @acls;
		}
	},
};

# This variable stores the relation between CLI queries
# and the corresponding actions in API

my $CLI_CMD2API_ACTION = {
	# qvd_object => kind_of_action => API action
	vm => {
		ids => 'vm_get_list',
	    get => 'vm_get_list', 
	    update => 'vm_update', 
	    create => 'vm_create', 
	    delete => 'vm_delete', 
	    start => 'vm_start', 
	    stop => 'vm_stop', 
		disconnect => 'vm_user_disconnect'
	},

	user => {
		ids => 'user_get_list',
	      get => 'user_get_list', 
	      update => 'user_update', 
	      create => 'user_create', 
		delete => 'user_delete'
	},

	host => {
		ids => 'host_get_list',
	      get => 'host_get_list', 
	      update => 'host_update', 
	      create => 'host_create', 
		delete => 'host_delete'
	},

	osf => {
		ids => 'osf_get_list',
	     get => 'osf_get_list', 
	     update => 'osf_update', 
	     create => 'osf_create', 
		delete => 'osf_delete'
	},

	di => {
		ids => 'di_get_list',
	    get => 'di_get_list', 
	    update => 'di_update', 
	    create => 'di_create', 
		delete => 'di_delete'
	},

	tenant => {
		ids => 'tenant_get_list',
		get => 'tenant_get_list', 
		update => 'tenant_update', 
		create => 'tenant_create', 
		delete => 'tenant_delete'
	},

	config => {
		get => 'config_get',
		update => 'config_set', 
		ssl     => 'config_ssl',
		delete => 'config_delete', 
	},

	admin => {
		ids => 'administrator_get_list',
	       get => 'administrator_get_list', 
	       update => 'administrator_update', 
	       create => 'administrator_create', 
		delete => 'administrator_delete'
	},

	role => {
		ids => 'role_get_list',
	      get => 'role_get_list', 
	      update => 'role_update', 
	      create => 'role_create', 
		delete => 'role_delete'
	},

    acl => { get => 'acl_get_list' }, 

    log => { get => 'log_get_list' },

    property => {
        ids    => 'property_get_list',
        get    => 'property_get_list',
        update => 'property_update',
        create => 'property_create',
        delete => 'property_delete',
    },

};

# Default lists of fields that must be displayed
# in console for every kind of qvd object

my $DEFAULT_FIELDS = {

    vm => [ qw( id name blocked user host di ip ip_in_use di_in_use state user_state ) ],

    user => [ qw( id name blocked number_of_vms number_of_vms_connected ) ],

    host => [ qw( id name blocked address frontend backend state number_of_vms_connected ) ],

    osf => [ qw( id name overlay user_storage memory tenant number_of_vms number_of_dis ) ],

    di => [ qw( id name version osf blocked tags state ) ],

	tenant => [ qw( id name language block blocked) ],

    config => [ qw( key value default is_default ) ],

    admin => [ qw(id name language block) ],

    role => [ qw(id name fixed internal) ],

    acl => [ qw(id name) ],

    log => [qw(time admin_name type_of_action qvd_object object_name status)],

    property => [qw(id key description)],
};

##############################################################
## METHOD RUN (to be executed when a command is introduced) ##
##############################################################

sub run 
{
    my ($self, $opts, @args) = @_;

    # Generate a QVD::Admin4::Grammar::Response
    my $parsing = $self->parse_string(@args); # It parses the input CLI query

    if ($parsing->command eq 'get')  # For display queries
    {
        $self->_get($parsing);
    }
    elsif ($parsing->command eq 'create') # For creation queries
    {
        $self->_create($parsing);
    }
    elsif ($parsing->command eq 'can') # For queries that check the acls of an admin or role
    {
        $self->_can($parsing);
    }
    elsif ($parsing->command eq 'assign')
    {
        $self->_assign($parsing);
    }
    elsif ($parsing->command eq 'unassign')
    {
        $self->_unassign($parsing);
    }
    else # For other queries (update/delete/...)
    {
        $self->_cmd($parsing);
    }
}

# Function used to execute a displaying query

sub _get 
{
    my ($self,$parsing) = @_;                       # Takes a parsed query
    my $query = $self->make_api_query($parsing);    # Creates a JSON query in API format 
	$self->execute_and_display_query($query,$parsing); # Ask the API and prints a table in pagination mode
}

# Function to execute a creation table

sub _create 
{
    my ($self,$parsing) = @_; # Takes parsed query

    # FIXME: This change shall be done by the API
    # If needed, it switchs from tenant name to tenant id
    if (my $tenant_name = $parsing->arguments->{tenant})
    {
        my $tenant_ids = $self->ask_for_ids('tenant', { name => $tenant_name });
        my $tenant_id = shift @$tenant_ids //
            CLI::Framework::Exception->throw("Unknows Tenant called $tenant_name");
        $parsing->arguments->{tenant} = $tenant_id;
    }

    my $query = $self->make_api_query($parsing);# Creates a JSON query in API format 
    my $res = $self->ask_api_standard($self->get_app->cache->get('api_default_path'), $query);
    $self->print_table($res,$parsing);
}

# Function executed for queries that check the acls of an admin or role

sub _can
{
    my ($self,$parsing) = @_;

    # It gets the id of the involved role or admin
    my $ids = $self->ask_for_ids($parsing->qvd_object, $self->get_filters($parsing));

    # It created an ad hoc JSON query
    my $acl_name = $parsing->parameters->{acl_name}; 
    my $id_key = $parsing->qvd_object eq 'admin' ? 'admin_id' : 'role_id';
    my $filters = { $id_key => $ids, operative => 1 }; 
    $filters->{acl_name} = { 'LIKE' => $acl_name } if defined $acl_name;
    my $action = $parsing->qvd_object eq 'admin' ? 'get_acls_in_admins' : 'get_acls_in_roles';
    my $query = { action => $action,filters => $filters,order_by => $self->get_order($parsing)};

    # It creates an ad hoc displaying query  
    $parsing = QVD::Admin4::Grammar::Response->new(
	response => { command => 'get', obj1 => { qvd_object => 'acl' }});

	$self->execute_and_display_query($query,$parsing); # Ask the API and prints a table in pagination mode
}

# Function intended to execute update, delete and the rest of actions.
# All these actions must include an id filter in API. So, firstly,
# the corresponding ids are requested to API, and then the update/delete
# request is performed

sub _cmd
{
    my ($self,$parsing) = @_;

    # It gets all the ids correspondig the objects that must
    # be deleted/updated

    my $filters = $self->get_filters($parsing);

    unless (keys %$filters or $parsing->qvd_object eq 'config') {
        if ($self->get_app->is_interactive_mode_enabled()) {
            print STDERR "Are you sure you want to apply this operation to all the elements? (y/n)\n";
            chomp(my $response = <STDIN>);
            if($response ne 'y') {
                CLI::Framework::Exception->throw('Operation aborted');
            }
        } else {
            if(!$self->get_app->is_force_enabled()) {
                CLI::Framework::Exception->throw('Use --force flag to perform operations with no filters');
            }
        }
    }

    my $ids = eval { $self->ask_for_ids($parsing->qvd_object, $filters) };
    $filters = { id => { '=' => $ids }} if defined $ids;

    # It performs the update/delete over the objects with those ids

    my $res = $self->ask_api_standard(
        $self->get_app->cache->get('api_default_path'),
        {
            action => $self->get_action($parsing),
            filters => $filters,
            order_by => $self->get_order($parsing),
            arguments => $self->get_arguments($parsing)
        }
    );

    # The API response is printed

    $self->print_table($res,$parsing);
}

# Function intended to execute assign command

sub _assign
{
    my ($self,$parsing) = @_;

    my $ids = eval { $self->ask_for_ids($parsing->qvd_object, $self->get_filters($parsing)) };
    CLI::Framework::Exception->throw('Ambiguous filter, several properties returned') if @$ids > 1;
    CLI::Framework::Exception->throw('No property matches the filter') if @$ids == 0;

    my $id = shift @$ids;

    my $settings = {};
    if($parsing->qvd_object eq 'property') {
        $settings = {
            action    => $parsing->arguments->{object}."_create_property_list",
            arguments => { property_id => $id }
        };
    } else {
        $settings = {
            action    => $self->get_action($parsing),
            filters   => $self->get_filters($parsing),
            arguments => $self->get_arguments($parsing)
        };
    }

    my $res = $self->ask_api_standard($self->get_app->cache->get('api_default_path'), $settings);

    # The API response is printed
    $self->print_table($res,$parsing);
}

# Function intended to execute assign command

sub _unassign
{
    my ($self,$parsing) = @_;

    my $ids = eval { $self->ask_for_ids($parsing->qvd_object, $self->get_filters($parsing)) };
    CLI::Framework::Exception->throw('Ambiguous filter, several properties returned') if @$ids > 1;
    CLI::Framework::Exception->throw('No property matches the filter') if @$ids == 0;

    my $id = shift @$ids;

    my $settings = {};
    if($parsing->qvd_object eq 'property') {
        $settings = {
            action    => $parsing->arguments->{object}."_delete_property_list",
            filters => { property_id => $id }
        };
    } else {
        $settings = {
            action    => $self->get_action($parsing),
            filters   => $self->get_filters($parsing)
        };
    }

    my $res = $self->ask_api_standard($self->get_app->cache->get('api_default_path'), $settings);

    # The API response is printed
    $self->print_table($res,$parsing);
}

# Function intended to execute a query in pagination mode.
# It sets the console in pagination mode and asks the API and
# prints a new table for every new page.

sub execute_and_display_query
{
    my ($self,$query,$parsing) = @_;
	my $app = $self->get_app;

	my $is_pagination_mode_enabled = ($app->get_interactivity_mode() ? 1 : 0);

    ReadMode("cbreak"); # This sets the pagination mode in console

    # Current pagination parameters setted
	if($is_pagination_mode_enabled) {
		$query->{offset} = 1;
    $query->{block} =  $app->cache->get('block');
	}

	my ($pause_time, $char);
	do {

    # It asks the API for the first page and prints that first page
    my $res = $self->ask_api_standard($self->get_app->cache->get('api_default_path'), $query); 
    $self->print_table($res,$parsing); 

		if ($is_pagination_mode_enabled) {
			my $total_pages = ceil($res->json('/total') / $query->{block});
			print STDOUT "--- page $query->{offset} / $total_pages\n";
            $app->set_help_message("Press ('n' for next, 'b' for back, 'q' for quit) ---");
			print STDOUT $app->help_message . "\n";

			$char = ReadKey($pause_time);
            
            # Pagination parameters updated
			$query->{offset}++ if ($char eq 'n' && $query->{offset} < $total_pages);
			$query->{offset}-- if ($char eq 'b' && $query->{offset} > 1);
    }

	} while ($is_pagination_mode_enabled && (defined($char)) && ($char ne 'q'));

    $app->set_help_message(undef);

    ReadMode(0); # Return to normal mode in console 
}


###############################################
## METHODS TO PRINT RESPONSES IN CONSOLE RUN ##
###############################################

# It takes the response of the API and the original query
# According to fields asked in the query, it prints in a 
# table in console the info stored in the API response

sub getDisplayTableMode {
	my $self = shift;
	return ($self->get_app->cache->get('display_mode') // "TABLE");
}

sub print_table
{
	my ($self, $res, $parsing) = @_;

	my @fields = $self->get_fields_from_response($parsing, $res);

	my $n = 0;
	my @values = ();
	while (my $field = $res->json("/rows/$n"))
	{
		$values[$n] = [ map {
			$self->get_field_value($parsing, $field, $_) // ''
		} @fields ];
		$n++;
	}

	my $display_mode = $self->getDisplayTableMode();
	if ($display_mode eq "CSV") {
		if (@fields) {
			print join(";", @fields)."\n";
			for ($n = 0; $n < @values; $n++) {
				print join(";", @{$values[$n]} )."\n";
			}
		} else {
			print STDOUT "total\n";
			print STDOUT $res->json('/total')."\n";
		}
	} elsif ($display_mode eq "TABLE") {
		if(@fields) {
			my $tb = Text::UnicodeTable::Simple->new();

			$tb->set_header(@fields);
			for ($n = 0; $n < @values; $n++) {
				$tb->add_row( $values[$n] );
			}

			print STDOUT "$tb";
		}
		print STDOUT "Total: ".$res->json('/total')."\n";
	} else {
		print STDOUT "Unknown format $display_mode\n";
	}
}

#######################################
## METHODS TO PARSE THE INPUT STRING ##
#######################################

sub parse_string
{
    my ($self,@args) = @_;
    my $req = join(' ',@args);
    my $app = $self->get_app;

    # This code gets the parsers from the CLI settings

    my ($tokenizer,$parser) = 
	($app->cache->get('tokenizer'), 
	 $app->cache->get('parser'));

    # First parsing stage, tokenization: 
    # from string to list of words
    my $tokenization = $tokenizer->parse($req);

    $self->unrecognized($tokenization) &&
	CLI::Framework::Exception->throw('Unable to tokenize request');

    # Second parsing stage, parsing:
    # syntactic analysis
    my $parsing = $parser->parse( shift @$tokenization ); # This is a list of analysis

    $self->unrecognized($parsing) &&
	CLI::Framework::Exception->throw('Unable to parse request');
    $self->ambiguous($parsing) &&
	CLI::Framework::Exception->throw('Ambiguos request');

    shift @$parsing; 
}

sub unrecognized
{
    my ($self,$response) = @_;
    scalar @$response < 1 ? return 1 : 0; 
}

sub ambiguous
{
    my ($self,$response) = @_;
    scalar @$response > 1 ? return 1 : 0; 
}

##################################################
## METHODS TO PERFORM A REQUEST AGAINST THE API ##
##################################################

# Method for standard queries to the API

sub ask_api_standard
{
    my ($self, $path, $query) = @_;

    my $ua = $self->get_app->cache->get('user_agent');
    my $credentials = $self->get_credentials();
    my $url = Mojo::URL->new($self->get_app->cache->get('api_url'));
    $url->path($path // $self->get_app->cache->get('api_default_path'));
    $query //= {};

	my $res = $ua->post(
		"$url",
		json => {
			%$query, %$credentials, parameters => { source => 'CLI'}
		}
	)->res;

	CLI::Framework::Exception->throw($res->error->{message})
	unless $res->code;

    $self->check_api_result($res);

    return $res;
}

# Method to create a DI uploading the image from local

sub ask_api_di_upload
{
	my ($self, $query, $ua, $url, $credentials) = @_;

    my $file = $query->{arguments}->{disk_image};
    $query->{arguments}->{disk_image} = basename($file);
    $query->{arguments} = encode_json($query->{arguments});
    $query->{parameters} = encode_json({ source => 'CLI' });
    delete $query->{filters};
    delete $query->{fields};
    delete $query->{order_by};
    
    my $res; 
    Mojo::IOLoop->delay(
		sub {
			my $delay = shift;
			$ua->post(
				"$url",
				form => {
					%$query, %$credentials, file => { file => $file }
				},
				$delay->begin
			);
		},
		sub {
			my ($delay,$tx) = @_; $res = $tx->res;
		}
	)->wait;
    
    return $res;
}


sub check_api_result
{
    my ($self,$res) = @_;
    
    my $status =  $res->json('/status') // -1;
    return 1 if $status == 0; # Successful response

    my $message = $res->json('/message') // "Unknown";
    chomp($message);
    my $failures = $res->json('/failures');
    if (defined($failures)) {
        $message .= ":\n";
        while (my ($id,$failure) = each %$failures) {
            $message .= "\t$id : " . $failure->{message} . "\n";
        }
    }

    CLI::Framework::Exception->throw($message);
}

# Returns a list of IDs for a specific request or throws an exepction in case the IDs are not
# available or it is an invalid field
sub ask_for_ids
{
    my ($self, $qvd_object, $filter) = @_;

    if (my $action = $CLI_CMD2API_ACTION->{$qvd_object}->{'ids'}) {
        my $ids = [ map { $_->{id} } @{ $self->ask_api_standard(
            $self->get_app->cache->get('api_default_path'),
            {
                action => $action,
                filters => $filter,
                fields => ['id']
            }
        )->json('/rows') } ];
        
        return $ids;
    } else {
        CLI::Framework::Exception->throw("No API action can retrieve IDs for object ($qvd_object)");
    }
}

###################################################
## AUXILIAR METHODS TO CREATE THE JSON API QUERY ##
## FROM THE PARSING QUERY                        ##
###################################################

# Returns the corresponding action in API to the current
# request in CLI
sub get_action
{
    my ($self,$parsing) = @_;
    return eval { 
	$CLI_CMD2API_ACTION->{$parsing->qvd_object}->{$parsing->command} 
    } // CLI::Framework::Exception->throw("No API action available for request"); 
}

# Normalizes the filters in a request according the
# info in the class variables of this class. Returns the
# hash of normalized  filters
sub get_filters
{
    my ($self,$parsing) = @_;
    return $parsing->filters // {};
}

# Normalizes the arguments in a request according the
# info in the class variables of this class. Returns the
# hash of normalized arguments
sub get_arguments
{
    my ($self,$parsing) = @_;
    my $arguments_input = $parsing->arguments // {};
    my $arguments_output = {};

    while (my ($key,$value) = each %$arguments_input)
    {
        my $argument_name = eval { $ARGUMENTS->{$parsing->qvd_object}->{$key} } // $key;
        $arguments_output->{$argument_name} = $value;
    }

    return $arguments_output;
}

# Normalizes the ordering in a request according the
# info in the class variables of this class. Returns the
# hash of normalized ordering
sub get_order
{
    my ($self,$parsing) = @_;
    
    my $order = $parsing->order // {};
    my $criteria = $order->{field} // [];
    my $order_fields = [];
    
    for my $criterium (@$criteria)
    {
        my $order_field = eval { $ORDER->{$parsing->qvd_object}->{$criterium} } // $criterium;
        push @$order_fields, $order_field;
    }
    my $direction = $order->{order} // '-asc';
    
    { order => $direction, field => $order_fields };
}

# It returns the list of fields that must be retrieved by 
# an action
sub get_fields_from_response
{
    my ($self,$parsing,$api_res) = @_;

    return () unless $api_res->json('/rows');
    return qw(id) if $parsing->command eq 'create';
    return qw() unless $parsing->command eq 'get';

    my @asked_fields = @{$parsing->fields} ?
        @{$parsing->fields}  : @{$DEFAULT_FIELDS->{$parsing->qvd_object}};

    my @retrieved_fields;
    for my $asked_field (@asked_fields)
    {
        my $api_field = eval {
            $FIELDS->{$parsing->qvd_object}->{$asked_field}
        } // $asked_field;

        push @retrieved_fields, $api_field;
    }
    @retrieved_fields;
}

# Normalizes the fields to retrieve in a request according the
# info in the class variables of this class. Returns the
# hash of normalized fields
sub get_fields
{
    my ($self,$parsing) = @_;
    my $fields_input = $parsing->fields // {};
    my $fields_output = [];
    
    for my $key (@$fields_input)
    {
        my $field_name = eval { $FIELDS->{$parsing->qvd_object}->{$key} } // $key;
        push @$fields_output, $field_name;
    }
    
    return $fields_output;
}

# For a certain field retrieved by the API, it may need to be
# normalized or processed before it is displayed. This function gets the
# normalized value of the field, or the callback intended to process it 
# (if any). And returns the normalized value, or the output of that callback 
# for the current field 
sub get_field_value
{
    my ($self,$parsing,$api_res_obj,$cli_field) = @_;

    my $api_field = eval { $FIELDS->{$parsing->qvd_object}->{$cli_field} } // $cli_field;
    my $v = $api_res_obj->{$api_field};

    if (ref($v)) 
    {
	my $cb = eval { $FIELDS_CBS->{$parsing->qvd_object}->{$cli_field} }
	// die "No method available to parse complex field in API output";
	$v = $cb->($v);
    }
    return $v;
}

# Regular function to create a JSON query in the API format

sub make_api_query
{
    my ($self,$parsing) = @_;

    return {
        action => $self->get_action($parsing),
        filters => $self->get_filters($parsing),
        fields => $self->get_fields($parsing),
        order_by => $self->get_order($parsing),
        arguments => $self->get_arguments($parsing)
    };
}

# Other auxiliar functions

sub read_password
{
    my $self = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\n";
    $pass;
}


sub _read
{
    my ($self,$msg) = @_;
    print STDERR "$msg: ";
    my $read = <>; 
    chomp $read;
    print STDERR "\r";
    $read;
}


sub superadmin
{
    my $self = shift;
    my $app = $self->get_app;
    $app->cache->get('tenant_id') ? return 1 : return 0;
}

sub get_credentials
{
    my $self = shift;

    my $app = $self->get_app;

    my $login = $app->cache->get('login');
    my $password = $app->cache->get('password');
    my $tenant = $app->cache->get('tenant_name');
    my $sid = $app->cache->get('sid');
    
    # Added credentials to the JSON query

    my $credentials = defined $sid ?
        { sid => $sid } :
        { login => $login, password => $password };
    $credentials->{tenant} = $tenant if
        defined $tenant && defined $credentials->{login};
    
    return $credentials;
}

1;
