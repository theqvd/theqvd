#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::Node;
use QVD::Config;
use QVD::Log;

$App::Daemon::pidfile = core_cfg('noded.pid_file');
$App::Daemon::as_user = core_cfg('noded.as_user');

daemonize;
my $ok = QVD::Node->new->run;
exit ($ok ? 0 : 1);

__END__
