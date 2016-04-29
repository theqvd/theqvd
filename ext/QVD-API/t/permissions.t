use Test::More;
use Test::Mojo;
use FindBin;
require "$FindBin::Bin/../bin/wat.pl";

my $t = Test::Mojo->new;

################
## SUPERADMIN ##
################

#################
### Is able to do
#################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_get_list',
			     filters    => { name => 'ben'}}) 
    ->status_is(200, 'superadmin is able to do HTTP STATUS')
    ->json_is('/status' => '0', 'superadmin is able to do API STATUS');


$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_update',
			     filters    => { id => 5 },
			     arguments => { name => 'ben' }}) 
    ->status_is(200, 'user_update HTTP STATUS')
    ->json_is('/status' => '0', 'superadmin is able to do API STATUS');

######################
## Filters by tenant_id
######################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_get_list',
			     filters    => { tenant_id => '1'}}) 
    ->status_is(200, 'superadmin is able to do HTTP STATUS')
    ->json_is('/status' => '0', 'superadmin filters by tenant_id API STATUS')
    ->json_has('/result/rows/3/' => 'superadmin filters by tenant_id API STATUS')
    ->json_hasnt('/result/rows/4/' => 'superadmin filters by tenant_id API STATUS');

###################
## Sees all tenants
###################

$t->post_ok('/' => json => { login    => 'superadmin',              
		             password => 'superadmin',              
		             action   => 'user_get_list',
			     filters    => {}}) 
    ->status_is(200, 'superadmin sees all tenants HTTP STATUS')
    ->json_is('/status' => '0', 'superadmin sees all tenants API STATUS')
    ->json_has('/result/rows/5/' => 'superadmin sees all tenants API STATUS')
    ->json_hasnt('/result/rows/6/' => 'superadmin sees all tenants API STATUS')

####################
## Gets tenants info
####################

    ->json_has('/result/rows/0/tenant_id' => 'superadmin gets tenants info API STATUS')
    ->json_has('/result/rows/0/tenant_name' => 'superadmin gets tenants info API STATUS');

#################
## ADMIN TENANT 1
################# 

#################
### Is able to do
#################

$t->post_ok('/' => json => { login    => 'benja',              
		             password => 'benja',              
		             action   => 'user_get_list',
			     filters    => { name => 'ben'}}) 
    ->status_is(200, 'admin 1 is able to HTTP STATUS')
    ->json_is('/status' => '0', 'admin tenant 1 is able to do API STATUS');


$t->post_ok('/' => json => { login    => 'benja',              
		             password => 'benja',              
		             action   => 'user_update',
			     filters    => { id => 5 },
			     arguments => { name => 'ben' }}) 
    ->status_is(200, 'admin tenant 1 is able to do HTTP STATUS')
    ->json_is('/status' => '8', 'admin tenant 1 is able to do API STATUS');

######################
## Filters by tenant_id
######################

$t->post_ok('/' => json => { login    => 'benja',              
		             password => 'benja',              
		             action   => 'user_get_list',
			     filters    => { tenant_id => '1'}}) 
    ->status_is(200, 'admin 1 is able to HTTP STATUS')
    ->json_is('/status' => '9', 'admin 1 filters by tenant_id API STATUS');

###################
## Sees all tenants
###################

$t->post_ok('/' => json => { login    => 'benja',              
		             password => 'benja',              
		             action   => 'user_get_list',
			     filters    => {}}) 
    ->status_is(200, 'admin 1 sees all tenants HTTP STATUS')
    ->json_is('/status' => '0', 'admin 1 sees all tenants API STATUS')
    ->json_has('/result/rows/3/' => 'admin 1 sees all tenants API STATUS')
    ->json_hasnt('/result/rows/4/' => 'admin 1 sees all tenants API STATUS')

####################
## Gets tenants info
####################

    ->json_hasnt('/result/rows/0/tenant_id' => 'admin 1 gets tenants info API STATUS')
    ->json_hasnt('/result/rows/0/tenant_name' => 'admin 1 gets tenants info API STATUS');


#################
## ADMIN TENANT 2
################# 

#################
### Is able to do
#################

$t->post_ok('/' => json => { login    => 'ana',              
		             password => 'ana',              
		             action   => 'user_get_list',
			     filters    => { name => 'santiago'}}) 
    ->status_is(200, 'admin 2 is able to HTTP STATUS')
    ->json_is('/status' => '0', 'admin tenant 2 is able to do API STATUS');


$t->post_ok('/' => json => { login    => 'ana',              
		             password => 'ana',              
		             action   => 'user_update',
			     filters    => { id => 17 },
			     arguments => { name => 'santiago' }}) 
    ->status_is(200, 'admin tenant 2 is able to do HTTP STATUS')
    ->json_is('/status' => '8', 'admin tenant 2 is able to do API STATUS');


######################
## Filters by tenant_id
######################

$t->post_ok('/' => json => { login    => 'ana',              
		             password => 'ana',              
		             action   => 'user_get_list',
			     filters    => { tenant_id => '2'}}) 
    ->status_is(200, 'admin 2 is able to HTTP STATUS')
    ->json_is('/status' => '9', 'admin 2 filters by tenant_id API STATUS');

###################
## Sees all tenants
###################

$t->post_ok('/' => json => { login    => 'ana',              
		             password => 'ana',              
		             action   => 'user_get_list',
			     filters    => {}}) 
    ->status_is(200, 'admin 2 sees all tenants HTTP STATUS')
    ->json_is('/status' => '0', 'admin 2 sees all tenants API STATUS')
    ->json_has('/result/rows/1/' => 'admin 2 sees all tenants API STATUS')
    ->json_hasnt('/result/rows/2/' => 'admin 2 sees all tenants API STATUS')

####################
## Gets tenants info
####################

    ->json_hasnt('/result/rows/0/tenant_id' => 'admin 2 gets tenants info API STATUS')
    ->json_hasnt('/result/rows/0/tenant_name' => 'admin 2 gets tenants info API STATUS');

###################################
###################################
###################################

done_testing();


