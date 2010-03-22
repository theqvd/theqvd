#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Simple;
use Sys::Hostname;
use File::Slurp;

db->erase;
db->deploy;

require QVD::Admin;

my $admin = QVD::Admin->new;

my %default_config = ( vmas_load_balance_algorithm => 'random',
		       vm_state_starting_timeout => 60,
		       vm_state_running_vma_timeout => 20,
		       vm_state_stopping_timeout => 20,
		       vm_state_zombie_sigkill_timeout => 15,
		       x_state_connecting_timeout => 15,
		       vma_response_timeout => 5,

		       vm_start_timeout => 180, # FIXME: eliminate
                                                # this configuration
                                                # variable, use
                                                # vm_state_starting_timeout
                                                # instead!

		       hkd_pid_file => '/var/run/qvd/hkd.pid',
		       hkd_log_file => '/var/log/qvd.log',

		       l7r_pid_file => '/var/run/qvd/l7r.pid',
		       l7r_log_file => '/var/log/qvd.log',

		       rc_pid_file => '/var/run/qvd/rc.pid',
		       rc_log_file => '/var/log/qvd.log',

		       base_storage_path => '/var/lib/qvd/storage',
		       ro_storage_path => '/var/lib/qvd/storage/images',
		       rw_storage_path => '/var/lib/qvd/storage/overlays',
		       home_storage_path => '/var/lib/qvd/storage/homes',
		       shared_storage_path => '/var/lib/qvd/storage/shared',

		       auth_mode => 'basic',
		       auth_ldap_host => 'yourLDAPhost.yourCompany.com',
		       auth_ldap_base => 'dc=example,dc=com',
		       auth_basic_adminusername => 'admin',
		       auth_basic_adminpassword => 'LpwdeQND' );

$admin->cmd_config_set(%default_config);
QVD::Config->reload;

$admin->cmd_user_add(login => 'qvd', 
		password => 'passw0rd', 
		department => 'I+D',
	       	email => 'qvd@qindel.com',
	       	telephone => '914 44 44 44');
$admin->cmd_osi_add(name => 'Test image',
	       memory => '256',
	       use_overlay => 1,
	       disk_image => 'qvd-guest.img');
$admin->cmd_host_add(name => hostname, address => '127.0.0.1');
$admin->cmd_vm_add(name => 'Test VM 1',
	      osi => 'Test image',
	      user => 'qvd',
	      ip => '',
	      );

$admin->cmd_config_ssl(key => scalar read_file('certs/server-key.pem'),
		    cert => scalar read_file('certs/server-cert.pem'));
