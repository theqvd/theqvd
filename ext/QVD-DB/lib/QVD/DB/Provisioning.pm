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
    $schema->deploy({add_drop_table => 1}) if $opts{deploy};
    my $self = {schema => $schema};
    bless $self, $class;
    return $self;
}

sub add_user {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    my $login = delete $opts{login};
    _die_on_too_many_opts(%opts);

    $schema->resultset('User')->create({login => $login});
        
    print "Invocado con, $login\n";
}

#~ sub del_user {
    #~ my ($self, %opts) = @_;
    #~ my $schema = $self->{schema};
#~ 
    #~ $schema->resultset('User')->delete());
#~ }

sub add_host {
    my ($self, %opts) = @_;
    my $schema = $self->{schema};
    _die_on_too_many_opts(%opts);

    $schema->resultset('Host')->create({});
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
    my $user = delete $opts{user}; 
    my $osi = delete $opts{osi}; 
    my $ip = delete $opts{ip}; 
    my $storage = delete $opts{storage}; 
    _die_on_too_many_opts(%opts);

    my $vm_runtime=$schema->resultset('VM_Runtime')->create({state => "stopped"});

    my $row = $schema->resultset('VM')->create({name => $name,
		 			user_id => $user,
					osi_id => $osi,
					ip => $ip,
					vm_runtime => $vm_runtime,
					storage => $storage });
 

}

1;
