package QVD::DB::Provisioning;

use warnings;
use strict;
use QVD::DB::Simple;
use Data::Dumper;
use Carp;

sub _die_on_too_many_opts (\%) {
    my $opts = shift;
    %$opts and croak "Unknown options";
}

sub storage {
    my $self = shift;
    $self->{storage};
}

sub new {
    my $class=shift;
    my %opts = @_;

    my $self = {};
    bless $self, $class;

    if ($opts{deploy}) {
	db->erase;
	$self->_deploy;
    }
    return $self;
}

sub _deploy {
    my $prov = shift;

    db->deploy;

    # FIXME: perl actually has loops! :-)
    $prov->add_vm_state(name => 'stopped');
    $prov->add_vm_state(name => 'starting');
    $prov->add_vm_state(name => 'running');
    $prov->add_vm_state(name => 'stopping');
    $prov->add_vm_state(name => 'zombie');
    $prov->add_vm_state(name => 'failed');

    $prov->add_vm_cmd(name => 'start');
    $prov->add_vm_cmd(name => 'stop');

    $prov->add_x_state(name => 'disconnected');
    $prov->add_x_state(name => 'connecting');
    $prov->add_x_state(name => 'listening');
    $prov->add_x_state(name => 'connected');
    $prov->add_x_state(name => 'disconnecting');

    $prov->add_x_cmd(name => 'connect');
    $prov->add_x_cmd(name => 'disconnect');

    $prov->add_user_state(name => 'disconnected');
    $prov->add_user_state(name => 'connecting');
    $prov->add_user_state(name => 'connected');
    $prov->add_user_state(name => 'aborting');

    $prov->add_user_cmd(name => 'Abort');
    $prov->add_user_cmd(name => 'Forward');

    $prov->add_config(key => 'vmas_load_balance_algorithm', value => 'random');

    $prov->add_config(key => 'vm_state_starting_timeout', value => '6000');
    $prov->add_config(key => 'vm_state_running_vma_timeout', value => '1500');
    $prov->add_config(key => 'vm_state_stopping_timeout', value => '9000');
    $prov->add_config(key => 'vm_state_zombie_sigkill_timeout', value => '3000');
    $prov->add_config(key => 'x_state_connecting_timeout', value => '1500');    
    $prov->add_config(key => 'vma_response_timeout', value => '1500');        

    $prov->add_config(key => 'vm_start_timeout', value => '6000');        

    $prov->add_config(key => 'vm_vma_port', value => '3030');
    $prov->add_config(key => 'vm_x_port', value => '5000');
    $prov->add_config(key => 'vm_ssh_port', value => '2022');
    $prov->add_config(key => 'vm_vnc_port', value => '5900');    

    $prov->add_config(key => 'hkd_pid_file', value => '/var/run/qvd/hkd.pid');
    $prov->add_config(key => 'hkd_log_file', value => '/var/log/qvd.log');

    $prov->add_config(key => 'base_storage_path', value => '/var/lib/qvd/storage');
    $prov->add_config(key => 'ro_storage_path', value => '/var/lib/qvd/storage/images');
    $prov->add_config(key => 'rw_storage_path', value => '/var/lib/qvd/storage/overlays');
    $prov->add_config(key => 'home_storage_path', value => '/var/lib/qvd/storage/homes');
    $prov->add_config(key => 'shared_storage_path', value => '/var/lib/qvd/storage/shared');
}

sub add_user {
    my ($self, %opts) = @_;
    my $login = delete $opts{login};
    my $passwd = delete $opts{password};
    _die_on_too_many_opts(%opts);
    rs(User)->create({login => $login,
		      password => $passwd});
}

sub add_host {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    my $address = delete $opts{address};
    _die_on_too_many_opts(%opts);
    txn_do {
	my $r = rs(Host)->create({name => $name,
				   address => $address});
	rs(Host_Runtime)->create({host_id => $r->id});
    }
}

sub add_osi {
    my ($self, %opts) = @_;
    my $disk_image = delete $opts{path};
    my $use_overlay = delete $opts{use_overlay};
    my $memory = delete $opts{memory};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);

    rs(OSI)->create({disk_image => $disk_image,
		     name => $name,
		     memory => $memory,
		     use_overlay => $use_overlay});
}

sub add_vm {
    my ($self, %opts) = @_;
    my $name = delete $opts{name}; 
    my $host = delete $opts{host}; 
    my $user = delete $opts{user}; 
    my $osi = delete $opts{osi}; 
    my $ip = delete $opts{ip}; 
    my $storage = delete $opts{storage}; 
    _die_on_too_many_opts(%opts);

    txn_do {
	my $vm = rs(VM)->create({name => $name,
				 user_id => $user,
				 osi_id => $osi,
				 ip => $ip,
				 storage => $storage });

	rs(VM_Runtime)->create({vm_id => $vm->id,
				host_id => $host,
				user_state => "disconnected",
				vm_state => "stopped",
				x_state => "disconnected",
				osi_actual_id => $osi});
    };
}

sub add_vm_state {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(VM_State)->create({name => $name});
}

sub add_vm_cmd {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(VM_Cmd)->create({name => $name});
}

sub add_user_state {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(User_State)->create({name => $name});
}

sub add_user_cmd {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(User_Cmd)->create({name => $name});
}

sub add_x_state {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(X_State)->create({name => $name});
}

sub add_x_cmd {
    my ($self, %opts) = @_;
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);
    rs(X_Cmd)->create({name => $name});
}

sub add_config {
    my ($self, %opts) = @_;
    my $key = delete $opts{key};
    my $value = delete $opts{value};
    _die_on_too_many_opts(%opts);
    rs(Config)->create({key => $key, value => $value});
}

sub add_ssl_config {
    my ($self, %opts) = @_;
    my $key = delete $opts{key};
    my $value = delete $opts{value};
    _die_on_too_many_opts(%opts);
    rs(SSL_Config)->create({key => $key, value => $value});
}

1;
