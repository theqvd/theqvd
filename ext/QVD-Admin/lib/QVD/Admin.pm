package QVD::Admin;

our $VERSION = '0.01';

use warnings;
use strict;

use File::Copy qw(copy move);
use File::Basename qw(basename);

use QVD::DB::Simple;
use QVD::Config;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
use QVD::Log;

my $osi_default_memory  = cfg('osi.default.memory');
my $osi_default_overlay = cfg('osi.default.overlay');

my $images_path         = cfg('path.storage.images');

sub new {
    my $class = shift;
    my $quiet = shift;
    my $self = { filter => {},
		 quiet => $quiet,
		 objects => { host => 'Host',
			      vm => 'VM',
			      user => 'User',
			      config => 'Config',
			      osi => 'OSI' } };
    bless $self, $class;
}

sub set_filter {
    my ($self, %conditions) = @_;
    while (my ($k, $v) = each %conditions) {
	$k = 'me.id' if $k eq 'id';
	if (defined($v)) {
	    if (ref $v) {
		$self->{filter}{$k} = $v;
	    } elsif ($v =~ /[*?]/) {
		$v =~ s/([_%])/\\$1/g;
		$v =~ tr/*?/%_/;
		$self->{filter}{$k} = {like => $v};
	    } else {
		$self->{filter}{$k} = $v;
	    }
	}
    }
}

sub reset_filter {
    shift->{filter} = {}
}

sub get_resultset {
    my ($self, $obj) = @_;
    my $db_object = $self->{objects}{$obj};
    if (!defined $db_object) {
	die("$obj: Unsupported object");
    }
    my $method = $self->can("get_result_set_for_${obj}");
    if ($method) {
	$self->$method;
    }
    my $rs = rs($db_object);
    $rs = $rs->search($self->{filter})
	if defined $self->{filter};

    $rs
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
    rs(VM)->search($filter,
		   { join => ['osi', 'user',
			      { vm_runtime => 'host'}] });
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

sub _aton { unpack('N', pack('C4', split /\./, shift)) }
sub _ntoa { join '.', unpack('C4', pack('N', shift)) }

sub _get_free_ip {
    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_) => 1 } rs(VM)->get_column('ip')->all;
    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}

sub _obj_add {
    my ($self, $obj, $required_params, @args) = @_;
    my $params = ref $args[0] ? $args[0] : {@args};
    unless (_set_equals([keys %$params], $required_params)) {
	die "The required parameters are: ",
	    join(", ", @$required_params), " (you supplied ",
	    join(", ", keys %$params), ")";
    }
    my $rs = $self->get_resultset($obj);
    $rs->create($params);
}

sub _obj_del {
    my ($self, $obj) = @_;
    my $rs = $self->get_resultset($obj);
    $rs->delete_all;
}

sub _obj_propget {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};
    my @props = $rs->search_related('properties', $condition);
    return \@props;
}

sub _obj_propset {
    my ($self, $obj, @args) = @_;
    my $params = {@args};
    my $rs = $self->get_resultset($obj);
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't seem to let us
    my $ci = 0;
    my $success = 0;
    while (my $obj = $rs->next) {
	foreach my $key (keys %$params) {
	    $obj->properties->search({key => $key})->update_or_create(
		{ key => $key, value => $params->{$key} },
		{ key => 'primary' }
	    );
	    $success = 1;
	}
	$ci = $ci + 1;
    }
    if (!$success) {
	$ci = -1;
    }
    $ci;
}

sub _start_vm {
    my ($self, $vmrt) = @_;
    $vmrt->vm_state eq 'stopped'
	or die "Unable to start machine, already running";
    if (!defined $vmrt->host_id) {
	require QVD::L7R::LoadBalancer;
	my $lb = QVD::L7R::LoadBalancer->new();
        my $free_host = $lb->get_free_host($vmrt->vm);
        if (!defined $free_host) {
            die "Unable to start machine, no hosts available";
        }
        $vmrt->set_host_id($free_host);
    }
    $vmrt->send_vm_start;
}

sub _stop_vm {
    my ($self, $vmrt) = @_;
    $vmrt->send_vm_stop;
}

sub _disconnect_user {
    my ($self, $vmrt) = @_;
    $vmrt->send_user_abort;
}

sub _lenton {
    my $len = shift;
    my $zeros = 32 - $len;
    return ((0xffffffff >> $zeros) << $zeros);
}

sub propset {
    my ($self, $object, @args) = @_;
    $self->_obj_propset($object, @args);
}

sub propget {
    my $self = shift;
    $self->_obj_propget(@_);
}

sub propdel {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};
    $rs->search_related('properties', $condition)->delete;
}

sub set_password {
    my ($self, $user, $password) = @_;
    my $row = rs('User')->find({login => $user}) or die "No such user: $user";
    $row->update({password => $password});
}

sub cmd_config_del {
    my ($self, @keys) = @_;

    my $rs = $self->get_resultset("config");
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};

    my $ci = $rs->search($condition)->count;
    $rs->search($condition)->delete;
    
    $ci;
    
}

sub cmd_config_get {
    my ($self, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my $rs = $self->get_resultset('config');
    my @configs = $rs->search($condition);
    return \@configs;
}

sub cmd_config_set {
    my ($self, %args) = @_;
    my $rs = $self->get_resultset('config');
    foreach my $key (keys %args) {
        if ($key =~ /^l7r\.ssl\./) {
            warn "to set SSL keys and certificates use the 'config ssl' command\n";
        }
	else {
            $rs->update_or_create({ key => $key,
                                    value => $args{$key}
                                  });
        }
    }
}

sub cmd_config_ssl {
    my ($self, %args) = @_;
    my $cert = delete $args{cert} or die "Certificate is required";
    my $key = delete $args{key} or die "Private key is required";
    rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.cert',
				       value => $cert });
    rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.key',
				       value => $key });
    1
}

sub cmd_host_add {
    my ($self, @args) = @_;
    txn_do {
	my $row = $self->_obj_add('host',
				  [qw/name address frontend backend/],
				  @args, frontend => 1, backend => 1);
	rs(Host_Runtime)->create({ host_id  => $row->id,
				   state    => 'stopped',
				   blocked  => 'false' });
	$row->id
    };
}

sub cmd_host_block {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('host');
    while (defined(my $host = $rs->next)) {
	txn_eval {
	    $host->discard_changes;
	    $host->runtime->block;
	    $counter++;
	};
	# FIXME: report errors
    }
    $counter
}

sub cmd_host_block_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $hostrt = rs(Host_Runtime)->find($id) //
	    die "Host $id doesn't exist";
	$hostrt->block;
    };
}

sub cmd_host_del {
    shift->_obj_del('host', @_);
}

sub cmd_host_propget {
    shift->_obj_propget('host', @_);
}

sub cmd_host_propset {
    shift->_obj_propset('host', @_);
}

sub cmd_host_unblock {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('host');
    while (defined(my $host = $rs->next)) {
	txn_eval {
	    $host->discard_changes;
	    $host->runtime->unblock;
	    $counter++;
	};
    # FIXME: report errors
    }
    $counter
}

sub cmd_host_unblock_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $hostrt = rs(Host_Runtime)->find($id) //
	    die "Host $id doesn't exist";
	$hostrt->unblock;
    };
}

sub cmd_osi_add {
    my ($self, %params) = @_;
    my @required_params = qw/name memory use_overlay disk_image/;

    # FIXME: detect type of image and set use_overlay accordingly, iso => no overlay
    $params{memory}      //= $osi_default_memory;
    $params{use_overlay} //= $osi_default_overlay;
    
    #die "The required parameters are ".join(", ", @required_params)
	#unless _set_equals([keys %params], \@required_params);

    mkdir $images_path, 0755;
    -d $images_path or die "Directory $images_path does not exist";

    my $src = delete $params{disk_image};
    my $file = basename($src);
    my $tmp = "$images_path/$file.tmp";
    copy($src, $tmp) or die "Unable to copy $src to $tmp: $^E";

    $params{disk_image} = '-';
    my $id;
    txn_do {
	my $rs = $self->get_resultset('osi');
	my $row = $rs->create(\%params);
	$id = $row->id;
	my $disk_image = "$id-$file";
	move($tmp, "$images_path/$disk_image");
	$row->update({disk_image => $disk_image});
    };
    $id
}

sub cmd_osi_del {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('osi');
    while (my $osi = $rs->next) {
	if ($osi->vms->count == 0) {
	    warn "deleting osi ".$osi->id;
	    $osi->delete;
	    $counter++;
	    # FIXME Should we delete the actual image file?
	}
    }
    $counter
}

sub cmd_user_add {
    my ($self, %params) = @_;
    my %core_params = ( login    => delete $params{login},
			password => delete $params{password} );
    $self->_obj_add('user', [qw/login password/], %core_params)
	-> id;
}

sub cmd_user_del {
    shift->_obj_del('user', @_);
    # FIXME Should we delete VMs, overlay images and home disk files?
}

sub cmd_user_propget {
    shift->_obj_propget('user', @_);
}

sub cmd_user_propset {
    shift->_obj_propset('user', @_);
}

sub cmd_vm_add {
    my ($self, %params) = @_;
    txn_do {
	if (exists $params{osi}) {
	    my $key = $params{osi};
	    my $rs = rs(OSI)->search({name => $key});
	    die "$key: No such OSI" if ($rs->count() < 1);
	    $params{osi_id} = $rs->single->id;
	    delete $params{osi};
	}
	if (exists $params{user}) {
	    my $key = $params{user};
	    my $rs = rs(User)->search({login => $key});
	    die "$key: No such user" if ($rs->count() < 1);
	    $params{user_id} = $rs->single->id;
	    delete $params{user};
	}
	unless ($params{ip}) {
	    $params{ip} = $self->_get_free_ip;
	    INFO "assigned IP: $params{ip}";
	}
	$params{storage} = '';
	my $row = $self->_obj_add('vm', [qw/name user_id osi_id ip storage/],
				  \%params);
	rs(VM_Runtime)->create({vm_id         => $row->id,
				osi_actual_id => $row->osi_id,
				vm_state      => 'stopped',
				user_state    => 'disconnected',
				blocked       => 'false'});
	$row->id
    };
}

sub cmd_vm_block {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
	txn_eval {
	    $vm->discard_changes;
	    $vm->vm_runtime->block;
	    $counter++;
	};
	# FIXME: report errors
    }
    $counter
}

sub cmd_vm_block_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $vmrt = rs(VM_Runtime)->find($id) //
	    die "VM $id doesn't exist";
	$vmrt->block;
    };
}

sub cmd_vm_del {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    # Checks if vm is running
    while (my $vm = $rs->next) {
	if ($vm->vm_runtime->vm_state eq 'stopped') {
	    $vm->delete;
	}
    }
    # FIXME Should we delete the overlay image and home disk file?
}

sub cmd_vm_disconnect_user {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
	txn_eval {
	    $vm->discard_changes;
	    $self->_disconnect_user($vm->vm_runtime);
	    $counter++;
	};
	# FIXME: report errors
    }
    $counter
}

sub cmd_vm_disconnect_user_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $vmrt = rs(VM_Runtime)->find($id) //
	    die "VM $id doesn't exist";
	$self->_disconnect_user($vmrt);
    };
}

sub cmd_vm_edit {
    my ($self, %args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    my @vm_columns = $rs->result_source->columns;
    while (defined(my $vm = $rs->next)) {
	txn_eval {
        $vm->discard_changes;
        my (%vm_args, %vm_runtime_args);
        foreach my $k (keys %args) {
            if (grep { $_ eq $k } @vm_columns) {
                $vm_args{$k} = $args{$k};
            } else {
                $vm_runtime_args{$k} = $args{$k};
            }
        }
        $vm->update (\%vm_args);
        $vm->vm_runtime->update (\%vm_runtime_args);
        $counter++;
	};
    # FIXME: report errors
    }
    $counter
}

sub cmd_vm_propget {
    shift->_obj_propget('vm', @_);
}

sub cmd_vm_propset {
    shift->_obj_propset('vm', @_);
}

sub cmd_vm_start {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
	txn_eval {
	    $vm->discard_changes;
	    $self->_start_vm($vm->vm_runtime);
	    $counter++;
	};
	# TODO Log error messages ($@) in some way
    }
    $counter
}

sub cmd_vm_start_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $vmrt = rs(VM_Runtime)->find($id) //
	    die "VM $id doesn't exist";
	$self->_start_vm($vmrt);
    };
}

sub cmd_vm_stop {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
	txn_eval {
	    $vm->discard_changes;
	    $self->_stop_vm($vm->vm_runtime);
	    $counter++;
	};
	# TODO Log error messages ($@) in some way
    }
    $counter
}

sub cmd_vm_stop_by_id {
    my ($self, $id) = @_;
    $id or die "Missing parameter id" unless defined $id;
    txn_do {
	my $vm = rs(VM_Runtime)->find($id) //
	    die "VM $id doesn't exist";
	$self->_stop_vm($vm);
    };
}

sub cmd_vm_unblock {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
	txn_eval {
	    $vm->discard_changes;
	    $vm->vm_runtime->unblock;
	    $counter++;
	};
    # FIXME: report errors
    }
    $counter
}

sub cmd_vm_unblock_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
	my $vmrt = rs(VM_Runtime)->find($id) //
	    die "VM $id doesn't exist";
	$vmrt->unblock;
    };
}

1;

__END__

=head1 NAME

QVD::Admin - QVD Administration API

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::Admin;
    my $admin = QVD::Admin->new;
    my $id = $admin->cmd_osi_add(name => "Ubuntu 9.10 (x86)", 
				 memory => 512,
				 use_overlay => 1,
				 disk_image => "/var/tmp/U910_x86.img");
    print "OSI added with id $id\n";

    $admin->set_filter(user=> 'qvd');
    my $count = $admin->cmd_vm_start();
    print "Started $count virtual machines.\n";

=head1 DESCRIPTION

This module implements the QVD Administration API.

=head2 API

=over

=item set_filter(%conditions)

Add conditions to the current filter. The filter is applied to all subsequent
operations. The keys that can be used depend on the object in question. 

=item reset_filter()

Removes all conditions from the filter.

=item get_resultset($object)

Return the DBIx::Class result set for the given object type. The valid object
types are listed in the "objects" member hash. They are host, vm, uesr, config,
and osi.

=item cmd_host_add(%parameters)

Add a host. The required parameters are name and address. 

Returns the id of the new host. 

=item cmd_vm_add(%parameters)

Add a virtual machine. The required parameters are name, user, osi, and ip.
OSI and user can be specified by name (login) or by id (osi_id, user_id). The
optional parameter is storage.

Returns the id of the new virtual machine. 

=item cmd_user_add(%parameters)

Adds a user. The required parameters are login and password.

Returns the id of the new user.

=item cmd_osi_add(%parameters)

Adds an operating system image. The required parameters are name and
disk_image. The value of disk_image should be the path of a disk image file.
The image file is copied to the read only storage area.  The optional
parameters are memory (megabytes), user_storage_size (megabytes), and
use_overlay (y/n).

=item cmd_host_del()

Deletes all hosts that match the current filter.

=item cmd_user_del()

Deletes all users that match the current filter.

=item cmd_vm_del()

Deletes all virtual machines that match the current filter.

=item cmd_osi_del()

Deletes all OSIs that match the current filter. Only OSIs that have no virtual
machines assigned are deleted. Returns the number of OSIs that were deleted.

=item propset($object, %properties)

Set the given properties on all $objects (hosts, vms, users) that are matched
by the current filter.

The parameter $object must be either "host", "vm", or "user".

=item cmd_host_propset(%properties)

Wrapper for propset('host', %properties).

=item cmd_vm_propset(%properties)

Wrapper for propset('vm', %properties).

=item cmd_user_propset(%properties)

Wrapper for propset('user', %properties).

=item propget($object, @keys)

Returns the properties with given keys for the $objects that are matched by the
current filter. 

The parameter $object must be either "host", "vm", or "user".

The return value is a reference to a list of the DBIx::Class::Row objects that
represent the individual property entries.

=item cmd_host_propget(@keys)

Wrappper for propget('host', @keys).

=item cmd_vm_propget(@keys)

Wrappper for propget('vm', @keys).

=item cmd_user_propget(@keys)

Wrappper for propget('user', @keys).

=item propdel($object, @keys)

Deletes the properties with the given keys for the $objects that are matched by
the current filter.

The parameter $object must be either "host", "vm", or "user".

Returns whatever the DBIx::Class::Resultset->delete call returns.

=item cmd_config_set(%configs)

Sets configuration keys to values.

=item cmd_config_get(@keys)

Returns the configuration table entries with the given keys.

The return value is a reference to a list of the DBIx::Class::Row objects that
represent the individual configuration entries.

=item cmd_vm_start_by_id($id)

Assigns the virtual machine with id $id to a host and starts it.

Throws an exception using "die" if it wasn't possible to start the vm.

=item cmd_vm_start()

Assigns the virtual machines matched by the current filter to hosts and starts
them. Any errors that ocurred are ignored. 

Returns the number of virtual machines that were succesfully started.

=item cmd_vm_stop_by_id($id)

Schedules the stopping of the virtua machine with the given id.

Throws an exception using "die" if it wasn't possible to stop the vm.

=item cmd_vm_stop()

Schedules the stopping of the virtual machines matched by the current filter.
Any errors that ocurred are ignored. 

Returns the number of virtual machines that were succesfully scheduled to stop.

=item cmd_vm_disconnect_user()

Disconnects the users connected to the virtual machines matched by the current
filter.

Returns the number of users that were disconnected.

=item cmd_config_ssl(cert => 'certificate', key => 'privatekey')

Sets the SSL certificate to 'certificate' and the private key to 'privatekey'.
Returns 1 on success.

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
