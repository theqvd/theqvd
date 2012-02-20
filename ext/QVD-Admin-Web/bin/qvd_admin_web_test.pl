#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QVD::Admin::Web', 'Test');

1;

=head1 NAME

qvd_admin_web_test.pl - Catalyst Test

=head1 SYNOPSIS

qvd_admin_web_test.pl [options] uri

 Options:
   --help    display this help and exits

 Examples:
   qvd_admin_web_test.pl http://localhost/some_action
   qvd_admin_web_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the command line.

=head1 AUTHOR

QVD,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
