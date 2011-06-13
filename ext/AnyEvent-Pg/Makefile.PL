use 5.010001;

use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'AnyEvent::Pg',
               VERSION_FROM  => 'lib/AnyEvent/Pg.pm',
               PREREQ_PM     => { 'Pg::PQ'   => '0.04',
                                  'AnyEvent' => '5.34' },
               ABSTRACT_FROM => 'lib/AnyEvent/Pg.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>'
             );
