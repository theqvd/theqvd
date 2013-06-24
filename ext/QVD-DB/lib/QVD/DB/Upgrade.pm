package QVD::DB::Upgrade;

use 5.010;
use strict;
use warnings;
use Carp;

use QVD::Config::Core;
use File::Spec;
use Sort::Versions;
use DBI;

my $db_name   = core_cfg('database.name');
my $db_user   = core_cfg('database.user');
my $db_host   = core_cfg('database.host');
my $db_passwd = core_cfg('database.password');

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(qvd_db_upgrade);

sub _dbi_connect {
    DBI->connect("dbi:Pg:dbname=$db_name;host=$db_host",
                 $db_user, $db_passwd,
                 { RaiseError => 1,
                   AutoCommit => 0 });
}

sub _sql_files {
    my $path = $INC{'QVD/DB/Upgrade.pm'};
    $path =~ s|\.pm$|/sql|;

    opendir my $dh, $path or croak "Unable to open directory '$path'\n";
    my @files = grep /\.sql$/, readdir $dh;
    closedir $dh or croak "Unable to read directory '$path'\n";
    map "$path/$_", @files;
}

sub qvd_db_upgrade {
    my ($target_version, $downgrade) = @_;

    my %sql_file;
    my $undo_re = ($downgrade ? 'undo-' : '');
    for (_sql_files()) {
        $sql_file{$1} = $_ if m|/${undo_re}upgrade-to-([^/]*).sql$|;
    }


    my $dbh = _dbi_connect;

    my $current_version;
    my ($table) = $dbh->selectrow_array("select tablename from pg_tables where tablename='versions'");
    if (defined $table) {
        ($current_version) = $dbh->selectrow_array("select version from versions where component='schema'");
    }
    else {
        $current_version = '3.2.0';
    }

    my $dir;
    my @versions = sort { versioncmp($a, $b) } keys %sql_file;
    $target_version //= $versions[-1];

    if ($downgrade) {
        $dir = 'down';
        @versions = reverse grep { ( versioncmp($_, $current_version) <= 0 and
                                     versioncmp($_, $target_version) > 0 ) } @versions;
    }
    else {
        $dir = 'up';
        @versions = grep { ( versioncmp($_, $current_version) > 0 and
                             versioncmp($_, $target_version) <= 0 ) } @versions;
    }

    if (@versions) {
        my @sql;
        my @sql_files = map $sql_file{$_}, @versions;
        for (@sql_files) {
            open my $fh, '<', $_ or die "unable to read file '$_'\n";
            push @sql, do {undef $/; <$fh> };
            close $fh or die "unable to read file '$_'\n";
        }

        warn join("\n",
                  "The following database scripts are going to be applied:",
                  (map "  $_", @sql_files),
                  "", "");

        my $sql = join("\n\n;\n", @sql);
        $dbh->do($sql);
        $dbh->commit or croak "unable to commit transaction";
    }
    else {
        warn "No database ${dir}grade scripts need to be applied\n";
    }

    warn "Database ${dir}graded sucessfully from version $current_version to version $target_version\n";
}

1;
