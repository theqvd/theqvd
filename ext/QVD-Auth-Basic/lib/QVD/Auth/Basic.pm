package QVD::Auth::Basic;

use warnings;
use strict;

our $VERSION = '0.01';

use QVD::DB::Simple;

sub login {
    my $self = shift;
    my $user = shift;
    my $passwd = shift;
    
    my $rs = rs(User)->search({login => $user,
			      password => $passwd});

    print $rs;

    $rs->count; # Must be 1 if login is OK
}

1;

__END__

=head1 NAME

QVD::Auth::Basic - Basic authentication for QVD

=head1 SYNOPSIS

    if (QVD::Auth::Basic::login($user, $pass)) {
	# successful authentication
    }

=head1 DESCRIPTION

This module authenticates users against the internal QVD database.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
