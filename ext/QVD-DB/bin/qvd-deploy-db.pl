#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use QVD::DB::Simple;

### FUNCTIONS ###

my %functions  = (
	FILE_CONTENT => \&get_file_content,
);

sub initData {

	# Check flags
	my %args = %{$_[0]};
	my $filepath = $args{filepath};
	my $checkData = (defined $args{check} and $args{check} > 0) ? 1 : 0;
	my $verbose = (defined $args{verbose} and $args{verbose} > 0) ? 1 : 0;

	print "- Checking initialisation data...\n" if $checkData;
	print "- Populating database...\n" if not $checkData;

	# Variables
	my $outcome = 1;
	open FILE, "<", $filepath or die "Cannot open file $filepath\n";
	my @lines = <FILE>;
	chomp(@lines);
	my $currTableName = '';
	my @currAttribNames = ();
	my @currAttribValues = ();
	my %currAttribHash = ();

	# Check each line of data
	for my $line (@lines) {
		# Remove empty lines
		if (not $line =~ /^\s*$/) {

			# Table reference
			if ($line =~ /^#+\s*(\w+)\s*#+$/) {
				$currTableName = $1;
				@currAttribNames = ();
				%currAttribHash = ();
			} else {
				# Attributes list
				if (@currAttribNames == 0) {
					@currAttribNames = split('\t+', $line);
					print "\n### $currTableName ###\n". join(', ', @currAttribNames) . "\n" if $verbose;
				} else {
					my @auxAttribValues = split('\t+', $line);
					@currAttribValues = map {applyFunction($_)} @auxAttribValues;
					# Check number of attributes of each row
					if (@currAttribValues != @currAttribNames) {
						print "[ERROR] Number of attributes is different to number of values in line:\n$line\n";
						$outcome = 0;
						last;
					} else { # Add values to the db
						print(join(" | ", @currAttribValues) . "\n") if $verbose;
						@currAttribHash{@currAttribNames} = @currAttribValues;
						rs($currTableName)->create(\%currAttribHash) unless $checkData;
					}
				}
			}
		}

	}

	print "[DONE] Status $outcome\n";
	return $outcome;
}

sub updateSeqs() {
	my $dbh = db->storage->dbh;
	for my $source (db->sources()){
		for my $col_name (db->source($source)->columns){
			my $col_info = db->source($source)->column_info($col_name);
			my $table_name = db->source($source)->name;
			if(($col_info->{is_auto_increment}) and ((db->source($source)->{is_virtual} // 0) == 0)){
				$dbh->do("SELECT setval('${table_name}_${col_name}_seq', 10000, false)");
			}
		}
	}
}

sub applyFunction {
	my $value = shift;

	if($value =~ /^\&(\w+)\((.*)\)$/){
		my $function = $1;
		my @args = split(/\s*,\s*/, $2);
		if (exists $functions{$function}) {
			$value = $functions{$function}->(@args);
		}
	}

	return $value;
}

sub get_file_content {
	my $filepath = shift;
	my $content = "";

	if (open FILE, $filepath){
		$content = join("",<FILE>);
		close(FILE);
	} else {
		print "[ERROR] Could not open file $filepath\n";
	}

	return $content;
}

### Check IF DB IS DEPLOYED ###

my $force;
my $datafile = "qvd-init-data.dat";
GetOptions("force|f" => \$force, "file=s" => \$datafile) or exit (1);
unless ($force) {
	eval { db->storage->dbh->do("select count(*) from configs;"); };
	$@ or die "Database already contains QVD tables, use '--force' to redeploy the database\n";
}

### DATA DEFINITION ###

# Check if data file exists
die "$datafile does not exist. Use -file option to select the correct file.\n" unless(-e $datafile);

# Enumarate types
my %enumerates = (
	administrator_and_tenant_views_setups_device_type_enum => [qw(mobile desktop)],
	administrator_and_tenant_views_setups_qvd_object_enum => [qw(user vm log host osf di role administrator tenant)],
	administrator_and_tenant_views_setups_view_type_enum => [qw(filter list_column)],
	log_qvd_object_enum =>
		[qw(user vm log host osf di role administrator tenant acl config tenant_view admin_view)],
	log_type_of_action_enum => [qw(create create_or_update delete see update exec login)],
	wat_setups_by_administrator_and_tenant_language_enum => [qw(es en auto default)],
);

# Initial single values
my %initial_values = (
	VM_State   => [qw(stopped starting running stopping zombie debugging )],
	VM_Cmd     => [qw(start stop busy)],
	User_State => [qw(disconnected connecting connected)],
	User_Cmd   => [qw(abort)],
	Host_State => [qw(stopped starting running stopping lost)],
	Host_Cmd   => [qw(stop)]
);

### DATABASE DEPLOYMENT ###

# Generate database
db->deploy({add_drop_table => 1, add_enums => \%enumerates, add_init_vars => \%initial_values});

# Populate database if DATA is valid
initData({filepath => $datafile}) if initData({filepath => $datafile, check => 1});

updateSeqs();

1;
