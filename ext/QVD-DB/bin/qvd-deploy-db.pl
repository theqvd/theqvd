#!/usr/lib/qvd/bin/perl

use strict;
use warnings;
use Try::Tiny;
use Getopt::Long;
use File::Basename;
use QVD::DB::Simple;
use QVD::DB::Upgrade qw(qvd_upgrade_db_data qvd_version_upgrade_available);
use QVD::DB::Common qw(ENUMERATES INITIAL_VALUES);
use Text::CSV;

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
	ERROR_DATA_FILE_INVALID => [5, "Data file invalid"],
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

# Throws an exception if something fails
sub get_data_from_file {
	# Check flags
	my %args = %{$_[0]};
	my $filepath = $args{filepath};
	my $verbose = (defined $args{verbose} and $args{verbose} > 0) ? 1 : 0;

	my $csv = Text::CSV->new ( { sep_char => "\t", quote_char => "`" } ) 
                or die "Cannot use CSV: ".Text::CSV->error_diag ();

	print "- Checking $filepath ...\n";
	open my $fh, "<:encoding(UTF8)", $filepath or die "Error opening $filepath: $!";

	my $data = [];
	my $currTableName = '';
	my @currAttribNames = ();
	my @currAttribValues = ();

	while (my $row = $csv->getline($fh)) {
	   # Remove empty lines
           $csv->combine(@$row);
	   if ($csv->string() eq '') {
	       next;
           }

	   if (@$row[0] =~ /^#+\s*(\w+)\s*#+$/) {
 		# Table name
		$currTableName = $1;
		push (@{$data}, $currTableName);
		push (@{$data}, []);
		@currAttribNames = ();
	   } else {
		# Attributes list
		if (@currAttribNames == 0) {
			@currAttribNames = @$row;
			print "\n### $currTableName ###\n". join(', ', @currAttribNames) . "\n" if $verbose;
		} else {
			@currAttribValues = map {apply_function( $_ )} @$row;
			for (@currAttribValues) {
				s/<BR>/\n/g
			}
		
			# Check number of attributes of each row
			if (@currAttribValues != @currAttribNames) {
				die "Number of attributes is different to number of values in line:\n" . $csv->string();
			} else {
				print( join( " | ", @currAttribValues )."\n" ) if $verbose;
				my %currAttribHash = ();
				@currAttribHash{@currAttribNames} = @currAttribValues;
				while ( my ( $key, $val ) = each %currAttribHash ) {
					delete $currAttribHash{$key} if ($val eq '\N' || $val eq '');
				}
				
				@currAttribValues = ();
				push (@{$data->[-1]}, \%currAttribHash);
			}
		}
           }
	}

	close $fh;

	print "[OK]\n";

	return $data;
}

sub populate_from_data {
	my $data_list = shift;
	while(@$data_list) {
		my $schema = shift @$data_list;
		my $data = shift @$data_list;
		for my $tuple (@{$data}) {
			# Assumes the constraints in the database are in deferred mode
			rs( $schema )->find_or_create( $tuple );
		}
	}
}

sub update_seqs() {
	my $dbh = db->storage->dbh;
	for my $source (db->sources()){
		my $table_name = db->source($source)->name;
		for my $col_name (db->source($source)->columns){
			my $col_info = db->source($source)->column_info($col_name);
			if(($col_info->{is_auto_increment}) and ((db->source($source)->{is_virtual} // 0) == 0)){
				my $val = (rs($source)->get_column($col_name)->max // 9999) + 1;
				$dbh->do("SELECT setval('${table_name}_${col_name}_seq', $val, false)");
			}
		}
	}
}

sub apply_function {
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

sub create_tuples_file {
	my $output_file = shift;
	open my $fh, ">", $output_file or die "Cannot open $output_file";
	my $csv = Text::CSV->new({sep_char => "\t", quote_char => "`", eol => "\n" });

	my $dbh = db->storage->dbh;
	for my $table (get_table_list($dbh)) {
		my ($schema) = grep { db->class($_)->table eq $table } db->sources;

		my $sth = $dbh->prepare("SELECT * FROM $table");
		$sth->execute();

		if ($sth->rows > 0) {
			my $fields = $sth->{NAME};

			print $fh "#### $schema ####\n";
			$csv->print($fh, $fields);
			while (my @row = $sth->fetchrow_array()) {
				for (@row) {
					s/\n//g if defined $_
				}
				$csv->print($fh, \@row);
			}
			print $fh "\n";
		}
	}

	close $fh;
}

sub get_table_list {
	my $dbh = shift;

	my $sth = $dbh->table_info('', 'public', undef, "TABLE");
	my @tables = map {$_->{TABLE_NAME}} @{$sth->fetchall_arrayref({})};

	return @tables;
}

### MAIN ###

my $error = "NO_ERROR";
my $force = 0;
my $update_schema = 0;
my $update_from_version = undef;
my $verbose = 0;
my $dirname = dirname(__FILE__);
my @datafiles = ();

GetOptions(
	"force|f"         => \$force,
	"file=s"          => \@datafiles,
	"update-from=s"   => \$update_from_version,
	"update-schema"   => sub { $force = 1; $update_schema = 1; $update_from_version = 'latest'; },
	"verbose|v"       => \$verbose,
) or exit (1);

push @datafiles, "$dirname/qvd-init-data.dat" if !$update_schema;

if ($update_from_version && !qvd_version_upgrade_available($update_from_version)){
	print("Cannot update from version $update_from_version\n") && exit(1);
}


try {
	### CHECK IF DB IS DEPLOYED ###
	unless ($force) {
		eval {
			db->storage->dbh->do("select count(*) from configs;");
		};
		unless ($@ ne '') {
			$error = "ERROR_DB_ALREADY_DEPLOYED";
			die "Database already contains QVD tables, use '--force' to redeploy the database";
		}
	}

	### PARSE AND CHECK INPUT DATA ###

	my @data_parsed = ();

	try{

		# Parse data from data files
		for my $db_file (@datafiles) {
			my $data = get_data_from_file( { filepath => $db_file, verbose => $verbose } );
			push @data_parsed, $data;
		}

		# Check if update is needed to get tuple file
		if($update_from_version || $update_schema) {
			my $old_tuples_file = "$dirname/qvd-old-tuples.dat";
			create_tuples_file($old_tuples_file);
			my $data = get_data_from_file( { filepath => $old_tuples_file, verbose => $verbose } );
			$data = qvd_upgrade_db_data($data, $update_from_version);
			push @data_parsed, $data;
		}

	} catch {
		my $exception = $_;
		$error = "ERROR_DATA_FILE_INVALID"; die "$exception";
	};

	### DATABASE DEPLOYMENT ###

	db->txn_begin();

	# Generate database
	try{
		db->deploy( {
			add_drop_table => 1, 
			add_enums      => ENUMERATES(), 
			add_init_vars  => INITIAL_VALUES(),
		} );
	} catch {
		db->txn_rollback();
		my $exception = $_;
		$error = "ERROR_DB_DEPLOY_FAILED"; die "$exception";
	};

	# Populate database if DATA is valid
	try {
		for my $data (@data_parsed) {
			populate_from_data($data);
		}
		update_seqs();
	} catch {
		db->txn_rollback();
		my $exception = $_;
		$error = "ERROR_DB_POPULATE_FAILED"; die "$exception";
	};

	db->txn_commit();

} catch {
	my $exception = $_;
	display_error($error, $exception);
};

exit(error_code($error));
