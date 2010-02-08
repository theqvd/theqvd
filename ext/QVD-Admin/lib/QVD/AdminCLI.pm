package QVD::AdminCLI;

use warnings;
use strict;

use QVD::Admin;
use Text::Table;

sub new {
    my $class = shift;
    my $admin = QVD::Admin->new;
    my $self = {
	admin => $admin,
    };
    bless $self, $class;
}

sub _split_on_equals {
    # FIXME: actually, improve me!
    map { my @a = split /=/, $_, 2; $a[0] => $a[1] } @_;
}

sub set_filter {
    my ($self, $filter_string) = @_;
    my %conditions = _split_on_equals($filter_string);
    $self->{admin}->set_filter(%conditions);
}

sub get_resultset {
    shift->{admin}->get_resultset(@_);
}

sub dispatch_command {
    my ($self, $object, $command, $help, @args) = @_;
    $self->die_and_help ("Valid command expected") unless defined $object;
    $self->die_and_help ("$object: Valid command expected", $object) unless defined $command;
    my $method = $self->can($help ? "help_${object}_${command}" : "cmd_${object}_${command}");
    if (defined $method) {
	$self->{admin}{current_object} = $object;
	$self->$method(@args);
    } else {
	$self->die_and_help ("$object: $command not implemented", $object);
    }
}

sub _format_timespan {
    my $seconds = shift;
    my $secs = $seconds%60;
    my $mins = ($seconds /= 60) % 60;
    my $hours = ($seconds /= 60);
    return sprintf "%02d:%02d:%02d", $hours, $mins, $secs;
}

sub _print_header {
    my @titles = @_;
    print join("\t", @titles)."\n";
    print join("\t", map { s/./-/g; $_ } @titles)."\n";
}

sub _print_table {
    my ($header, $body) = @_;
    
    my $tb = Text::Table->new(@$header);
    $tb->load(@$body);
    
    print $tb->title;
    print $tb->rule( '-', '+');
    print $tb->body;
}

sub cmd_host_list {
    my ($self, @args) = @_;

    my $rs = $self->get_resultset('host');
    my @header = ("Id", "Name", "Address ","HKD", "VMs assigned");
    my @body;

    
    while (my $host = $rs->next) {
	my $hkd_ts = defined $host->runtime ? $host->runtime->hkd_ok_ts : undef;
	my $mins = defined $hkd_ts ? _format_timespan(time - $hkd_ts) : '-';
	my @row = ($host->id, $host->name, $host->address, $mins,
			    $host->vms->count);
	push(@body, \@row);
    }
    
    _print_table(\@header, \@body) unless $self->{quiet};
}

sub help_host_list {
    print <<EOT
host list: list the hosts registered on the platform
usage: host list
    
  Lists consists of Id, Name, Address, HKD and VMs assigned, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only host matched by FILTER
    -q [--quiet]         : don't print the header
EOT
}

sub cmd_user_list {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('user');
    my @header = qw(Id Login Department Telephone Email);
    my @body;
    while (my $user = $rs->next) {
	my @row = map {$user->$_ // '-'} 
		    qw(id login department telephone email);
	push(@body, \@row);
    }
    
    _print_table(\@header, \@body) unless $self->{quiet};
}

sub help_user_list {
    print <<EOT
user list: list the registered users
usage: user list
    
    Lists consists of the users' id, login, department, telephone and email
    separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only user matched by FILTER
    -q [--quiet]         : don't print the header
EOT
}

sub cmd_vm_list {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    my @header = ("Id","Name","User","Host","State","UserState");
    my @body;
    while (my $vm = $rs->next) {
	my $vmr = $vm->vm_runtime;
	my @row = map { $_ // '-' } ( $vm->id,
				       $vm->name,
				       $vm->user->login,
				       defined $vmr->host ? $vmr->host->name : undef,
				       $vmr->vm_state,
				       $vmr->user_state );
	push(@body, \@row);
    }
    
    _print_table(\@header, \@body) unless $self->{quiet};
}

sub help_vm_list {
    print <<EOT
vm list: Returns a list with the virtual machines.
usage: vm list
    
  Lists consists of Id, Name, State and Host, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only vm matched by FILTER
    -q [--quiet]         : don't print the header
EOT
}

sub _print {
    my ($self, @msg) =(@_);
    print @msg, "\n" unless $self->{quiet};
}

sub cmd_host_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $id = $self->{admin}->cmd_host_add(%args);
    $self->_print("Host added with id ".$id);
}

