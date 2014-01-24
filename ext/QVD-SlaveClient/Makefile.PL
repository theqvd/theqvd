use 5.10;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'QVD-SlaveClient';
all_from 'lib/QVD/SlaveClient.pm';
author   q{Vadim Troshchinskiy <vadim@qindel.com>};
license  'gpl3';

perl_version 5.10;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#QVD-SlaveClient',
   license    => 'http://www.gnu.org/licenses/gpl-3.0.html',
   #repository => 'git://github.com/Vadim Troshchinskiy/QVD-SlaveClient.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-SlaveClient',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
