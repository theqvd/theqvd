package QVD::Client::USB;
use strict;
use QVD::Log;
use Data::Dumper;

=head1 NAME

QVD::Client::USB

=head1 SYNOPSIS

USB over IP sharing base module

=head1 DESCRIPTION

This module defines the interface for USB sharing.

Currently two implementations are supported:

=over 4

=item * QVD::Client::USB::USBIP, integrated into recent Linux kernels

=item * QVD::Client::USB::IncentivesPro, closed source

=back

=head1 FUNCTIONS

=cut

sub new {
	my $self = {};
	my $class = shift;

	$self->{device_list} = [];
	$self->{device_hash} = {};
	$self->{shared_list} = [];
	$self->{needs_refresh} = 1;
	
	bless $self, $class;

	#$self->refresh;
	return $self;
}

=head2 instantiate($subclass)

Dynamically loads and instantiates an USB over IP implementation.

Currently two are available: USBIP and IncentivesPro.

=cut

sub instantiate {
	my ($subclass) = @_;
	
	my $classname = "QVD::Client::USB::$subclass";
	
	my $class = eval "use $classname; $classname->new();";
	
	if ( defined $class ) {
		if ( !$class->isa( "QVD::Client::USB" ) ) {
			die "Loaded $classname, but it wasn't a QVD::Client::USB";
		}
	} else {
		die "Failed to load $classname: $@";
	}
	
	return $class;
}

=head2 refresh()

Refreshes the current list of USB devices.

=cut

sub refresh {
	my ($self) = @_;
	my $devices = $self->int_get_devices;


	$self->{device_list} = $devices;
	$self->{shared_list} = [];
	$self->{device_hash} = {};
	$self->{needs_refresh} = 0;

	
	foreach my $dev (@$devices) {
		my $id = $self->get_device_id( $dev->{vid}, $dev->{pid}, $dev->{serial} );
		
		$dev->{key} = $id;
		#my $id = $dev->{vid} . ":" . $dev->{pid};
		#$id .= "\@" . $dev->{serial} if ( defined $dev->{serial} );
		
		$self->{device_hash}->{$id} = $dev;

		if ( $dev->{shared} ) {
			push @{ $self->{shared_list} }, $dev;
		}
	}
}

sub int_get_devices {
}

=head2

Returns the list of current devices, as an arrayref of hashref

=cut


sub list_devices {
	my ($self) = @_;
	
	$self->refresh if ( $self->{needs_refresh} );
	return $self->{device_list};
}


=head2

Returns the list of currently shared devices

=cut

sub list_shared_devices {
	my ($self) = @_;
	
	$self->refresh if ( $self->{needs_refresh} );
	return $self->{shared_list};
}

=head2

Checks whether an USB device exists

=cut

sub device_exists {
	my ($self, $vid, $pid) = @_;
	my $dev = $self->get_device($vid, $pid);
	
	return defined $dev;
}

=head2 get_device_id($vid, $pid, $serial)

Obtains an unique identifier for a device. 

Returns a string in the form of $vid:$pid@serial

This function accepts all the parts together or separately. Eg, both of these
ways of calling it are acceptable:

    $usb->get_device_id("0123", "ABCD", "1234567");
    $usb->get_device_id("0123:ABCD@1234567");


The same goes for any function that takes device identifiers as an argument.

=cut

sub get_device_id {
	my ($self, $vid, $pid, $serial) = @_;
	
	if ( $vid =~ /:/ ) {
		($vid, $pid) = split(/:/, $vid);
		($pid, $serial) = split(/@/, $pid) if ($pid =~ /@/);
	}
	
	$vid = lc($vid);
	$pid = lc($pid);
	
	foreach my $str ($vid, $pid, $serial) {
		$str =~ s/^\s+//;
		$str =~ s/\s+$//;
	}
	
	$self->refresh if ( $self->{needs_refresh} );
	my $key = "$vid:$pid";
	$key .= "\@${serial}" if (defined $serial);
	return $key;
}

=head2 get_device($vid, $pid, $serial)

Returns an arrayref with device information, or undef if not found.

=cut

sub get_device {
	my ($self, $vid, $pid, $serial) = @_;
	
	my $key = $self->get_device_id( $vid, $pid, $serial );
	
	if ( exists $self->{device_hash}->{$key} ) {
		return $self->{device_hash}->{$key};
	} else {
		return undef;
	}
}

=head2 share($vid, $pid, $serial)

Shares the indicated device

=cut

sub share {
}

=head2 unshare($vid, $pid, $serial)

Unshares the indicated device

=cut

sub unshare {
}


=head2 share_list_only([$vid, $pid, $serial], [$vid, $pid, $serial], ...)

Shares the devices specified in the list, and unshares any unlisted ones.

=cut


sub share_list_only {
	my ($self, @list) = @_;
	my %shared_ids;
	
	my $ret = 1;
	my @failed;
	
	# Ensure the data is up to date
	$self->refresh;
		
		
	foreach my $elem (@list) {
		my $key = $self->get_device_id( @$elem );
		DEBUG "Going to share device $key";
		
		my $dev = $self->get_device( $key );
		if ( $dev ) {
			$shared_ids{$key} = 1;
			if ( !$dev->{shared} ) {
				DEBUG "Sharing device $key";
				$self->share(@$elem);
			} else {
				DEBUG "Device $key is already shared, skipping";
			}
		} else {
			WARN "Was asked to share device $key, but the device is not present";
			$ret = 1;
			push @failed, $key;
		}
	}
	
	foreach my $dev ( @{$self->list_devices} ) {
		my $key = $dev->{key};
		if ( !exists $shared_ids{$key} && $dev->{shared} ) {
			DEBUG "Unsharing currently shared device $key, not in current list";
			$self->unshare( $key );
		}
	}
	
	return ($ret, @failed);
}

=head2 can_autoshare()

Returns true if the module can automatically share USB devices.
Returns false if the module requires that each device be shared specifically.

This is important for the VMA side. An implementation with autoshare can let
the VM connect any system device it asks when in autoshare mode. An implementation
without must list the devices to share, and those unlisted will be unavailable to
the VM.

=cut

sub can_autoshare {
	return 0;
}

=head2 set_autoshare(bool)

Sets autoshare mode.

=cut

sub set_autoshare {
	die "Autosharing not supported by this module";
}
 
1;


=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut