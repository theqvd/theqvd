#line 1
package Module::Install::External;

# Provides dependency declarations for external non-Perl things

use strict;
use Module::Install::Base ();

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '1.00';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}

sub requires_external_cc {
	my $self = shift;

	# We need a C compiler, use the can_cc method for this
	unless ( $self->can_cc ) {
		print "Unresolvable missing external dependency.\n";
		print "This package requires a C compiler.\n";
		print STDERR "NA: Unable to build distribution on this platform.\n";
		exit(0);
	}

	# Unlike some of the other modules, while we need to specify a
	# C compiler as a dep, it needs to be a build-time dependency.

	1;
}

sub requires_external_bin {
	my ($self, $bin, $version) = @_;
	if ( $version ) {
		die "requires_external_bin does not support versions yet";
	}

	# Load the package containing can_run early,
	# to avoid breaking the message below.
	$self->load('can_run');

	# Locate the bin
	print "Locating required external dependency bin:$bin...";
	my $found_bin = $self->can_run( $bin );
	if ( $found_bin ) {
		print " found at $found_bin.\n";
	} else {
		print " missing.\n";
		print "Unresolvable missing external dependency.\n";
		print "Please install '$bin' seperately and try again.\n";
		print STDERR "NA: Unable to build distribution on this platform.\n";
		exit(0);
	}

	# Once we have some way to specify external deps, do it here.
	# In the mean time, continue as normal.

	1;
}

1;

__END__

#line 138
