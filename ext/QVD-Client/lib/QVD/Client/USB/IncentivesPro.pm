#!/usr/bin/perl -w
package QVD::Client::USB::IncentivesPro;
use base 'QVD::Client::USB';
use strict;
use QVD::Log;

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new();
	bless $self, $class;
	return $self;
}

sub _get_devices {
	my ($self) = @_;
	my @dev_list;

	my $usbsrv = $self->{usbsrv};
	my @usblist = `$usbsrv -list`;
	chomp @usblist;

	DEBUG "Getting shared USB devices";

	foreach my $line ( @usblist ) {
		my ($vid, $pid, $shared);
		
		if ( $line =~ /^\s*\d+:/ ) {
			undef $pid;
			undef $vid;
		}
		
		
		if ( $line =~ /Vid: ([a-f0-9]{4})\s+Pid: ([a-f0-9]{4})/i  ) {
			($vid, $pid) = ($1, $2);
		}
		
		if ( $line =~ /^\s+Status:.*?shared/ && $pid && $vid ) {
			$shared = 1;
		}
		
		push @dev_list, { vid => $vid, pid => $pid, shared => $shared };
	}

	return \@dev_list;
}

sub share {
	my ($self, $vid, $pid) = @_;
	return system($self->{usbsrv}, "-share", "-vid", $vid, "-pid", $pid) == 0	
}

sub unshare {
	my ($self, $vid, $pid) = @_;
	return system($self->{usbsrv}, "-unshare", "-vid", $vid, "-pid", $pid) == 0
}

sub can_autoshare {
	return 1;
}

sub set_autoshare {
	my ($self, $value) = @_;
	
	system($self->{usbsrv}, '-autoshare', $value ? 'on' : 'off');
}

1;