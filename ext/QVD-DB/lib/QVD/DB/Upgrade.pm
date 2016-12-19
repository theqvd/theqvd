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
our @EXPORT = qw(qvd_db_upgrade qvd_upgrade_db_data qvd_version_upgrade_available);

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

### UPGRADE FUNCTIONS USING qvd-deploy-db.pl SCRIPT ### 

sub migrate_properties_from_36_to_40 {
    my $list_ref = shift;
    my @new_list = ();
    my @tuple_list = ();
    my @properties = ();

    my %schema_to_enum = (
        Host_Property => 'host',
        VM_Property   => 'vm',
        User_Property => 'user',
    );

    while(@$list_ref){
        my $schema = shift @$list_ref;
        my $data = shift @$list_ref;
        if (grep {$_ eq $schema} keys(%schema_to_enum)){
            my $enum = $schema_to_enum{$schema};
            for my $tuple (@{$data}) {
                push @properties,
                    {
                        key    => $tuple->{key},
                        value  => $tuple->{value},
                        enum   => $enum,
                        obj_id => $tuple->{"${enum}_id"}
                    };
            }
        } else {
            push @new_list, $schema, $data;
        }
    }

    my $index = 1;
    my %property_ids = map { $_ => $index++ } (keys { map { $_->{key} => 1 } @properties } );

    # Create property list
    push @new_list, 'Property_List';
    @tuple_list = ();
    while( my ($key, $id) = each(%property_ids) ) {
        push @tuple_list, { id => $id, key => $key, tenant_id => 1 };
    }
    push @new_list, [ @tuple_list ];

    # Assign property to element
    $index = 1;
    push @new_list, 'QVD_Object_Property_List';
    @tuple_list = ();
    for my $property (@properties) {
        push @tuple_list, {
                id          => $index,
                property_id => $property_ids{$property->{key}},
                qvd_object  => $property->{enum},
            };
        $property->{prop_id} = $index;
        $index++;
    }
    push @new_list, [ @tuple_list ];

    # Assign value to element properties
    $index = 1;
    for my $schema (keys(%schema_to_enum)) {
        my $enum = $schema_to_enum{$schema};
        push @new_list, $schema;
        @tuple_list = ();
        for my $tuple ( grep { $_->{enum} eq $enum } @properties ) {
            push @tuple_list,
                {
                    "${enum}_id" => $tuple->{obj_id},
                    value        => $tuple->{value},
                    property_id  => $tuple->{prop_id},
                };
        }
        push @new_list, [ @tuple_list ];
    }

    return \@new_list;
};

my $UPGRADE_SCHEMA = {
    'common' => {
        delete_schemas => [ qw(Version) ],
    },
    '3.6' => {
        delete_schemas => [ qw(Host_Cmd Host_State User_Cmd User_State VM_Cmd VM_State) ],
        add_column     => {
            User => {
                tenant_id => sub { return 1; },
            },
            Config => {
                tenant_id => sub { return -1; },
            },
            OSF => {
                tenant_id => sub { return 1; },
            }
        },
        additional_actions => [
            \&migrate_properties_from_36_to_40
        ],
    },
    '4.0' => {},
    'latest' => {}
};

sub qvd_version_upgrade_available {
    my $version = shift;
    return (grep {$_ eq $version} keys(%{$UPGRADE_SCHEMA})) ? 1 : 0;
}

sub qvd_upgrade_db_data {
    my $data_list_ref = shift;
    my $from = shift;

    my @data_list = @{$data_list_ref};
    my @data_updated = ();
    
    while(@data_list) {
        my $schema = shift @data_list;
        my $data = shift @data_list;

        # Do not add useless schemas
        next if (grep {$_ eq $schema}
            @{$UPGRADE_SCHEMA->{$from}->{delete_schemas}},@{$UPGRADE_SCHEMA->{common}->{delete_schemas}});

        # Add new columns
        if (my $new_columns = $UPGRADE_SCHEMA->{$from}->{add_column}->{$schema}){
            while ( my ($column, $value) = each(%$new_columns) ) {
                for my $tuple (@$data) {
                    $tuple->{$column} = $value->();
                }
            }
        }

        # Save tuples
        push @data_updated, $schema;
        push @data_updated, $data;
    }

    # Additional actions
    for my $action (@{$UPGRADE_SCHEMA->{$from}->{additional_actions}}) {
        @data_updated = @{ $action->(\@data_updated) };
    }

    return \@data_updated;
}

1;
