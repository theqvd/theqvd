package QVD::AdminCLI;

use warnings;
use strict;

use QVD::Admin;

sub new {
    my $class = shift;
    my $admin = QVD::Admin->new;
    my $self = {
	admin => $admin,
    };
    bless $self, $class;
}

sub set_filter {
    my ($self, $filter_string) = @_;
    $self->{admin}->set_filter($filter_string);
}

sub _get_result_set {
    shift->{admin}->_get_result_set(@_);
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

sub cmd_host_list {
    my ($self, @args) = @_;
    _print_header "Id", "Name", "Address ","HKD", "VMs assigned"
	    unless $self->{quiet};

    my $rs = $self->_get_result_set('host');
    while (my $host = $rs->next) {
	# FIXME proper formatting
	my $hkd_ts = defined $host->runtime ? $host->runtime->hkd_ok_ts : undef;
	my $mins = defined $hkd_ts ? _format_timespan(time - $hkd_ts) : '-';
	print join "\t", $host->id, $host->name, $host->address, $mins,
			    $host->vms->count;
	print "\n";

    }
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
    _print_header "Id","Login" unless $self->{quiet};
    my $rs = $self->_get_result_set('user');
    while (my $user = $rs->next) {
	printf "%s\t%s\n", $user->id, $user->login;
    }
}

sub help_user_list {
    print <<EOT
user list: Returns a list with the users.
usage: user list
    
  Lists consists of Id and Login, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only user matched by FILTER
    -q [--quiet]         : don't print the header
EOT
}

sub cmd_vm_list {
    my ($self, @args) = @_;
    _print_header "Id","Name","User","Host","State","UserState" unless $self->{quiet};
    my $rs = $self->_get_result_set('vm');
    while (my $vm = $rs->next) {
	my $vmr = $vm->vm_runtime;
	print(join("\t",
		   map { defined $_ ? $_ : '-' } ( $vm->id,
						   $vm->name,
						   $vm->user->login,
						   defined $vmr->host ? $vmr->host->name : undef,
						   $vmr->vm_state,
						   $vmr->user_state )),
	      "\n");
    }
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
    my $id = $self->{admin}->cmd_host_add(@_);
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
    my $id = $self->{admin}->cmd_vm_add(@_);
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
    my $id = $self->{admin}->cmd_user_add(@_);
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
    _print_header qw(Id Name RAM UserHD Image)
	unless $self->{quiet};
    my $rs = $self->_get_result_set('osi');
    while (my $osi = $rs->next) {
	print(join("\t",
		   map { defined($_) ? $_ : '-' }
		   map { $osi->$_ } qw(id name memory user_storage_size disk_image)),
	      "\n");
    }
}

sub help_osi_list {
    print <<EOT;
osi list: list the Operative System Images (OSI) configured.
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
    my $id = $self->{admin}->cmd_osi_add(@_);
    $self->_print( "OSI added with id ".$id);
}

sub help_osi_add {
    print <<EOT
osi add: Adds operating systems images.
usage: osi add name=value memory=value use_overlay=value disk_image=value
       
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
    my $count = $self->_get_result_set($obj)->count();
    $self->_print("Deleting ".$count." ${obj}(s)");
    $self->{admin}->_obj_del;
}

sub cmd_host_del {
    shift->_obj_del('host', @_);
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
    shift->_obj_del('user', @_);
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
    shift->_obj_del('vm', @_);
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
    my ($self, @args) = @_;
    $self->_obj_del('OSI', @args);
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
    shift->{admin}->cmd_host_propset(@_)
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
    shift->{admin}->cmd_user_propset(@_)
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
    shift->{admin}->cmd_vm_propset(@_)
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
    my $props = $self->{admin}->_obj_propget(@args);
    print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @$props;
}

sub cmd_host_propget {
    shift->_obj_propget(sub { $_->host->name }, @_);
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
    shift->_obj_propget(sub { $_->user->login }, @_);
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
    shift->_obj_propget(sub { $_->vm->name }, @_);
}

sub help_vm_propget {
    print <<EOT
vm propget: Gets vm property.
usage: vm propget [key...]
      
  Example:
  vm propget usage priority
      
Valid options:
    -f [--filter] FILTER : sets VM properties on VMs matched by FILTER
EOT
}

sub cmd_config_set {
    shift->{admin}->cmd_config_set(@_)
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
    shift->{admin}->cmd_config_get(@_)
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
    shift->{admin}->cmd_vm_start(@_)
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
    shift->{admin}->cmd_vm_stop(@_)
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
    shift->{admin}->cmd_vm_disconnect_user(@_)
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


sub cmd_vm_ssh {
    shift->{admin}->cmd_vm_ssh(@_)
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
    shift->{admin}->cmd_vm_vnc(@_)
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

