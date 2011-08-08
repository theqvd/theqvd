#!/usr/bin/perl 

use QVD::DB::Simple;
use strict;

my $IP_SUBNET = '172.20.99.';
my $TEMP_STO = 'En algun lugar';

rs(Host)->create({});
rs(OSF)->create({name => 'test'});
rs(DI)->create({osf_id => 1,
                path => '/var/local/img'});

for (my $i=1; $i<=5; $i++){
    rs(User)->create({login => 'test'.$i});

    rs(VM)->create({name => 'test'.$i,
		    farm_id => 1,
		    user_id => $i,
		    osf_id => 1,
                    di_tag => 'default',
		    ip => $IP_SUBNET . $i, 
		    storage => $TEMP_STO
		   });
    rs(VM_Runtime)->create({vm_id => $i,
			    host_id => $i,
			    state => 'Stopped',
			    state_x => 'Check',
			    state_user => 'Disconnected',
			    user_ip => 'The ip from user is connecting',
			    real_user_id => 'Real User'
			   });
}





