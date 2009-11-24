package QVD::Admin;

use warnings;
use strict;

use QVD::DB;
use QVD::Config;

sub new {
    my $class = shift;
    my $quiet = shift;
    my $db = shift // QVD::DB->new();
    my $self = {db => $db,
		filter => {},
		quiet => $quiet,
		objects => {
		    host => 'Host',
		    vm => 'VM',
		    user => 'User',
		    config => 'Config',
		    osi => 'OSI',
		},
    };
    bless $self, $class;
}

sub _split_on_equals {
    my %r = map { my @a = split /=/, $_, 2; $a[0] => $a[1] } @_;
    \%r
}

sub set_filter {
    my ($self, $filter_string) = @_;
    # 'a=b,c=d' -> {'a' => 'b', 'c' => 'd}
    my $conditions = _split_on_equals split /,\s*/, $filter_string;
    while (my ($k, $v) = each %$conditions) {
	if ($v =~ /[*?]/) {
	    $v =~ s/([_%])/\\$1/g;
	    $v =~ tr/*?/%_/;
	    $self->{filter}{$k} = {like => $v};
	} else {
	    $self->{filter}{$k} = $v;
	}
    }
}

sub _get_result_set {
    my ($self, $obj) = @_;
    my $db_object = $self->{objects}{$obj};
    if (!defined $db_object) {
	$self->die_and_help ("$obj: Unsupported object", $obj);
    }
    my $method = $self->can("get_result_set_for_${obj}");
    if ($method) {
	$self->$method;
    }
    elsif ($self->{filter}) {
	$self->{db}->resultset($db_object)->search($self->{filter});
    } else {
	$self->{db}->resultset($db_object);
    }
}

sub dispatch_command {
    my ($self, $object, $command, $help, @args) = @_;
    $self->die_and_help ("Valid command expected") unless defined $object;
    $self->die_and_help ("$object: Valid command expected", $object) unless defined $command;
    my $method = $self->can($help ? "help_${object}_${command}" : "cmd_${object}_${command}");
    if (defined $method) {
	$self->{current_object} = $object;
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

    my $rs = $self->_get_result_set($self->{current_object});
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
host list: Returns a list with the virtual machines.
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
    my $rs = $self->_get_result_set($self->{current_object});
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

sub _filter_obj {
    my ($self, $term_map) = @_;
    my $filter = $self->{filter};
    while (my ($src,$dst) = each %$term_map) {
	$filter->{$dst} = delete $filter->{$src} if exists $filter->{$src}
    }
    $filter
}

sub get_result_set_for_vm {
    my ($self, @args) = @_;
    my %term_map = (
	name => 'me.name',
	osi => 'osi.name',
	user => 'user.login',
	host => 'host.name',
	state => 'vm_runtime.vm_state',
    );
    my $filter = $self->_filter_obj(\%term_map);
    $self->{db}->resultset('VM')->search($filter, {
	    join => ['osi', 'user', { vm_runtime => 'host'}],
	});
}

sub cmd_vm_list {
    my ($self, @args) = @_;
    _print_header "Id","Name","State","Host" unless $self->{quiet};
    my $rs = $self->_get_result_set('vm');
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	my $host = $vm_runtime->host;
	my $host_name = defined $host ? $host->name : '-';
	print join "\t", $vm->id, $vm->name, $vm_runtime->vm_state, $host_name;
	print "\n";
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

sub _set_equals {
    my ($a, $b) = @_;
    return 0 if scalar @$a != scalar @$b;
    my @a = sort @$a;
    my @b = sort @$b;
    foreach my $i (0 .. @a-1) {
	return 0 if $a[$i] ne $b[$i];
    }
    return 1;
}

sub _obj_add {
    my ($self, $required_params, @args) = @_;
    my $params = ref $args[0] ? $args[0] : _split_on_equals @args;
    unless (_set_equals([keys %$params], $required_params)) {
	print "The required parameters are: ",
	    join(", ", @$required_params),
	    "\n";
	exit 1;
    }
    my $rs = $self->_get_result_set($self->{current_object});
    $rs->create($params);
}

sub cmd_host_add {
    my $self = shift;
    my $row = $self->_obj_add([qw/name address/], @_);
    $self->{db}->resultset('Host_Runtime')
			    ->create({host_id => $row->id});
    print "Host added with id ".$row->id."\n" unless $self->{quiet};
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
    my ($self,@args) = @_;
    my $params = _split_on_equals @args;
    if (exists $params->{osi}) {
	my $key = $params->{osi};
	my $rs = $self->{db}->resultset('OSI')
				->search({name => $key});
	die "$key: No such OSI" if ($rs->count() < 1);
	$params->{osi_id} = $rs->single->id;
	delete $params->{osi};
    }
    if (exists $params->{user}) {
	my $key = $params->{user};
	my $rs = $self->{db}->resultset('User')
				->search({login => $key});
	die "$key: No such user" if ($rs->count() < 1);
	$params->{user_id} = $rs->single->id;
	delete $params->{user};
    }
    $params->{storage} = '';
    my $row = $self->_obj_add([qw/name user_id osi_id ip storage/], 
				$params);
    $self->{db}->resultset('VM_Runtime')->create({
	    vm_id => $row->id,
	    osi_actual_id => $row->osi_id,
	    vm_state => 'stopped',
	    x_state => 'disconnected',
	    user_state => 'disconnected',
	});
    print "VM added with id ".$row->id."\n" unless $self->{quiet};
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
    my $row = $self->_obj_add([qw/login password/], @_);
    print "User added with id ".$row->id."\n" unless $self->{quiet};
}

sub help_user_add {
    print <<EOT
user add: Adds users.
usage: user add login=value password=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_osi_add {
    my ($self, @args) = @_;
    my $params = _split_on_equals @args;

    # Default OSI parameters
    # FIXME Detect type of image and set use_overlay accordingly, iso=no overlay
    $params->{memory} //= 256;
    $params->{use_overlay} //= 1;
    
    use File::Basename qw/basename/;
    my $img = $params->{disk_image};
    $params->{disk_image} = basename($img);

    die "Invalid parameters" unless _set_equals([keys %$params],
	[qw/name memory use_overlay disk_image/]);

    # Copy image to ro-directory
    # FIXME Overwriting existing image should be an error
    die "disk_image is not optional" unless defined $params->{disk_image};
    my $destination = QVD::Config->get('ro_storage_path');
    use File::Copy qw/copy/;
    copy($img, $destination) or die "Unable to copy $img to storage: $^E";

    my $rs = $self->_get_result_set($self->{current_object});
    my $row = $rs->create($params);

    print "OSI added with id ".$row->id."\n" unless $self->{quiet};
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
	if (scalar %{$self->{filter}} eq 0) {
	    print "Are you sure you want to delete all ${obj}s? [y/N] ";
	    my $answer = <>;
	    exit 0 unless $answer =~ /^y/i;
	}
    }
    my $rs = $self->_get_result_set($self->{current_object});
    print "Deleting ".$rs->count." ${obj}(s)\n" unless $self->{quiet};
    $rs->delete_all;
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
    # FIXME Should we delete the actual image file?
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

sub _obj_propset {
    my ($self, @args) = @_;
    my $params = _split_on_equals @args;
    my $rs = $self->_get_result_set($self->{current_object});
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't seem to let us
    while (my $obj = $rs->next) {
	foreach my $key (keys %$params) {
	    $obj->properties->search({key => $key})->update_or_create(
		{ key => $key, value => $params->{$key} },
		{ key => 'primary' }
	    );
	}
    }
}

sub cmd_host_propset {
    shift->_obj_propset(@_);
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
    shift->_obj_propset(@_);
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
    shift->_obj_propset(@_);
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
    my $rs = $self->_get_result_set($self->{current_object});
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my @props = $rs->search_related('properties', $condition);
    print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @props;
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
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_config_set {
    my ($self, @args) = @_;
    my $params = _split_on_equals @args;
    my $rs = $self->_get_result_set($self->{current_object});
    foreach my $key (keys %$params) {
	$rs->update_or_create({
		key => $key,
		value => $params->{$key}
	    });
    }
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
    my ($self, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my $rs = $self->_get_result_set($self->{current_object});
    my @configs = $rs->search($condition);
    print map { $_->key.'='.$_->value."\n" } @configs;
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
    my $rs = $self->_get_result_set($self->{current_object});
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->vm_state eq 'stopped') {
	    unless ($vmas->assign_host_for_vm($vm_runtime)) {
		print "Unable to assign VM ".$vm->id." to a host\n";
		next;
	    }
	    unless ($vmas->schedule_start_vm($vm_runtime)) {
		print "Unable to start VM ".$vm->id." on host "
			.$vm_runtime->host->name."\n";
		next;
	    }
	    print "Scheduled the start of VM ".$vm->id." on host ".
		$vm_runtime->host->name."\n" unless $self->{quiet};
	} else {
	    print "VM ".$vm->id." is not in the 'stopped' state\n" unless $self->{quiet};
	}
    }
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
    my $rs = $self->_get_result_set($self->{current_object});
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->vm_state eq 'running') {
	    $vmas->schedule_stop_vm($vm_runtime);
	    print "Scheduled the stop of VM ".$vm->id." on host ".
		$vm_runtime->host->name."\n" unless $self->{quiet};
	} else {
	    print "VM ".$vm->id." is not in the 'running' state\n"
		unless $self->{quiet};
	}
    }
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
    my $rs = $self->_get_result_set($self->{current_object});
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
    my $counter = 0;
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->user_state eq 'connected') {
	    print "Disconnecting user on VM ".$vm->id,"\n" unless $self->{quiet};
	    $vmas->disconnect_nx($vm_runtime);
	    $counter++;
	} else {
	    print "No user connected on VM ".$vm->id,"\n" unless $self->{quiet};
	}
    }
    print "Disconnected $counter users.\n" unless $self->{quiet};
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

sub _get_single_running_vm_runtime {
    my $self = shift;
    my $rs = $self->_get_result_set('vm');
    if ($rs->count > 1) {
	die 'Filter matches more than one VM';
    }
    my $vm = $rs->single;
    die 'No matching VMs' unless defined $vm;
    my $vm_runtime = $vm->vm_runtime;
    die 'The VM is not running' unless $vm_runtime->vm_state eq 'running';
}

sub cmd_vm_ssh {
    my ($self, @args) = @_;
    my $vm_runtime = $self->_get_single_running_vm_runtime;
    my $ssh_port = $vm_runtime->vm_ssh_port;
    die 'SSH access is disabled' unless defined $ssh_port;
    my @cmd = (ssh => ($vm_runtime->vm_address, -p => $ssh_port, @args));
    exec @cmd;
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
    my $vm_runtime = $self->_get_single_running_vm_runtime;
    my $vnc_port = $vm_runtime->vm_vnc_port;
    die 'VNC access is disabled' unless defined $vnc_port;
    my @cmd = (vncviewer => ($vm_runtime->vm_address.'::'.$vnc_port, @args));
    exec @cmd;
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
	grep exists &{"QVD::Admin::$_"}, keys %{"QVD::Admin::"};
    };
    
    @funcs = grep {s/^cmd_([a-z]+)_(\w+)/$1 $2/} @funcs;
    @funcs = grep {m/^${obj}/} @funcs if defined $obj and exists $self->{objects}{$obj};
    
    print $message.", available subcommands:\n   ";
    print join "\n   ", sort @funcs;
    print "\n\n";
    
    exit 1;
}

1;

__END__

=head1 NAME

QVD::Admin - The great new QVD::Admin!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Admin;

    my $foo = QVD::Admin->new();
    ...

=head1 AUTHOR

Qindel Formacion y Servicios S.L., C<< <joni.salonen at qindel.es> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
