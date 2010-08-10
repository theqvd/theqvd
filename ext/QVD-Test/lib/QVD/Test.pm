package QVD::Test;
use parent qw(Test::Class);

use warnings;
use strict;

our $VERSION = '0.01';

INIT {
    Test::Class->runtests
}

1;

__END__

=head1 NAME

QVD::Test - QVD Functional Test Automation

=head1 SYNOPSIS

Automated functional tests of QVD components, categorized by test environment.
You can use Test::Class to run the tests.

   Test::Class->runtests

=head1 DESCRIPTION

Classes within the QVD::Test namespace implement the functional tests of QVD
components. They are subclasses of Test::Class, one class per test environment.
Additional test cases can be added as methods of these classes, see perldoc
Test::Class for further details. Testing in specialized subenvironments can be
created through subclasses.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

