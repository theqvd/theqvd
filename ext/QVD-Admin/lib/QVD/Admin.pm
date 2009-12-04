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
    elsif ($self->{filter}) {
	$self->{db}->resultset($db_object)->search($self->{filter});
    } else {
	$self->{db}->resultset($db_object);
    }
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
    $self->{db}->resultset('Host_Runtime')
			    ->create({host_id => $row->id});
    $row->id
}

sub cmd_vm_add {
    my ($self,@args) = @_;
    my $params = {@args};
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
    my $row = $self->_obj_add('vm', [qw/name user_id osi_id ip storage/], 
				$params);
    $self->{db}->resultset('VM_Runtime')->create({
	    vm_id => $row->id,
	    osi_actual_id => $row->osi_id,
	    vm_state => 'stopped',
	    x_state => 'disconnected',
	    user_state => 'disconnected',
	});

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
    my ($self, @args) = @_;
    my $params = {@args};
    my @required_params = qw/name memory use_overlay user_storage_size disk_image/;

    # Default OSI parameters
    # FIXME Detect type of image and set use_overlay accordingly, iso=no overlay
    $params->{memory} //= 256;
    $params->{use_overlay} //= 1;
    $params->{user_storage_size} //= undef;

    die "The required parameters are ".join(", ", @required_params)
	unless _set_equals([keys %$params], \@required_params);

    use File::Basename qw/basename/;
    my $img = $params->{disk_image};
    $params->{disk_image} = basename($img);

    # Copy image to ro-directory
    # FIXME Overwriting existing image should be an error
    my $destination = QVD::Config->get('ro_storage_path');
    use File::Copy qw/copy/;
    copy($img, $destination) or die "Unable to copy $img to storage: $^E";

    my $rs = $self->get_resultset('osi');
    my $row = $rs->create($params);

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
    $self->_obj_del('OSI', @args);
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
    my ($self, $obj, @args) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my @props = $rs->search_related('properties', $condition);
    return \@props;
}

sub propget {
    my $self = shift;
    $self->_obj_propget(@_);
}

sub cmd_host_propget {
    shift->_obj_propget(sub { $_->host->name }, 'host', @_);
}

sub cmd_user_propget {
    shift->_obj_propget(sub { $_->user->login }, 'user', @_);
}

sub cmd_vm_propget {
    shift->_obj_propget(sub { $_->vm->name }, 'vm', @_);
}

sub propdel {
    my ($self, $obj, @args) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
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

sub cmd_vm_start {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    my $counter = 0;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->vm_state eq 'stopped') {
	    next unless $vmas->assign_host_for_vm($vm_runtime);
	    next unless $vmas->schedule_start_vm($vm_runtime);
	    $counter++;
	}
    }
    $counter
}

sub cmd_vm_stop {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    my $counter = 0;
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	if ($vm_runtime->vm_state eq 'running') {
	    $vmas->schedule_stop_vm($vm_runtime);
	    $counter++;
	}
    }
    $counter
}

sub cmd_vm_disconnect_user {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    use QVD::VMAS;
    my $vmas = QVD::VMAS->new($self->{db});
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
    exec @cmd;
}

sub cmd_vm_vnc {
    my ($self, @args) = @_;
    my $vm_runtime = $self->_get_single_vm_runtime;
    my $vnc_port = $vm_runtime->vm_vnc_port;
    die 'VNC access is disabled' unless defined $vnc_port;
    my @cmd = (vncviewer => ($vm_runtime->vm_address.'::'.$vnc_port, @args));
    exec @cmd;
}

1;

__END__

=head1 NAME

QVD::Admin - QVD Administration API

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::Admin;
    my $admin = QVD::Admin->new();
    my $id = $admin->cmd_osi_add("name=Ubuntu 9.10 (x86)", "memory=512",
			"use_overlay=1", "disk_image=/var/tmp/U910_x86.img");
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

Removed all conditions from the filter.

=item get_resultset($object)

Return the DBIx::Class result set for the given object type. The valid object
types are listed in the "objects" member hash. They are host, vm, uesr, config,
and osi.

=item cmd_host_add(@values)

Add a host. The parameters are name and address. 

=item cmd_vm_add(@values)

Add a virtual machine. The obligatory parameters are name, user, osi, and ip.
OSI and user can be specified by name (login) or by id. The optional parameter
is storage.

=back

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
