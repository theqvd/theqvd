package QVD::Client::USB;
use strict;
use QVD::Log;
use Data::Dumper;
	
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

sub refresh {
	my ($self) = @_;
	my $devices = $self->int_get_devices;


	$self->{device_list} = $devices;
	$self->{shared_list} = [];
	$self->{device_hash} = {};
	$self->{needs_refresh} = 0;

	
	foreach my $dev (@$devices) {
		
		my $id = $dev->{vid} . ":" . $dev->{pid};
		$self->{device_hash}->{$id} = $dev;

		if ( $dev->{shared} ) {
			push @{ $self->{shared_list} }, $dev;
		}
	}
}

sub int_get_devices {
}

sub list_devices {
	my ($self) = @_;
	
	$self->refresh if ( $self->{needs_refresh} );
	return $self->{device_list};
}

sub list_shared_devices {
	my ($self) = @_;
	
	$self->refresh if ( $self->{needs_refresh} );
	return $self->{shared_list};
}

sub device_exists {
	my ($self, $vid, $pid) = @_;
	my $dev = $self->get_device($vid, $pid);
	
	return defined $dev;
}

sub get_device {
	my ($self, $vid, $pid) = @_;
	
	if ( $vid =~ /:/ ) {
		($vid, $pid) = split(/:/, $vid);
	}
	
	$vid = lc($vid);
	$pid = lc($pid);
	
	$self->refresh if ( $self->{needs_refresh} );
	
	if ( exists $self->{device_hash}->{"$vid:$pid"} ) {
		return $self->{device_hash}->{"$vid:$pid"};
	} else {
		return undef;
	}
}

sub share {
}

sub unshare {
}

 
1;
