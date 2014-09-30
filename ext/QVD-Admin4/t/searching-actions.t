use Test::More;
use Test::Mojo;
use FindBin;
require "$FindBin::Bin/../bin/wat.pl";

my $t = Test::Mojo->new;


#################
### user_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_get_list',
			     filters    => { id => 5,
					     name => 'ben', 
					     blocked => 0,
#					     creation_admin => undef,
#					     creation_date => undef,
					     tenant_id => 1,
					     tenant_name => 'Madrid',
					     world => 'reality',
					     age => '30'}}) 
    ->status_is(200, 'user_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'user_get_list API STATUS')
    ->json_has('/result/rows/0/', 'user_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'user_get_list NO OVERGENERATE');

####################
### user_get_details
####################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_get_details',
			     filters    => { id => 5}}) 
    ->status_is(200, 'user_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'user_get_details API STATUS')
    ->json_has('/result/rows/0/', 'user_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'user_get_details NO OVERGENERATE');

#################
### user_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_all_ids',
			     filters    => { id => 5,
					     name => 'ben', 
					     blocked => 0,
#					     creation_admin => undef,
#					     creation_date => undef,
					     tenant_id => 1,
					     tenant_name => 'Madrid',
					     world => 'reality',
					     age => '30'}}) 
    ->status_is(200, 'user_all_ids HTTP STATUS')
    ->json_is('/status' => '0', 'user_all_ids API STATUS')
    ->json_is('/result/rows/0/', 5, 'user_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'user_all_ids NO OVERGENERATE');

##################
### user_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_tiny_list',
			     filters    => { tenant_id => 1}}) 
    ->status_is(200, 'user_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'user_tiny_list API STATUS')
    ->json_has('/result/rows/3/', 'user_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/4/' => 'user_tiny_list NO OVERGENERATE');

#################
### vm_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'vm_get_list',
			     filters    => { storage => undef, 
					     id => 4,
					     name => 'kkdevm', 
					     user_id => 5,
					     user_name => 'ben', 
					     osf_id => 1,
					     osf_name => 'Accountants',
					     di_tag => 'default',
					     blocked => 0,
					     expiration_soft => undef,
					     expiration_hard => undef,
					     state => 'stopped',
					     host_id => undef,
					     host_name => undef,
					     di_id => 5,
					     user_state => 'disconnected',
					     ip => '10.0.255.254',
					     next_boot_ip => undef,
					     ssh_port => undef,
					     vnc_port => undef,
					     serial_port => undef,
					     tenant_id => '1',
					     tenant_name => 'Madrid',
#					     creation_admin => undef,
#					     creation_date => undef,
					     world => 'qvd'}}) 
    ->status_is(200, 'vm_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'vm_get_list API STATUS')
    ->json_has('/result/rows/0/', 'vm_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'vm_get_list NO OVERGENERATE');


#################
### vm_get_details
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'vm_get_details',
			     filters    => { id => 4}}) 
    ->status_is(200, 'vm_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'vm_get_details API STATUS')
    ->json_has('/result/rows/0/', 'vm_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'vm_get_details NO OVERGENERATE');

#################
### vm_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'vm_all_ids',
			     filters    => { storage => undef, 
					     id => 4,
					     name => 'kkdevm', 
					     user_id => 5,
					     user_name => 'ben', 
					     osf_id => 1,
					     osf_name => 'Accountants',
					     di_tag => 'default',
					     blocked => 0,
					     expiration_soft => undef,
					     expiration_hard => undef,
					     state => 'stopped',
					     host_id => undef,
					     host_name => undef,
					     di_id => 5,
					     user_state => 'disconnected',
					     ip => '10.0.255.254',
					     next_boot_ip => undef,
					     ssh_port => undef,
					     vnc_port => undef,
					     serial_port => undef,
					     tenant_id => '1',
					     tenant_name => 'Madrid',
#					     creation_admin => undef,
#					     creation_date => undef,
					     world => 'qvd'}}) 
    ->status_is(200, 'vm_all_ids HTTP STATUS')
    ->json_is('/status' => '0', 'vm_all_ids API STATUS')
    ->json_is('/result/rows/0/', 4, 'vm_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'vm_all_ids NO OVERGENERATE');

##################
### vm_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'vm_tiny_list',
			     filters    => { tenant_id => 1}}) 
    ->status_is(200, 'user_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'vm_tiny_list API STATUS')
    ->json_has('/result/rows/1/', 'vm_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/2/' => 'vm_tiny_list NO OVERGENERATE');

#################
### host_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'host_get_list',
			     filters    => { id => 1,
					     name => 'QVD1',
					     address => '10.0.0.1',
					     blocked => 0,
					     frontend => 1,
					     backend => 1,
					     vm_id => undef,
#					     creation_admin => undef,
#					     creation_date => undef,
					     state => 'stopped',
                                             world => 'qvd'}}) 
    ->status_is(200, 'host_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'host_get_list API STATUS')
    ->json_has('/result/rows/0/', 'host_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'host_get_list NO OVERGENERATE');

#####################
### host_get_details
#####################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'host_get_details',
			     filters    => { id => 1}}) 
    ->status_is(200, 'host_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'host_get_details API STATUS')
    ->json_has('/result/rows/0/', 'host_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'host_get_details NO OVERGENERATE');

#################
### host_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'host_all_ids',
			     filters    => { id => 1,
					     name => 'QVD1',
					     address => '10.0.0.1',
					     blocked => 0,
					     frontend => 1,
					     backend => 1,
					     vm_id => undef,
#					     creation_admin => undef,
#					     creation_date => undef,
					     state => 'stopped',
                                             world => 'qvd'}}) 
    ->status_is(200, 'host_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'host_all_ids API STATUS')
    ->json_is('/result/rows/0/',1, 'host_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'host_all_ids NO OVERGENERATE');

##################
### host_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'host_tiny_list',
			     filters    => {}}) 
    ->status_is(200, 'host_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'host_tiny_list API STATUS')
    ->json_has('/result/rows/2/', 'host_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/3/' => 'host_tiny_list NO OVERGENERATE');

#################
### osf_get_list
#################


$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'osf_get_list',
			     filters    => { id => 1,
					     name => 'Accountants',
					     overlay => 1,
					     user_storage => 0,
					     memory => 256,
					     vm_id => 4,
					     di_id => 1,
					     tenant_id => 1,
					     tenant_name => 'Madrid' }}) 
    ->status_is(200, 'osf_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'osf_get_list API STATUS')
    ->json_has('/result/rows/0/', 'osf_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'osf_get_list NO OVERGENERATE');

###################
### osf_get_details
###################


$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'osf_get_details',
			     filters    => { id => 1 }}) 
    ->status_is(200, 'osf_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'osf_get_details API STATUS')
    ->json_has('/result/rows/0/', 'osf_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'osf_get_details NO OVERGENERATE');

#################
### osf_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'osf_all_ids',
			     filters    => { id => 1,
					     name => 'Accountants',
					     overlay => 1,
					     user_storage => 0,
					     memory => 256,
					     vm_id => 4,
					     di_id => 1,
					     tenant_id => 1,
					     tenant_name => 'Madrid' }}) 
    ->status_is(200, 'osf_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'osf_all_ids API STATUS')
    ->json_is('/result/rows/0/',1, 'osf_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'osf_all_ids NO OVERGENERATE');

##################
### osf_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'osf_tiny_list',
			     filters    => { tenant_id => 1 }}) 
    ->status_is(200, 'osf_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'osf_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'osf_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'osf_tiny_list NO OVERGENERATE');

#################
### di_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'di_get_list',
			     filters    => { id => 5,
					     disk_image => 'opensuse',
					     version => '2014-09-26-002',
					     osf_id => 1,
					     osf_name => 'Accountants',
					     tenant_id => 1,
					     blocked => 0,
					     tag => 'default',
					     tenant_name => 'Madrid',
                                             world => 'qvd'
}}) 
    ->status_is(200, 'di_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'di_get_list API STATUS')
    ->json_has('/result/rows/0/', 'di_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'di_get_list NO OVERGENERATE');


#################
### di_get_details
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'di_get_details',
			     filters    => { id => 5}}) 
    ->status_is(200, 'di_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'di_get_details API STATUS')
    ->json_has('/result/rows/0/','di_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'di_get_details NO OVERGENERATE');


#################
### di_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'di_all_ids',
			     filters    => { id => 5,
					     disk_image => 'opensuse',
					     version => '2014-09-26-002',
					     osf_id => 1,
					     osf_name => 'Accountants',
					     tenant_id => 1,
					     blocked => 0,
					     tag => 'default',
					     tenant_name => 'Madrid',
                                             world => 'qvd'
}}) 
    ->status_is(200, 'di_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'di_get_list API STATUS')
    ->json_is('/result/rows/0/', 5, 'di_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'di_get_list NO OVERGENERATE');

##################
### di_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'di_tiny_list',
			     filters    => { tenant_id => 1 }}) 
    ->status_is(200, 'di_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'di_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'di_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/3/' => 'di_tiny_list NO OVERGENERATE');

#################
### tag_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tag_get_list',
			     filters    => { osf_id => 1,
					     name => 'default',
					     id => 29}}) 
    ->status_is(200, 'tag_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'tag_get_list API STATUS')
    ->json_has('/result/rows/0/', 'tag_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tag_get_list NO OVERGENERATE');

###################
### tag_get_details
###################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tag_get_details',
			     filters    => { id => 29}}) 
    ->status_is(200, 'tag_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'tag_get_details API STATUS')
    ->json_has('/result/rows/0/', 'tag_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tag_get_details NO OVERGENERATE');

#################
### tag_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tag_all_ids',
			     filters    => { osf_id => 1,
					     name => 'default',
					     id => 29}}) 
    ->status_is(200, 'tag_all_ids HTTP STATUS')
    ->json_is('/status' => '0', 'tag_all_ids API STATUS')
    ->json_is('/result/rows/0/', 29, 'tag_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tag_all_ids NO OVERGENERATE');


##################
### tag_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tag_tiny_list',
			     filters    => { tenant_id => 1, osf_id => 1 }}) 
    ->status_is(200, 'tag_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'tag_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'tag_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/6/' => 'tag_tiny_list NO OVERGENERATE');


#################
### admin_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'admin_get_list',
			     filters    => { name => 'myadmin',
					     tenant_id => 1,
					     tenant_name => 'Madrid',
					     id => 5 }}) 
    ->status_is(200, 'admin_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'admin_get_list API STATUS')
    ->json_has('/result/rows/0/', 'admin_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'admin_get_list NO OVERGENERATE');

#####################
### admin_get_details
#####################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'admin_get_details',
			     filters    => { id => 5 }}) 
    ->status_is(200, 'admin_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'admin_get_details API STATUS')
    ->json_has('/result/rows/0/', 'admin_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'admin_get_details NO OVERGENERATE');

#################
### admin_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'admin_all_ids',
			     filters    => { name => 'myadmin',
					     tenant_id => 1,
					     tenant_name => 'Madrid',
					     id => 5 }}) 
    ->status_is(200, 'admin_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'admin_all_ids API STATUS')
    ->json_is('/result/rows/0/', 5, 'admin_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'admin_all_ids NO OVERGENERATE');


####################
### admin_tiny_list
####################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'admin_tiny_list',
			     filters    => { tenant_id => 1 }}) 
    ->status_is(200, 'admin_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'admin_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'admin_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/4/' => 'admin_tiny_list NO OVERGENERATE');

