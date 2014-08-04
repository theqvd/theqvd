use Test::More;
use Test::Mojo;
use FindBin;
require "$FindBin::Bin/../bin/wat.pl";

my $t = Test::Mojo->new;

##################################################################
############################## USER ##############################
#################################################################

#################
### user_get_list
#################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
		             action     => 'user_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { login => 'benja', 
					     world => 'reality' }}) # custom property: world => (reality | fantasy)
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

####################
##### user_get_state
####################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'user_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '2'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');


#######################
##### user_get_details
#######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'user_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '1'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

##################################################################
############################### VM  ##############################
##################################################################

#################
### vm_get_list
#################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'vm_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { office => 'Madrid',
			                     name => 'MyVM',
                                             user_id => 2,
					     osf_id  => 1,
					     di_id => undef,
					     host_id => '2' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

######################
#### vm_get_details
######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'vm_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '12' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

###################
#### vm_get_state
###################


$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'vm_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '12' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

###################
#### vm_get_state
###################


$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'vm_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '12'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

##################################################################
############################### HOST #############################
##################################################################

######################
#### host_get_list
######################


$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'host_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { name  => 'QVD_Ubuntu_14.04',
			                     vm_id => 12,
					     office => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');


######################
#### host_get_details
######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'host_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

###################
#### host_get_state
###################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'host_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

#################################################################
############################### OSF #############################
#################################################################

#######################
#### osf_get_list
#######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'osf_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { name  => 'ubuntu',
			                     vm_id => 12,
					     di_id => 1,
					     office => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

#######################
#### osf_get_details
#######################


$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'osf_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 1 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

################################################################
############################### DI #############################
################################################################

#######################
#### di_get_list
#######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'di_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { disk_image  => '1-ubuntu-13.04-i386-qvd.tar.gz',
			                     osf_id      => 1,
                                             office      => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

#######################
#### di_get_details
#######################

$t->post_ok('/' => json => { login => 'benja',                      # With login sergio, password sergio, 
		             password => 'benja',                   # access to other tenant
			     action     => 'di_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => 1 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/' => '0');

#################################

done_testing();

#################################
#################################
#################################

