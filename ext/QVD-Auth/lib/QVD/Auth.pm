package QVD::Auth;

use warnings;
use strict;
use Carp;
use QVD::Config;

use feature 'switch';

our $VERSION = '0.01';

sub login {
    my $mode = cfg('l7r.auth.mode');
    given ($mode) {
	when('basic') {
	    require QVD::Auth::Basic;
	    QVD::Auth::Basic::login(@_);
	}
	when('ldap') {
	    require QVD::Auth::LDAP;
	    QVD::Auth::LDAP::login(@_);
	}
	default {
	    croak "bad authentication mode $_ (l7r.auth.mode)";
	}
    }
}

1;

__END__

=head1 NAME

QVD::Auth - Pluggable authentication for QVD

=head1 SYNOPSIS

    if (QVD::Auth->login($name, $password)) {
	# authentication was succesful
    }

=head1 DESCRIPTION

This module implements pluggable authentication for QVD. The authentication
method is controlled by the configuration setting C<auth_mode>. At the moment
the only supported methods are "basic" and "ldap".

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