###################
### tenant_get_list
###################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tenant_get_list',
			     filters    => { name => 'Madrid', 
					     id => 1 }}) 
    ->status_is(200, 'tenant_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'tenant_get_list API STATUS')
    ->json_has('/result/rows/0/', 'tenant_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tenant_get_list NO OVERGENERATE');

######################
### tenant_get_details
######################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tenant_get_details',
			     filters    => { id => 1 }}) 
    ->status_is(200, 'tenant_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'tenant_get_details API STATUS')
    ->json_has('/result/rows/0/', 'tenant_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tenant_get_details NO OVERGENERATE');

###################
### tenant_all_ids
###################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tenant_all_ids',
			     filters    => { name => 'Madrid', 
					     id => 1 }}) 
    ->status_is(200, 'tenant_all_ids HTTP STATUS')
    ->json_is('/status' => '0', 'tenant_all_ids API STATUS')
    ->json_is('/result/rows/0/', 1, 'tenant_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'tenant_all_ids NO OVERGENERATE');

####################
### tenant_tiny_list
####################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'tenant_tiny_list',
			     filters    => {}}) 
    ->status_is(200, 'tenant_tiny_list HTTP STATUS')
    ->json_is('/status' => '0', 'tenant_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'tenant_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/3/' => 'tenant_tiny_list NO OVERGENERATE');

#################
### role_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'role_get_list',
			     filters    => { name => 'superpringao', 
					     id => 4 }}) 
    ->status_is(200, 'role_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'role_get_list API STATUS')
    ->json_has('/result/rows/0/', 'role_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'role_get_list NO OVERGENERATE');

#################
### role_get_details
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'role_get_details',
			     filters    => { id => 4 }}) 
    ->status_is(200, 'role_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'role_get_details API STATUS')
    ->json_has('/result/rows/0/', 'role_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'role_get_details NO OVERGENERATE');

#################
### role_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'role_all_ids',
			     filters    => { name => 'superpringao', 
					     id => 4 }}) 
    ->status_is(200, 'role_all_ids HTTP STATUS')
    ->json_is('/status' => '0', 'role_all_ids API STATUS')
    ->json_is('/result/rows/0/',4, 'role_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'role_all_ids NO OVERGENERATE');

##################
### role_tiny_list
##################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'role_tiny_list',
			     filters    => {}}) 
    ->status_is(200, 'role_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'role_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'role_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/5/' => 'role_tiny_list NO OVERGENERATE');

