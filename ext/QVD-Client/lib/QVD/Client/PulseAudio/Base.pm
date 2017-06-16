package QVD::Client::PulseAudio::Base;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub is_running {
	return 0;
}

sub version {
	return undef;
}

sub is_opus_supported {
	return 0;
}

1;
