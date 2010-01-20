package QVD::Admin;

use warnings;
use strict;

use QVD::DB::Simple;
use QVD::Config;

sub new {
    my $class = shift;
    my $quiet = shift;
    my $self = { filter => {},
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

sub set_filter {
    my ($self, %conditions) = @_;
    while (my ($k, $v) = each %conditions) {
	$k = 'me.id' if $k eq 'id';
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

sub cmd_host_add {
    my $self = shift;
    my $row = $self->_obj_add('host', [qw/name address/], @_);
    rs(Host_Runtime)->create({host_id => $row->id});
    $row->id
}

sub cmd_vm_add {
    my ($self,@args) = @_;
    my $params = {@args};
    if (exists $params->{osi}) {
	my $key = $params->{osi};
	my $rs = rs(OSI)->search({name => $key});
	die "$key: No such OSI" if ($rs->count() < 1);
	$params->{osi_id} = $rs->single->id;
	delete $params->{osi};
    }
    if (exists $params->{user}) {
	my $key = $params->{user};
	my $rs = rs(User)->search({login => $key});
	die "$key: No such user" if ($rs->count() < 1);
	$params->{user_id} = $rs->single->id;
	delete $params->{user};
    }
    $params->{storage} = '';
    my $row = $self->_obj_add('vm', [qw/name user_id osi_id ip storage/], 
				$params);
    rs(VM_Runtime)->create({ vm_id => $row->id,
			     osi_actual_id => $row->osi_id,
			     vm_state => 'stopped',
			     x_state => 'disconnected',
			     user_state => 'disconnected' });
    $row->id
}

sub cmd_user_add {
    my $self = shift;
    my %params = @_;
    $params{department} //= undef;
    $params{telephone} //= undef;
    $params{email} //= undef;
    my $row = $self->_obj_add('user', 
	[qw/login password department telephone email/], %params);
    $row->id
}

sub cmd_osi_add {
    my ($self, %params) = @_;
    my @required_params = qw/name memory use_overlay user_storage_size disk_image/;

    # Default OSI parameters
    # FIXME Detect type of image and set use_overlay accordingly, iso=no overlay
    $params{memory} //= 256;
    $params{use_overlay} //= 1;
    $params{user_storage_size} //= undef;

    die "The required parameters are ".join(", ", @required_params)
	unless _set_equals([keys %params], \@required_params);

    use File::Basename qw/basename/;
    my $img = $params{disk_image};
    $params{disk_image} = basename($img);

    my $destination = cfg('ro_storage_path');
    unless (-f $destination.'/'.$params{disk_image}) {
	use File::Copy qw/copy/;
	copy($img, $destination) or die "Unable to copy $img to storage: $^E";
    }

    my $rs = $self->get_resultset('osi');
    my $row = $rs->create(\%params);

    $row->id;
}

sub _obj_del {
    my ($self, $obj) = @_;
    my $rs = $self->get_resultset($obj);
    $rs->delete_all;
}

sub cmd_host_del {
    shift->_obj_del('host', @_);
}

sub cmd_user_del {
    shift->_obj_del('user', @_);
    # FIXME Should we delete the overlay image and home disk files?
}

sub cmd_vm_del {
    shift->_obj_del('vm', @_);
    # FIXME Should we delete the overlay image and home disk file?
}

sub cmd_osi_del {
    my ($self, @args) = @_;
    $self->_obj_del('osi', @args);
    # FIXME Should we delete the actual image file?
}

sub _obj_propset {
    my ($self, $obj, @args) = @_;
    my $params = {@args};
    my $rs = $self->get_resultset($obj);
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

sub propset {
    my ($self, $object, @args) = @_;
    $self->_obj_propset($object, @args);
}

sub cmd_host_propset {
    shift->_obj_propset('host', @_);
}

sub cmd_user_propset {
    shift->_obj_propset('user', @_);
}

sub cmd_vm_propset {
    shift->_obj_propset('vm', @_);
}

sub _obj_propget {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};
    my @props = $rs->search_related('properties', $condition);
    return \@props;
}

sub propget {
    my $self = shift;
    $self->_obj_propget(@_);
}

sub cmd_host_propget {
    shift->_obj_propget('host', @_);
}

sub cmd_user_propget {
    shift->_obj_propget('user', @_);
}

sub cmd_vm_propget {
    shift->_obj_propget('vm', @_);
}

sub propdel {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};
    $rs->search_related('properties', $condition)->delete;
}

sub cmd_config_set {
    my ($self, %args) = @_;
    my $rs = $self->get_resultset('config');
    foreach my $key (keys %args) {
	$rs->update_or_create({
		key => $key,
		value => $args{$key}
	    });
    }
}

sub cmd_config_get {
    my ($self, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my $rs = $self->get_resultset('config');
    my @configs = $rs->search($condition);
    return \@configs;
}

sub cmd_vm_start_by_id {
    my ($self, $id) = @_;
    die "Missing parameter id" unless defined $id;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    my $vm = $self->get_resultset('vm')->find($id);
    die "VM $id doesn't exist" unless defined $vm;
    txn_do {
	if ($vm->vm_runtime->vm_state eq 'stopped') {
	    $vmas->assign_host_for_vm($vm->vm_runtime)
		or die "Unable to assign VM $id to a host";
	    $vmas->schedule_start_vm($vm->vm_runtime);
	} else {
	    die "Unable to start VM: VM is not stopped";
	}
    };
    $vmas->notify_hkd($vm->vm_runtime);
}

sub cmd_vm_start {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    my $counter = 0;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    while (my $vm = $rs->next) {
	eval {
	    txn_do {
		my $vm_runtime = $vm->vm_runtime;
		if ($vm_runtime->vm_state eq 'stopped') {
		    die unless $vmas->assign_host_for_vm($vm_runtime);
		    $vmas->schedule_start_vm($vm_runtime);
		    $counter++;
		}
	    };
	};
	# TODO Log error messages ($@) in some way
    }
    $counter
}

sub cmd_vm_stop_by_id {
    my ($self, $id) = @_;
    die "Missing parameter id" unless defined $id;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    my $vm;
    txn_do {
	$vm = $self->get_resultset('vm')->find($id);
	die "VM $id doesn't exist" unless defined $vm;
	
	if ($vm->vm_runtime->vm_state eq 'running') {
	    $vmas->schedule_stop_vm($vm->vm_runtime);
	} else {
	    die "Unable to stop VM: VM is not running";
	}
    };
    $vmas->notify_hkd($vm->vm_runtime);
}

sub cmd_vm_stop {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    my $counter = 0;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->vm_state eq 'running') {
	    next unless eval { $vmas->schedule_stop_vm($vm_runtime); };
	    $counter++;
	}
    }
    $counter
}

sub cmd_vm_disconnect_user_by_id {
    my ($self, $id) = @_;
    die "Missing parameter id" unless defined $id;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    my $vm;
    txn_do {
	$vm = $self->get_resultset('vm')->find($id);
	die "VM $id doesn't exist" unless defined $vm;
	
	if ($vm->vm_runtime->user_state eq 'connected') {
	    $vmas->disconnect_nx($vm->vm_runtime);
	} else {
	    die "Unable to disconnect user: user is not connected";
	}
    };
    $vmas->notify_hkd($vm->vm_runtime);
}

sub cmd_vm_disconnect_user {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new;
    my $counter = 0;
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->user_state eq 'connected') {
	    $vmas->disconnect_nx($vm_runtime);
	    $counter++;
	}
    }
    $counter
}

sub cmd_config_ssl {
    my ($self, %args) = @_;
    # FIXME: Is using File::Slurp the best way?
    use File::Slurp; 
    my $cert = eval { read_file($args{cert}) } 
	or die "$args{cert}: Unable to read cert file: $^E";
    my $key = eval { read_file($args{key}) }  
	or die "$args{key}: Unable to read key file: $^E";

    rs(SSL_Config)->update_or_create({
	    key => 'ssl_server_cert',
	    value => $cert,
	});

    rs(SSL_Config)->update_or_create({
	    key => 'ssl_server_key',
	    value => $key,
	});
    1
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

Adds a user. The required parameters are login and password. You can optionally
specify the user's department, telephone, and email.

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

Deletes all OSIs that match the current filter.

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

=item cmd_config_ssl(cert => mycert.pem, key => mykey.key)

Sets the SSL certificate to the one read from mycert.pem and the private key to
the one read from mykey.key. Returns 1 on success.

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
