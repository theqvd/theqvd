package QVD::Client::PulseAudio;
use strict;
use warnings;



sub new {
	my ($class, %params) = @_;
	my $self = {};

	if ( $^O =~ /linux/ ) {
		require QVD::Client::PulseAudio::Linux;
		return  QVD::Client::PulseAudio::Linux->new(%params);
	}

	die "No implementation for OS '$^O'";
}

sub start {
	my ($class, %params) = @_;

	my $obj = $class->new(%params);
	$obj->start();
	return $obj;
}

1;