sub help_host_add {
    print <<EOT
host add: Adds hosts.
usage: host add name=value address=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $id = $self->{admin}->cmd_vm_add(%args);
    $self->_print( "VM added with id ".$id);
}

sub help_vm_add {
    print <<EOT
vm add: Adds virtual machines.
usage: vm add name=value user_id=value osi_id=value ip=value storage=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_user_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $id = $self->{admin}->cmd_user_add(%args);
    $self->_print( "User added with id ".$id);
}

sub help_user_add {
    print <<EOT
user add: Adds users.
usage: user add login=value password=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_osi_list {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('osi');   
    my @header = qw(Id Name RAM UserHD Image);
    my @body;
    while (my $osi = $rs->next) {
	my @row = map { defined($_) ? $_ : '-' } map { $osi->$_ } qw(id name memory user_storage_size disk_image);
	push(@body, \@row);
    }
    
    _print_table(\@header, \@body) unless $self->{quiet};
}

sub help_osi_list {
    print <<EOT;
osi list: lists the installed Operating System Images (OSI)
usage: osi list

  Lists consists of Id, Name, RAM size, Home partition size and image
  file name separated by tabs.

Valid options:
    -f [--filter] FILTER : list only OSIs matched by FILTER
    -q [--quiet]         : don't print the header
EOT
}

sub cmd_osi_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $id = $self->{admin}->cmd_osi_add(%args);
    $self->_print( "OSI added with id ".$id);
}

