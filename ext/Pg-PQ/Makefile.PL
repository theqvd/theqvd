
use ExtUtils::MakeMaker;

`pg_config --version` =~ /PostgreSQL\s+(\d+)\.(\d+\.\d+)/i;
unless (defined $1 and $1 >= 8) {
    die "libpq 8.x.x or later required ($1.$2 found)\n";
}

my $incdir = `pg_config --includedir`;
my $libdir = `pg_config --libdir`;
chomp($incdir, $libdir);

WriteMakefile( NAME          => 'Pg::PQ',
               VERSION_FROM  => 'lib/Pg/PQ.pm',
               PREREQ_PM     => {},
               ABSTRACT_FROM => 'lib/Pg/PQ.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>',
               LIBS          => ["-lpq -L$libdir"],
               DEFINE        => '', # e.g., '-DHAVE_SOMETHING'
               INC           => "-I. -I$incdir",
               # OBJECT        => '$(O_FILES)', # link all the C files too
             );
