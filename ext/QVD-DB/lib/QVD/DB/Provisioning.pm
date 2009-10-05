package QVD::DB::Provisioning;

use warnings;
use strict;
use QVD::DB;
use Data::Dumper;

sub new {
	my $class=shift;
	my %opts = @_;
	my $schema = QVD::DB->new(); 
	$schema->deploy({add_drop_table => 1}) if $opts{deploy};
	my $self = {schema => $schema};
	bless $self, $class;
	return $self; 
	
}


sub add_farm {
	my ($self, %opts) = @_;
	my $schema = $self->{schema};
	my $name = $opts{'name'};
	$schema->resultset('Farm')->create({name => $name});
	$schema->txn_commit;
}

sub add_user {
	my ($self, %opts) = @_;
        my $schema = $self->{schema};
        my $login = $opts{'login'};
	$schema->resultset('User')->create({login => $login});
	$schema->txn_commit;
}

sub add_host {
	my ($self, %opts) = @_;
        my $schema = $self->{schema};
        my $farm = $opts{'farm'};
	$schema->resultset('Host')->create({farm_id => $farm});
	$schema->txn_commit;
}

sub add_osi {
	my ($self, %opts) = @_;
        my $schema = $self->{schema};
	my $disk_image = $opts{path};
	my $name = $opts{name};
	$schema->resultset('OSI')->create({disk_image => $disk_image,
					   name => $name});
	$schema->txn_commit;
}

sub add_vm {
	my ($self, %opts) = @_;
        my $schema = $self->{schema};

	my $name = $opts{name}; 
	my $farm = $opts{farm}; 
	my $user = $opts{user}; 
	my $osi = $opts{osi}; 
	my $ip = $opts{ip}; 
	my $storage = $opts{storage}; 

	my $row = $schema->resultset('VM')->create({name => $name,
					  farm_id => $farm, 
		 			  user_id => $user,
					  osi_id => $osi,
				    	  ip => $ip,
					  storage => $storage });
	

	my $vm_runtime=$schema->resultset('VM_Runtime');
	print $row->id;
	$vm_runtime->create({vm_id => $row->id});
						
	$schema->txn_commit;
						
}
						
1;