sub help_osi_add {
    print <<EOT
osi add: Adds operating systems images.
usage: osi add name=string disk_image=path [memory=size] [use_overlay=boolean]
		[user_storage_size=size]

    The disk_image is copied to the read-only storage area.
    The default values for the optional parameters are:
	memory=256 
	use_overlay=y
	user_storage_size=undef (no user storage)

Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub _obj_del {
    my ($self, $obj) = @_;
    unless ($self->{quiet}) {
	if (scalar %{$self->{admin}{filter}} eq 0) {
	    print "Are you sure you want to delete all ${obj}s? [y/N] ";
	    my $answer = <>;
	    exit 0 unless $answer =~ /^y/i;
	}
    }
    my $count = $self->get_resultset($obj)->count();
    $self->_print("Deleting ".$count." ${obj}(s)");
}

sub cmd_host_del {
    my $self = shift;
    $self->_obj_del('host', @_);
    $self->{admin}->cmd_host_del();
}

sub help_host_del {
    print <<EOT
host del: Deletes hosts.
usage: host del
       
Valid options:
    -f [--filter] FILTER : deletes hosts matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_user_del {
    my $self = shift;
    $self->_obj_del('user', @_);
    $self->{admin}->cmd_user_del();
}

sub help_user_del {
    print <<EOT
user del: Deletes users.
usage: user del
       
Valid options:
    -f [--filter] FILTER : deletes users matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_del {
    my $self = shift;
    $self->_obj_del('vm', @_);
    $self->{admin}->cmd_vm_del();
}

sub help_vm_del {
    print <<EOT
vm del: Deletes virtual machines.
usage: vm del
       
Valid options:
    -f [--filter] FILTER : deletes virtual machines matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_osi_del {
    my $self = shift;
    $self->_obj_del('osi', @_);
    my $count = $self->{admin}->cmd_osi_del();
    $self->_print("$count osis deleted.");
}

sub help_osi_del {
    print <<EOT
osi del: Deletes operating systems images.
usage: osi del
       
Valid options:
    -f [--filter] FILTER : deletes operating systems images matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_host_propset {
    shift->{admin}->cmd_host_propset(_split_on_equals @_)
}

sub help_host_propset {
    print <<EOT
host propset: Sets host property.
usage: host propset [key=value...]
      
  Example:
  host propset weight=50kg maxtemp=56º
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_user_propset {
    shift->{admin}->cmd_user_propset(_split_on_equals @_)
}

sub help_user_propset {
    print <<EOT
user propset: Sets user property.
usage: user propset [key=value...]
      
  Example:
  user propset genre=male timezone=+1
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_vm_propset {
    shift->{admin}->cmd_vm_propset(_split_on_equals @_)
}

sub help_vm_propset {
    print <<EOT
vm propset: Sets vm property.
usage: vm propset [key=value...]
      
  Example:
  vm propset usage=accounting priority=critical
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub _obj_propget {
    my ($self, $display_cb, @args) = @_;
    my $props = $self->{admin}->propget(@args);
    print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @$props;
}

sub cmd_host_propget {
    shift->_obj_propget(sub { $_->host->name }, 'host', @_);
}

sub help_host_propget {
    print <<EOT
host propget: Gets host property.
usage: host propget [key...]
      
  Example:
  host propget usage priority
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_user_propget {
    shift->_obj_propget(sub { $_->user->login }, 'user', @_);
}

sub help_user_propget {
    print <<EOT
user propget: Gets user property.
usage: user propget [key...]
      
  Example:
  user propget genre timezone
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_vm_propget {
    shift->_obj_propget(sub { $_->vm->name }, 'vm', @_);
}

sub help_vm_propget {
    print <<EOT
vm propget: Lists vm properties
usage: vm propget [key...]
      
  Example:
  vm propget usage priority
      
Valid options:
    -f [--filter] FILTER : sets VM properties on VMs matched by FILTER
EOT
}

sub cmd_host_propdel {
    shift->{admin}->propdel('host', @_);
}

sub help_host_propdel {
    print <<EOT
vm propdel: Deletes host properties.
usage: host propdel [key...]

    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
	host propdel priority -f address=198.168.1.??
      
Valid options:
    -f [--filter] FILTER : Delete properties of hosts matched by FILTER
EOT
}

sub cmd_user_propdel {
    shift->{admin}->propdel('user', @_);
}

sub help_user_propdel {
    print <<EOT
vm propdel: Deletes user properties
usage: user propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
	user propdel timezone -f login=M*,department=sales
      
Valid options:
    -f [--filter] FILTER : Delete properties of users matched by FILTER
EOT
}

sub cmd_vm_propdel {
    shift->{admin}->propdel('vm', @_);
}

sub help_vm_propdel {
    print <<EOT
vm propdel: Deletes VM properties
usage: vm propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
	vm propdel priority -f user=nobody
      
Valid options:
    -f [--filter] FILTER : sets VM properties of VMs matched by FILTER
EOT
}

sub cmd_config_set {
    my $self = shift;
    my %args = _split_on_equals(@_);
    $self->{admin}->cmd_config_set(%args)
}

sub help_config_set {
    print <<EOT
config set: Sets config property.
usage: config set [key=value ...]
      
  Example:
  config set vm_ssh_port=2022 base_storage_path=/var/run/qvd/storage
EOT
}

sub cmd_config_get {
    my $configs = shift->{admin}->cmd_config_get(@_);
    print map { $_->key.'='.$_->value."\n" } @$configs;
}

sub help_config_get {
    print <<EOT
config get: Gets config property.
usage: config get [key...]
      
  Example:
  config get vm_ssh_port base_storage_path
EOT
}


sub cmd_vm_start {
    my ($self, @args) = @_;
    my $count = $self->{admin}->cmd_vm_start();
    $self->_print("Started ".$count." VMs.");
}

sub help_vm_start {
    print <<EOT
vm start: Starts virtual machine.
usage: vm start
      
Valid options:
    -f [--filter] FILTER : starts virtual machine matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_stop {
    my ($self, @args) = @_;
    my $count = $self->{admin}->cmd_vm_stop();
    $self->_print("Stopped ".$count." VMs.");
}

sub help_vm_stop {
    print <<EOT
vm stop: Stops virtual machine.
usage: vm stop
      
Valid options:
    -f [--filter] FILTER : stops virtual machine matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_disconnect_user {
    my ($self, @args) = @_;
    my $count = $self->{admin}->cmd_vm_disconnect_user();
    $self->_print("Disconnected ".$count." users.");
}

sub help_vm_disconnect_user{
    print <<EOT
vm disconnect_user: Disconnects user.
usage: vm disconnect_user
      
Valid options:
    -f [--filter] FILTER : disconnects users on VMs matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub _get_single_vm_runtime {
    my $self = shift;
    my $rs = $self->get_resultset('vm');
    if ($rs->count > 1) {
	die 'Filter matches more than one VM';
    }
    my $vm = $rs->single;
    die 'No matching VMs' unless defined $vm;
    $vm->vm_runtime
}

sub cmd_vm_ssh {
    my ($self, @args) = @_;
    my $vm_runtime = $self->_get_single_vm_runtime;
    my $ssh_port = $vm_runtime->vm_ssh_port;
    die 'SSH access is disabled' unless defined $ssh_port;
    my @cmd = (ssh => ($vm_runtime->vm_address, -p => $ssh_port, @args));
    exec @cmd or die "Unable to exec ssh: $^E";
}

sub help_vm_ssh {
    print <<EOT
vm ssh: Connects to the virtual machine SSH server.
usage: vm ssh

  To pass aditional parameters to SSH add them to the command line after --
  
  Example:
  vm ssh -- -l qvd
       
Valid options:
    -f [--filter] FILTER : connect to the virtual machine matched by FILTER
EOT
}

sub cmd_vm_vnc {
    my ($self, @args) = @_;
    my $vm_runtime = $self->_get_single_vm_runtime;
    my $vnc_port = $vm_runtime->vm_vnc_port;
    die 'VNC access is disabled' unless defined $vnc_port;
    # FIXME Make the vnc client configurable
    my @cmd = (vncviewer => ($vm_runtime->vm_address.'::'.$vnc_port, @args));
    exec @cmd or die "Unable to exec vncviewer: $^E";
}

sub help_config_ssl {
    print <<EOT
config ssl: Sets the SSL certificate and private key
usage: config ssl key=mykey.pem cert=mycert.pem

    Sets the SSL certificate to the one read from the file mycert.pem, and the
    private key to the one read from mykey.pem.

    Example: config ssl key=certs/server-key.pem cert=certs/server-cert.pem
EOT
}


sub cmd_config_ssl {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $key_file = delete $args{key};
    my $cert_file = delete $args{cert};
    if (%args or !$key_file or !$cert_file) {
	help_config_ssl;
	exit 1;
    }
    # FIXME: Is using File::Slurp the best way?
    use File::Slurp; 
    my $cert = eval { read_file($cert_file) } 
	or die "$cert_file: Unable to read cert file: $^E";
    my $key = eval { read_file($key_file) }  
	or die "$key_file: Unable to read key file: $^E";

    $self->{admin}->cmd_config_ssl(key => $key, cert => $cert) 
	and $self->_print("SSL certificate and private key set.\n");
}

sub help_user_passwd {
    print <<EOT
user passwd: Sets the password of a user
usage: user passwd username

    Prompts the user for the new password for the user with login "username"
    and sets it.

    Example: user passwd qvd
EOT
}

sub cmd_user_passwd {
    my ($self, $user) = @_;
    print "New password for $user: ";
    my $passwd = <STDIN>;
    chomp $passwd;
    $self->{admin}->set_password($user, $passwd);
}

sub help_vm_vnc {
    print <<EOT
vm ssh: Connects to the virtual machine VNC server.
usage: vm vnc

  To pass aditional parameters to vncviewer add them to the command line after --
  
  Example:
  vm vnc -- --depth 8
       
Valid options:
    -f [--filter] FILTER : connect to the virtual machine matched by FILTER
EOT
}

sub die_and_help {
    my ($self, $message, $obj) = @_;
    $message = "Unknown error" unless defined($message);
    my @funcs = do {
	no strict;
	grep exists &{"QVD::AdminCLI::$_"}, keys %{"QVD::AdminCLI::"};
    };
    
    @funcs = grep {s/^cmd_([a-z]+)_(\w+)/$1 $2/} @funcs;
    @funcs = grep {m/^${obj}/} @funcs if defined $obj and exists $self->{admin}{objects}{$obj};
    
    print $message.", available subcommands:\n   ";
    print join "\n   ", sort @funcs;
    print "\n\n";
    
    exit 1;
}

1;

__END__

=head1 NAME

QVD::AdminCLI - QVD CLI Administration Tool

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::Admin;
    my $admin = QVD::AdminCLI->new($quiet);
    $admin->set_filter('login=mua*');
    $admin->dispatch_command('user', 'del');

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

