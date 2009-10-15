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

    $db->add_x_state(name => 'stopped');
    $db->add_x_state(name => 'disconnected');
    $db->add_x_state(name => 'connecting');
    $db->add_x_state(name => 'connected');

    $db->add_x_cmd(name => 'start');
    $db->add_x_cmd(name => 'stop');

    $db->add_user_state(name => 'disconnected');
    $db->add_user_state(name => 'connecting');
    $db->add_user_state(name => 'connected');
    $db->add_user_state(name => 'disconnecting');
    $db->add_user_state(name => 'aborting');

    $db->add_user_cmd(name => 'abort');

}

sub add_user {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $login = delete $opts{login};
    _die_on_too_many_opts(%opts);

    $schema->resultset('User')->create({login => $login});        
}

sub add_host {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    _die_on_too_many_opts(%opts);
# FIXME PostgreSQL driver doesn't like empty hashes so we use a fixed id!
    $schema->resultset('Host')->create({id => 1});
}

sub add_osi {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $disk_image = delete $opts{path};
    my $name = delete $opts{name};
    _die_on_too_many_opts(%opts);

    $schema->resultset('OSI')->create({disk_image => $disk_image,
			    name => $name});
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
							vm_state => "stopped"});
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

1;