#################
### acl_get_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'acl_get_list',
			     filters    => { name => 'user_see', 
					     id => 1 }}) 
    ->status_is(200, 'acl_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'acl_get_list API STATUS')
    ->json_has('/result/rows/0/', 'acl_get_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'acl_get_list NO OVERGENERATE');

#################
### acl_get_details
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'acl_get_details',
			     filters    => { id => 1 }}) 
    ->status_is(200, 'acl_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'acl_get_details API STATUS')
    ->json_has('/result/rows/0/', 'acl_get_details NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'acl_get_details NO OVERGENERATE');

#################
### acl_all_ids
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'acl_all_ids',
			     filters    => { name => 'user_see', 
					     id => 1 }}) 
    ->status_is(200, 'acl_get_details HTTP STATUS')
    ->json_is('/status' => '0', 'acl_all_ids API STATUS')
    ->json_is('/result/rows/0/', 1, 'acl_all_ids NO UNDERGENERATE')
    ->json_hasnt('/result/rows/1/' => 'acl_all_ids NO OVERGENERATE');

#################
### acl_tiny_list
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'acl_tiny_list',
			     filters    => {}}) 
    ->status_is(200, 'acl_get_list HTTP STATUS')
    ->json_is('/status' => '0', 'acl_tiny_list API STATUS')
    ->json_has('/result/rows/0/', 'acl_tiny_list NO UNDERGENERATE')
    ->json_hasnt('/result/rows/4/' => 'acl_tiny_list NO OVERGENERATE');

##
done_testing();
##
###################################
###################################
###################################
##
#
