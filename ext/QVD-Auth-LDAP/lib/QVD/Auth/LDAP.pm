package QVD::Auth::LDAP;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::Config;
use Net::LDAP;

sub login {
    my ($self, $user, $passwd) = @_;
    my $ldap = Net::LDAP->new (cfg('l7r.auth.ldap.host')) or return 0;
    my $mesg = $ldap->bind; 
    $mesg = $ldap->search(base   => cfg('l7r.auth.ldap.base'),
                          filter => "(uid=$user)" );
    if ($mesg->code != 0) {
	WARN $mesg->error;
	return 0;
    }

    my $dn;
    foreach my $entry ($mesg->entries) { $dn = $entry->dn; }
    
    $mesg = $ldap->bind( $dn, password => $passwd);
    
    if ($mesg->code != 0) {
	warn $mesg->error;
	return 0;
    }
    
    1
}

=head1 NAME

QVD::Auth::LDAP - LDAP authentication for QVD

=head1 SYNOPSIS

    if (QVD::Auth::LDAP::login($user, $pass)) {
	# successful authentication
    }

=head1 DESCRIPTION

This module authenticates users against an external LDAP server.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

