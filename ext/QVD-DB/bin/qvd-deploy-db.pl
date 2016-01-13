#!/usr/bin/perl

use strict;
use warnings;
use TryCatch;
use Getopt::Long;
use QVD::DB::Simple;

### FUNCTIONS ###

my %functions  = (
	FILE_CONTENT => \&get_file_content,
	CURRENT_TIME => \&get_current_time,
);

# Error codes
my %error_hash = (
	ERROR_UNDEFINED => [-1, "Undefined error code"],
	NO_ERROR => [0, "OK"],
	ERROR_MISSING_FILE => [1, "Missing file"],
	ERROR_DB_ALREADY_DEPLOYED => [2, "DB already deployed"],
	ERROR_DB_DEPLOY_FAILED => [3, "DB deployment failed"],
	ERROR_DB_POPULATE_FAILED => [4, "Populate database failed"],
);

sub error_description {
	my $error = shift;
	return $error_hash{$error}[1];
}

sub error_code{
	my $error = shift;
	return $error_hash{$error}[0];
}

sub display_error {
	my ($error, $message) = @_;
	my $code = error_code($error);
	if(!defined $code) { $error = "ERROR_UNDEFINED"; }
	my $description = error_description($error);
	print "[ERROR] Code $code: $description. Message:\n $message\n";
}

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

# Throws an exception if something fails
sub initData {

	# Check flags
	my %args = %{$_[0]};
	my $filepath = $args{filepath};
	my $checkData = (defined $args{check} and $args{check} > 0) ? 1 : 0;
	my $verbose = (defined $args{verbose} and $args{verbose} > 0) ? 1 : 0;

	print "- Checking initialisation data...\n" if $checkData;
	print "- Populating database...\n" if not $checkData;

	# Variables
	open FILE, "<", $filepath or die "Cannot open file $filepath";
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
						die "Number of attributes is different to number of values in line:\n$line";
					} else { # Add values to the db
						print(join(" | ", @currAttribValues) . "\n") if $verbose;
						@currAttribHash{@currAttribNames} = @currAttribValues;
						while ( my ( $key, $val ) = each %currAttribHash ) {
							delete $currAttribHash{$key} if $val eq '\N';
						}
						rs($currTableName)->create(\%currAttribHash) unless $checkData;
					}
				}
			}
		}

	}

	return 1;
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

	open FILE, $filepath or die "Could not open file $filepath";
		$content = join("",<FILE>);
		close(FILE);

	return $content;
}

sub get_current_time {
	my ($second, $minute, $hour, $day, $month, $year) = localtime();
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d+00", $year+1900, $month+1, $day, $hour, $minute, $second);
}

### MAIN ###

my $error = "NO_ERROR";
my $force;
my $verbose = 0;
my $datafile = "qvd-init-data.dat";
GetOptions("force|f" => \$force, "file=s" => \$datafile, "verbose|v" => \$verbose) or exit (1);

try {

	### Check IF DB IS DEPLOYED ###
	unless ($force) {
		eval {
			db->storage->dbh->do("select count(*) from configs;");
		};
		if (defined $@) {
			$error = "ERROR_DB_ALREADY_DEPLOYED";
			die "Database already contains QVD tables, use '--force' to redeploy the database";
		}
	}

	### DATA DEFINITION ###

	# Check if data file exists
	unless(-e $datafile){
		$error = "ERROR_MISSING_FILE";
		die "$datafile does not exist. Use -file option to select the correct file";
	}

	### DATABASE DEPLOYMENT ###

	# Generate database
	try{
		db->deploy({add_drop_table => 1, add_enums => \%enumerates, add_init_vars => \%initial_values});
	}catch ($exception) {
		$error = "ERROR_DB_DEPLOY_FAILED"; die "$exception";
	}

	# Populate database if DATA is valid
	try{
		if (initData({ filepath => $datafile, check => 1, verbose => $verbose })) {
			initData({ filepath => $datafile });
			updateSeqs();
		} else {
			$error = "ERROR_DB_POPULATE_FAILED"; die "Minor error populating database.";
		}
	} catch ($exception) {
		$error = "ERROR_DB_POPULATE_FAILED"; die "$exception";
	}
} catch ($exception) {
	display_error($error, $exception);
}

exit(error_code($error));
