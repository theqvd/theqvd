package QVD::Client::PulseAudio;
use strict;
use warnings;



sub new {
	my ($class, %params) = @_;
	my $self = {};

	if ( $^O =~ /linux/ ) {
		require QVD::Client::PulseAudio::Linux;
		return  QVD::Client::PulseAudio::Linux->new(%params);
    } elsif ( $^O =~ /darwin/ ) {
        require QVD::Client::PulseAudio::Darwin;
        return  QVD::Client::PulseAudio::Darwin->new(%params);
	}

	die "No implementation for OS '$^O'";
}

sub is_qvd_pulseaudio_installed {
	return 0;
}

sub start {
	my ($class, %params) = @_;

	my $obj = $class->new(%params);
	$obj->start();
	return $obj;
}

1;

