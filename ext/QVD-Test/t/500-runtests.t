#!/usr/lib/qvd/bin/perl -T

use strict;
use warnings;
use lib 'lib';

BEGIN {
	delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
	$ENV{PATH} = "/usr/lib/qvd/bin:/bin:/usr/bin:/sbin:/usr/sbin";
}
use Test::Class::Load 'lib';
#use QVD::Test::SingleServer;
#use QVD::Test::AdminCLI;


Test::Class->runtests;
