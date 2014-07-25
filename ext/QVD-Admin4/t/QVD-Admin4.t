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

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_get_list',
			     table      => 'User',
			     fields     => [qw(id login)],
			     order_by   => [qw(id login)],
			     arguments  => { relations => { vms => [qw(name ip)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { login => 'benja' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/id')
    ->json_has('/result/rows/0/login')
    ->json_has('/result/rows/0/vms/0/ip')
    ->json_has('/result/rows/0/vms/0/name');

##################
### user_get_state
##################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_get_state',
			     table      => 'User',
			     fields     => [],
			     order_by   => [],
			     arguments  => { relations => { vms => [qw(id)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { login => 'benja' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/id');

#####################
### user_get_details
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_get_details',
			     table      => 'User',
			     fields     => [qw(id login)],
			     order_by   => [],
			     arguments  => { relations => { properties => [qw(key value)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { id => '2' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/id')
    ->json_has('/result/rows/0/login')
    ->json_is('/result/rows/0/id' => '2');
#   ->json_has('/result/rows/0/properties/0/key')
#   ->json_has('/result/rows/0/properties/0/value');

#####################
### user_create
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_create',
			     table      => 'User',
			     fields     => [],
			     order_by   => [],
			     arguments  => { login => 'ramirez', password => '4591'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/login' => 'ramirez')
    ->json_is('/result/rows/0/password' => '4591');


#####################
### user_delete
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_delete',
			     table      => 'User',
			     fields     => [],
			     order_by   => [],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {login => [qw(ramirez)]}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0');

#####################
### user_update
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_update',
			     table      => 'User',
			     fields     => [],
			     order_by   => [],
			     arguments  => { password  => 'ramirez'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { id =>  [qw(2)]  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/password' => 'ramirez');


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'user_update',
			     table      => 'User',
			     fields     => [],
			     order_by   => [],
			     arguments  => { password => '4591'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { id => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0');

#################################################################
############################## VM  ##############################
#################################################################


#####################
### vm_get_list
#####################


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_get_list',
			     table      => 'VM',
			     fields     => [qw(me.id me.name me.user_id 
                                               me.osf_id osf.name  me.di_tag 
                                               vm_runtime.blocked 
                                               vm_runtime.vm_expiration_soft 
                                               vm_runtime.vm_expiration_hard)],
			     order_by   => [qw(me.id me.name vm_runtime.vm_state
                                               vm_runtime.host_id me.user_id me.osf_id  
                                               vm_runtime.blocked)],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { 'me.name' => 'MyVM', 
					     'user_id' => 2, 
					     'osf_id' => 1,
                                             'vm_runtime.host_id' => undef,
					     'vm_runtime.current_di_id' => undef,
					     di_tag => 'default'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'MyVM');


#####################
### vm_get_details
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_get_details',
			     table      => 'VM',
			     fields     => [qw(id ip name osf_id di_tag 
                                               vm_runtime.blocked 
                                               vm_runtime.vm_state
                                               vm_runtime.host_id
                                               vm_runtime.vm_address ip 
                                               vm_runtime.vm_ssh_port 
                                               vm_runtime.vm_vnc_port
                                               vm_runtime.vm_serial_port 
                                               vm_runtime.vm_expiration_soft 
                                               vm_runtime.vm_expiration_hard)],
			     order_by   => [],
			     arguments  => { relations => { properties => [qw(key value)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { id => 12}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'MyVM');

##################
### vm_get_state
##################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_get_state',
			     table      => 'VM',
			     fields     => [qw(vm_runtime.vm_state vm_runtime.user_state)],
			     order_by   => [],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { id => 12 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/vm_runtime vm_state' => 'stopped')
    ->json_is('/result/rows/0/vm_runtime user_state' => 'disconnected');


#####################
### vm_create
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_create',
			     table      => 'VM',
			     fields     => [],
			     order_by   => [],
			     arguments  => { user_id => 2, name => 'YourVM', osf_id => 1, 
					     di_tag => 'default', ip => '10.3.15.253' },
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/ip' => '10.3.15.253')
    ->json_is('/result/rows/0/name' => 'YourVM');


#####################
### vm_delete
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_delete',
			     table      => 'VM',
			     fields     => [],
			     order_by   => [],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {name => [qw(YourVM)]}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0');

#####################
### vm_update
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_update',
			     table      => 'VM',
			     fields     => [],
			     order_by   => [],
			     arguments  => { ip  => '10.3.15.253'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { name =>  [qw(MyVM)]  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/ip' => '10.3.15.253');

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_update',
			     table      => 'VM',
			     fields     => [],
			     order_by   => [],
			     arguments  => { ip  => '10.3.15.254'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name =>  [qw(MyVM)]  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0');

#####################
### vm_running_stats
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'vm_running_stats',
			     table      => 'VM',
			     fields     => [],
			     order_by   => [],
			     arguments  => { },
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { 'vm_runtime.vm_state' =>  'running'  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/total', '0');

#################################################################
############################## HOST #############################
#################################################################

#####################
### host_get_list
#####################


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_get_list',
			     table      => 'Host',
			     fields     => [qw(id name address runtime.blocked)],
			     order_by   => [qw(id name runtime.state address 
                                               runtime.blocked)],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name => 'QVD_Ubuntu_14.04' }})
#                                            'vms.vm_id' => 12  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/id' => 2)
    ->json_is('/result/rows/0/name' => 'QVD_Ubuntu_14.04')
    ->json_is('/result/rows/0/address' => '10.3.15.1')
    ->json_is('/result/rows/0/runtime blocked' => '0');

#####################
### host_get_details
#####################


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_get_details',
			     table      => 'Host',
			     fields     => [qw(id name runtime.state address runtime.blocked)],
			     order_by   => [],
			     arguments  => { relations => { properties => [qw(key value)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { id => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/id' => 2)
    ->json_is('/result/rows/0/name' => 'QVD_Ubuntu_14.04')
    ->json_is('/result/rows/0/address' => '10.3.15.1')
    ->json_is('/result/rows/0/runtime blocked' => '0')
    ->json_is('/result/rows/0/runtime state' => 'running');

##################
### host_get_state
##################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_get_state',
			     table      => 'Host',
			     fields     => [qw(runtime.state)],
			     order_by   => [],
			     arguments  => { relations => { vms => [qw(id)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { id => '2' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0/id');


#####################
### host_create
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_create',
			     table      => 'Host',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name => 'KKK', address => '10.3.15.6'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'KKK')
    ->json_is('/result/rows/0/address' => '10.3.15.6');


#####################
### host_delete
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_delete',
			     table      => 'Host',
			     fields     => [],
			     order_by   => [],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {name => [qw(KKK)]}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0');

#####################
### host_update
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_update',
			     table      => 'Host',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name  => 'QQQ'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name =>  [qw(QVD_Ubuntu_14.04)]  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'QQQ');


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_update',
			     table      => 'Host',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name => 'QVD_Ubuntu_14.04'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name => [qw(QQQ)] }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0');

######################
### host_running_stats
######################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'host_running_stats',
			     table      => 'Host',
			     fields     => [],
			     order_by   => [],
			     arguments  => { },
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { 'runtime.state' =>  'running'  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/total', '1');

#################################################################
############################## HOST #############################
#################################################################

######################
### osf_get_list
######################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_get_list',
			     table      => 'OSF',
			     fields     => [qw(me.id me.name me.use_overlay
                                               me.user_storage_size me.memory)],
			     order_by   => [qw(me.id me.name me.use_overlay
                                               me.memory me.user_storage_size)],
			     arguments  => { relations => { vms => [qw(id)],
                                                            dis => [qw(id)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { 'me.name'     =>  'ubuntu',
			                     'vms.id' =>  12,
                                             'dis.id' =>  1 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'ubuntu');

######################
### osf_get_details
######################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_get_details',
			     table      => 'OSF',
			     fields     => [qw(me.id me.name me.use_overlay
                                               me.user_storage_size me.memory)],
			     order_by   => [qw(me.id me.name me.use_overlay
                                               me.memory me.user_storage_size)],
			     arguments  => {relations => { properties => [qw(key value)]}},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { 'me.id'     =>  '1'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'ubuntu');

#####################
### osf_create
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_create',
			     table      => 'OSF',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name => 'kubuntu'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => {}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/name' => 'kubuntu');



#####################
### osf_delete
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_delete',
			     table      => 'OSF',
			     fields     => [],
			     order_by   => [],
			     arguments  => {},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 1 },
			     filters    => { name => [qw(kubuntu)]}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0');

#####################
### osf_update
#####################

$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_update',
			     table      => 'OSF',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name  => 'kubuntu'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name =>  [qw(ubuntu)]  }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/name' => 'kubuntu');


$t->post_ok('/' => json => { host       => '192.168.56.102',
			     user       => 'qvd',
			     password   => '4591',
			     database   => 'qvddb',
			     action     => 'osf_update',
			     table      => 'OSF',
			     fields     => [],
			     order_by   => [],
			     arguments  => { name => 'ubuntu'},
			     order_dir  => "-desc",
			     pagination => { offset => 1, blocked => 10 },
			     filters    => { name => 'kubuntu' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0');


################################

done_testing();

################################
################################
################################
