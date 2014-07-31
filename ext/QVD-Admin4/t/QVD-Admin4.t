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

$t->post_ok('/' => json => { action     => 'user_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { login => 'benjamin',
                                             office => 'Mexico',
                                             degree => 'PhD'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/blocked' => undef)
    ->json_is('/result/rows/0/#vms' => '0')
    ->json_is('/result/rows/0/login' => 'benjamin');


###################
#### user_get_state
###################

$t->post_ok('/' => json => { action     => 'user_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '2'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/#vms','1');

######################
#### user_get_details
######################

$t->post_ok('/' => json => { action     => 'user_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '1'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_has('/result/rows/0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/login' => 'benjamin')
    ->json_is('/result/rows/0/blocked' => undef)
    ->json_is('/result/rows/0/office' => 'Mexico')
    ->json_is('/result/rows/0/degree' => 'PhD')
    ->json_is('/result/rows/0/creation_admin' => undef)
    ->json_is('/result/rows/0/creation_date' => undef);

######################
#### user_create
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'user_create',
#			     table      => 'User',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { login => 'ramirez', password => '4591'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0')
#    ->json_is('/result/rows/0/login' => 'ramirez')
#    ->json_is('/result/rows/0/password' => '4591');
#
#
######################
#### user_delete
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'user_delete',
#			     table      => 'User',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => {},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {login => [qw(ramirez)]}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0');
#
######################
#### user_update
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'user_update',
#			     table      => 'User',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { password  => 'ramirez'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { id =>  [qw(2)]  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_is('/result/rows/0/password' => 'ramirez');
#
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'user_update',
#			     table      => 'User',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { password => '4591'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { id => 2 }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0');
#
##################################################################
############################### VM  ##############################
##################################################################
#
#
######################
#### vm_get_list
######################


#################
### vm_get_list
#################

$t->post_ok('/' => json => { action     => 'vm_get_list',
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
    ->json_is('/result/rows/0/id' => '12')
    ->json_is('/result/rows/0/name' => 'MyVM')
    ->json_is('/result/rows/0/host_id' =>  '2')
    ->json_is('/result/rows/0/user_id' =>  '2')
    ->json_is('/result/rows/0/user_login' =>  'benja')
    ->json_is('/result/rows/0/osf_id' =>  1)
    ->json_is('/result/rows/0/osf_name' =>  'ubuntu')
    ->json_is('/result/rows/0/di_tag' =>  'default')
    ->json_is('/result/rows/0/di_version' =>  undef)
    ->json_is('/result/rows/0/blocked' =>  0)
    ->json_is('/result/rows/0/expiration_soft' =>  undef)
    ->json_is('/result/rows/0/expiration_hard' =>  undef);


######################
#### vm_get_details
######################

$t->post_ok('/' => json => { action     => 'vm_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '12' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '12')
    ->json_is('/result/rows/0/name' => 'MyVM')
    ->json_is('/result/rows/0/osf_id' =>  1)
    ->json_is('/result/rows/0/osf_name' =>  'ubuntu')
    ->json_is('/result/rows/0/di_tag' =>  'default')
    ->json_is('/result/rows/0/di_id' =>  undef)
    ->json_is('/result/rows/0/di_name' =>  undef)
    ->json_is('/result/rows/0/di_version' =>  undef)
    ->json_is('/result/rows/0/blocked' =>  0)
    ->json_is('/result/rows/0/office' =>  'Madrid')
    ->json_is('/result/rows/0/state' =>  'running')
    ->json_is('/result/rows/0/host_id' =>  '2')
    ->json_is('/result/rows/0/host_name' =>  'QVD_Ubuntu_14.04')
    ->json_is('/result/rows/0/ip' =>  '10.3.15.254')
    ->json_is('/result/rows/0/next_boot_ip' =>  undef )
    ->json_is('/result/rows/0/ssh_port' =>  undef )
    ->json_is('/result/rows/0/vnc_port' =>  undef )
    ->json_is('/result/rows/0/serial_port' =>  undef )
    ->json_is('/result/rows/0/expiration_soft' =>  undef)
    ->json_is('/result/rows/0/expiration_hard' =>  undef)
    ->json_is('/result/rows/0/creation_admin' => undef)
    ->json_is('/result/rows/0/creation_date' => undef);


###################
#### vm_get_state
###################


$t->post_ok('/' => json => { action     => 'vm_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => '12'}})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/vm_state','running')
    ->json_is('/result/rows/0/user_state','disconnected');

######################
#### vm_create
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'vm_create',
#			     table      => 'VM',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { user_id => 2, name => 'YourVM', osf_id => 1, 
#					     di_tag => 'default', ip => '10.3.15.253' },
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0')
#    ->json_is('/result/rows/0/ip' => '10.3.15.253')
#    ->json_is('/result/rows/0/name' => 'YourVM');
#
#
######################
#### vm_delete
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'vm_delete',
#			     table      => 'VM',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => {},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {name => [qw(YourVM)]}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0');
#
######################
#### vm_update
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'vm_update',
#			     table      => 'VM',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { ip  => '10.3.15.253'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => { name =>  [qw(MyVM)]  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_is('/result/rows/0/ip' => '10.3.15.253');
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'vm_update',
#			     table      => 'VM',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { ip  => '10.3.15.254'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { name =>  [qw(MyVM)]  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0');
#
######################
#### vm_running_stats
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'vm_running_stats',
#			     table      => 'VM',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { },
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => { 'vm_runtime.vm_state' =>  'running'  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_is('/result/total', '0');
#
##################################################################
############################### HOST #############################
##################################################################
#
######################
#### host_get_list
######################


$t->post_ok('/' => json => { action     => 'host_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { name  => 'QVD_Ubuntu_14.04',
			                     vm_id => 12,
					     office => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '2')
    ->json_is('/result/rows/0/name' => 'QVD_Ubuntu_14.04')
    ->json_is('/result/rows/0/address' => '10.3.15.1')
    ->json_is('/result/rows/0/blocked' => '0');

######################
#### host_get_details
######################

$t->post_ok('/' => json => { action     => 'host_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '2')
    ->json_is('/result/rows/0/name' => 'QVD_Ubuntu_14.04')
    ->json_is('/result/rows/0/address' => '10.3.15.1')
    ->json_is('/result/rows/0/blocked' => '0')
    ->json_is('/result/rows/0/load' => undef)
    ->json_is('/result/rows/0/creation_admin' => undef)
    ->json_is('/result/rows/0/creation_time' => undef)
    ->json_is('/result/rows/0/office' => 'Madrid');


###################
#### host_get_state
###################

$t->post_ok('/' => json => { action     => 'host_get_state',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 2 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/load' => undef)
    ->json_is('/result/rows/0/state' => 'running')
    ->json_is('/result/rows/0/#vms' => '1');


######################
#### host_create
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'host_create',
#			     table      => 'Host',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { name => 'KKK', address => '10.3.15.6'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0')
#    ->json_is('/result/rows/0/name' => 'KKK')
#    ->json_is('/result/rows/0/address' => '10.3.15.6');
#
#
######################
#### host_delete
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'host_delete',
#			     table      => 'Host',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => {},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {name => [qw(KKK)]}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0');
#
######################
#### host_update
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'host_update',
#			     table      => 'Host',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { name  => 'QQQ'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { name =>  [qw(QVD_Ubuntu_14.04)]  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0')
#    ->json_is('/result/rows/0/name' => 'QQQ');
#
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'host_update',
#			     table      => 'Host',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { name => 'QVD_Ubuntu_14.04'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { name => [qw(QQQ)] }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0');
#
#######################
#### host_running_stats
#######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'host_running_stats',
#			     table      => 'Host',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { },
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => { 'runtime.state' =>  'running'  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_is('/result/total', '1');
#
#################################################################
############################### OSF #############################
#################################################################

#######################
#### osf_get_list
#######################

$t->post_ok('/' => json => { action     => 'osf_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { name  => 'ubuntu',
			                     vm_id => 12,
					     di_id => 1,
					     office => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/name' => 'ubuntu')
    ->json_is('/result/rows/0/overlay' => '1')
    ->json_is('/result/rows/0/memory' => '256')
    ->json_is('/result/rows/0/user_storage' => undef)
    ->json_is('/result/rows/0/#vms' => '1')
    ->json_is('/result/rows/0/#dis' => '1');

#######################
#### osf_get_details
#######################


$t->post_ok('/' => json => { action     => 'osf_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id  => 1 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/name' => 'ubuntu')
    ->json_is('/result/rows/0/overlay' => '1')
    ->json_is('/result/rows/0/memory' => '256')
    ->json_is('/result/rows/0/user_storage' => undef)
    ->json_is('/result/rows/0/office' => 'Madrid');



################################################################
############################### DI #############################
################################################################

#######################
#### di_get_list
#######################

$t->post_ok('/' => json => { action     => 'di_get_list',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { disk_image  => '1-ubuntu-13.04-i386-qvd.tar.gz',
			                     osf_id      => 1,
                                             office      => 'Madrid' }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/disk_image' => '1-ubuntu-13.04-i386-qvd.tar.gz')
    ->json_is('/result/rows/0/version' => '2014-06-18-000')
    ->json_is('/result/rows/0/osf_id' => '1')
    ->json_is('/result/rows/0/osf_name' => 'ubuntu')
    ->json_is('/result/rows/0/blocked' => undef)
    ->json_has('/result/rows/0/tags/0/')
    ->json_has('/result/rows/0/tags/1/')
    ->json_has('/result/rows/0/tags/2/');

#######################
#### di_get_details
#######################

$t->post_ok('/' => json => { action     => 'di_get_details',
			     offset     => 1,
			     blocked    => 3,
			     filters    => { id => 1 }})
    ->status_is(200)
    ->json_is('/message' => '')
    ->json_is('/status' => '0')
    ->json_is('/result/rows/0/id' => '1')
    ->json_is('/result/rows/0/disk_image' => '1-ubuntu-13.04-i386-qvd.tar.gz')
    ->json_is('/result/rows/0/version' => '2014-06-18-000')
    ->json_is('/result/rows/0/osf_id' => '1')
    ->json_is('/result/rows/0/osf_name' => 'ubuntu')
    ->json_is('/result/rows/0/blocked' => undef)
    ->json_has('/result/rows/0/tags/0/')
    ->json_has('/result/rows/0/tags/1/')
    ->json_has('/result/rows/0/tags/2/')
    ->json_is('/result/rows/0/office', 'Madrid');

######################
#### di_create
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'di_create',
#			     table      => 'DI',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { osf_id => 1, 
#					     path => '1-ubuntu-13.04-i386-qvd.tar.gz',
#                                             version => '2014-07-28-000' },
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => {}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0')
#    ->json_is('/result/rows/0/version' => '2014-07-28-000');
#
#
#
######################
#### di_delete
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'di_delete',
#			     table      => 'DI',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => {},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 1 },
#			     filters    => { version => [qw(2014-07-28-000)]}})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_has('/result/rows/0');
#
######################
#### di_update
######################
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'di_update',
#			     table      => 'DI',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { path  => 'kubuntu.gz'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { path =>  [qw(1-ubuntu-13.04-i386-qvd.tar.gz)]  }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0')
#    ->json_is('/result/rows/0/path' => 'kubuntu.gz');
#
#
#$t->post_ok('/' => json => { host       => '192.168.56.102',
#			     user       => 'qvd',
#			     password   => '4591',
#			     database   => 'qvddb',
#			     action     => 'di_update',
#			     table      => 'DI',
#			     fields     => [],
#			     order_by   => [],
#			     arguments  => { path => '1-ubuntu-13.04-i386-qvd.tar.gz'},
#			     order_dir  => "-desc",
#			     pagination => { offset => 1, blocked => 10 },
#			     filters    => { path => 'kubuntu.gz' }})
#    ->status_is(200)
#    ->json_is('/message' => '')
#    ->json_is('/status' => '0');
#
#
#################################


done_testing();
#
#################################
#################################
#################################
