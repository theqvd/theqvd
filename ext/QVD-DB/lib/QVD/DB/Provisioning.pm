package QVD::DB::Provisioning;

use warnings;
use strict;
use QVD::DB;
use Data::Dumper;
use Carp;

sub _die_on_too_many_opts (\%) {
    my $opts = shift;
    %$opts and croak "Unknown options";
}

sub schema {
    my $self = shift;
    $self->{schema};
}

sub storage {
    my $self = shift;
    $self->{storage};
}

sub new {
    my $class=shift;
    my %opts = @_;
    my $schema = QVD::DB->new();  

    my $self = {schema => $schema};
    bless $self, $class;
    
    if ($opts{deploy}) {
	$schema->erase;
	$self->_deploy($schema);
    }
    
    return $self;
}

sub _deploy {
    my $db = shift;
    
    $db->schema->deploy;
    
    $db->add_vm_state(name => 'stopped');
    $db->add_vm_state(name => 'starting');
    $db->add_vm_state(name => 'running');
    $db->add_vm_state(name => 'stopping');
    $db->add_vm_state(name => 'zombie');
    $db->add_vm_state(name => 'failed');

    $db->add_vm_cmd(name => 'start');
    $db->add_vm_cmd(name => 'stop');

    $db->add_x_state(name => 'disconnected');
    $db->add_x_state(name => 'connecting');
    $db->add_x_state(name => 'listening');
    $db->add_x_state(name => 'connected');
    $db->add_x_state(name => 'disconnecting');

    $db->add_x_cmd(name => 'connect');
    $db->add_x_cmd(name => 'disconnect');

    $db->add_user_state(name => 'disconnected');
    $db->add_user_state(name => 'connecting');
    $db->add_user_state(name => 'connected');
    $db->add_user_state(name => 'aborting');

    $db->add_user_cmd(name => 'Abort');
    $db->add_user_cmd(name => 'Forward');

    $db->add_config(key => 'vmas_load_balance_algorithm', value => 'random');
    
    $db->add_config(key => 'vm_state_starting_timeout', value => '6000');
    $db->add_config(key => 'vm_state_running_vma_timeout', value => '1500');
    $db->add_config(key => 'vm_state_stopping_timeout', value => '9000');
    $db->add_config(key => 'vm_state_zombie_sigkill_timeout', value => '3000');
    $db->add_config(key => 'x_state_connecting_timeout', value => '1500');    
    $db->add_config(key => 'vma_response_timeout', value => '1500');        
    
    $db->add_config(key => 'vm_start_timeout', value => '6000');        
    
    $db->add_config(key => 'vm_vma_port', value => '3030');
    $db->add_config(key => 'vm_x_port', value => '5000');
    $db->add_config(key => 'vm_ssh_port', value => '2022');
    $db->add_config(key => 'vm_vnc_port', value => '5900');    
    
    $db->add_config(key => 'hkd_pid_file', value => '/var/run/qvd/hkd.pid');
    $db->add_config(key => 'hkd_log_file', value => '/var/log/qvd.log');
    
    $db->add_config(key => 'base_storage_path', value => '/var/lib/qvd/storage');
    $db->add_config(key => 'ro_storage_path', value => '/var/lib/qvd/storage/images');
    $db->add_config(key => 'rw_storage_path', value => '/var/lib/qvd/storage/overlays');
    $db->add_config(key => 'home_storage_path', value => '/var/lib/qvd/storage/homes');
}

sub add_user {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $login = delete $opts{login};
    my $passwd = delete $opts{password};
    _die_on_too_many_opts(%opts);

    $schema->resultset('User')->create({login => $login, 
    					password => $passwd});        
}

sub add_host {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    my $address = delete $opts{address};
    _die_on_too_many_opts(%opts);
    my $r = $schema->resultset('Host')->create({name => $name,
					address => $address});
    $r = $schema->resultset('Host_Runtime')->create({host_id => $r->id});
}

sub add_osi {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $disk_image = delete $opts{path};
    my $use_overlay = delete $opts{use_overlay};
    my $memory = delete $opts{memory};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);

    $schema->resultset('OSI')->create({disk_image => $disk_image,
			    name => $name,
			    memory => $memory,
			    use_overlay => $use_overlay});
}

sub add_vm {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name}; 
    my $host = delete $opts{host}; 
    my $user = delete $opts{user}; 
    my $osi = delete $opts{osi}; 
    my $ip = delete $opts{ip}; 
    my $storage = delete $opts{storage}; 
    _die_on_too_many_opts(%opts);


    my $row = $schema->resultset('VM')->create({name => $name,
		 			user_id => $user,
					osi_id => $osi,
					ip => $ip,
					storage => $storage });
 

    my $vm_runtime=$schema->resultset('VM_Runtime')->create({vm_id => $row->id,
							host_id => $host,
							user_state => "disconnected",
							vm_state => "stopped",
							x_state => "disconnected",
							osi_actual_id => $osi});
}

sub add_vm_state {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('VM_State')->create({name => $name});
    
}

sub add_vm_cmd {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('VM_Cmd')->create({name => $name});
    
}

sub add_user_state {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('User_State')->create({name => $name});
    
}

sub add_user_cmd {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('User_Cmd')->create({name => $name});
    
}

sub add_x_state {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('X_State')->create({name => $name});
    
}

sub add_x_cmd {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    
    $schema->resultset('X_Cmd')->create({name => $name});
    
}

sub add_config {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $key = delete $opts{key};
    my $value = delete $opts{value};
    _die_on_too_many_opts(%opts);

    $schema->resultset('Config')->create({key => $key, value => $value});        
}

1;
