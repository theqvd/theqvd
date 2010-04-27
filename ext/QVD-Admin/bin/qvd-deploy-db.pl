#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Simple;
use Log::Log4perl;

my @sqlt_args = ({}); #{ add_drop_table => 0 };
my $dir = '.';

# FIXME parse command line arguments properly
my $db = @ARGV ? db(data_source => $ARGV[0], username => $ARGV[1], password => $ARGV[2])
		: db(); 
$db->erase;
$db->deploy(@sqlt_args, $dir);

require QVD::Admin;

my $admin = QVD::Admin->new;

my %default_config = ( vmas_load_balance_algorithm => 'random',
		       vm_state_starting_timeout => 180,
		       vm_state_running_vma_timeout => 20,
		       vm_state_stopping_timeout => 100,
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
		       auth_basic_adminpassword => 'admin' );

$admin->cmd_config_set(%default_config);
