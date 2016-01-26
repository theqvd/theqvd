#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(first_index);
use Getopt::Long;
use Backticks;

# Constants
my $EXIT_ERROR_CODE = 1;
my $EXIT_OK_CODE = 0;

# Get input parameters
my $tenant_superadmin = "*";
my $login_superadmin = "superadmin";
my $password_superadmin = "superadmin";

my $tenant_name;
my $admin_name = "admin";
my $user_name = "user";

# Images
my @images = ();
my %images_map = (
	empty   => "empty-image.tar.gz",
	generic => "ubuntu-13.04-i386-qvd.tar.gz",
);

# Options
GetOptions (
	"stenant=s"   => \$tenant_superadmin,
	"slogin=s"    => \$login_superadmin,
	"spass=s"     => \$password_superadmin,
	"newtenant=s" => \$tenant_name,
	"newadmin=s"  => \$admin_name,
	"newuser=s"   => \$user_name,
	"image=s"     => \@images,
) or (print("Command line arguments not valid\n") and exit($EXIT_ERROR_CODE));

if (not defined $tenant_name) {
	print ("New tenant name not defined\n");
	exit($EXIT_ERROR_CODE);
}

# qvd-administrator tool directory
my $perl = "/usr/lib/qvd/bin/perl -Mlib::glob=./*/lib";
my $qa = "./QVD-Admin4/bin/qa -t CSV ";

# Environment variables to be set
my %env_variables = (
	QVD_ADMIN_TENANT => $tenant_superadmin,
	QVD_ADMIN_PASSWORD => $password_superadmin,
	QVD_ADMIN_LOGIN => $login_superadmin,
);

# Commands to be executed
my %command_order = ();
my %commands = ();
my %command_outputs = ();

addCommand( "cmd_get_tenants", "tenant", "get",
	{
			name => { operator => "~", value => "%$tenant_name%" },
		},
	{ }
);
addCommand( "cmd_new_tenant", "tenant", "new",
	{ },
	{
			name => sub {
			my $n_rows = getCommandRowsNumber(getCommandIdFromName("cmd_get_tenants"));
			my @tenant_names = map { getCommandRowValue(getCommandIdFromName("cmd_get_tenants"), $_, "name") } 0 .. $n_rows-1;
				return getNewTenantName($tenant_name, \@tenant_names);
			},
	}
);
addCommand( "cmd_get_new_tenant", "tenant", "get",
	{
		id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_tenant"), 0, "id") },
		},
	{ }
);
addCommand( "cmd_new_admin", "admin", "new",
	{ },
	{
			name => "$admin_name",
		tenant_id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_tenant"), 0, "id") },
			password => "$admin_name",
	}
);
addCommand( "cmd_assign_role", "admin", "assign role",
	{
		id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_admin"), 0, "id") },
		},
	{
			"Administrator" => undef,
	}
);
addCommand( "cmd_new_user", "user", "new",
	{ },
	{
			name => "$user_name",
			password => "$user_name",
		tenant_id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_tenant"), 0, "id") },
	}
);

my $image_number = 1;
my %image_count = map {$_ => 1} keys (%images_map);
for my $image (@images) {
	addCommand( "cmd_new_osf_$image_number", "osf", "new",
		{ },
		{
			name => "osf_${image}_$image_count{$image}",
			tenant_id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_tenant"), 0, "id") },
		},
	);
	addCommand( "cmd_new_di_$image_number", "di", "new",
		{ },
		{
			osf_id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_osf_$image_number"), 0, "id") },
			disk_image => $images_map{$image} // $image,
		}
	);
	addCommand( "cmd_new_vm_$image_number", "vm", "new",
		{ },
		{
			user_id => sub { getCommandRowValue(getCommandIdFromName("cmd_new_user"), 0, "id") },
			osf_id => sub {
				my $id = getCommandRowValue(getCommandIdFromName("cmd_new_osf_$image_number"), 0, "id");
				$image_number++;
				return $id;
	},
			di_tag => "default",
			name => "vm_${image}_$image_count{$image}",
	}
	);
	$image_count{$image}++;
	$image_number++;
}
# Need to restart the value to be increased during the execution
$image_number = 1;


# Command methods

sub addCommand {
	my ($name, $object, $action, $filters, $arguments) = @_;
	my $id = keys (%command_order) + 1;

	$command_order{$name} = $id;

	$commands{$id} = {
		object => $object,
		action => $action,
		filters => $filters,
		arguments => $arguments,
	};

	return $id;
}

sub getCommandList {
	return sort { $a <=> $b } (keys(%commands));
}

sub getCommand {
	my $cmd = shift;
	return $commands{$cmd};
}

sub getCommandIdFromName {
	my $name = shift;
	return $command_order{$name};
}

sub getCommandObject {
	my $cmd = shift;
	return getCommand($cmd)->{object} // "";
}

sub getCommandAction {
	my $cmd = shift;
	return getCommand($cmd)->{action} // "";
}

sub getCommandArguments {
	my $cmd = shift;
	return getCommand($cmd)->{arguments} // {};
}

sub getCommandFilters {
	my $cmd = shift;
	return getCommand($cmd)->{filters} // {};
}

sub isCommandOptional{
	my ($cmd) = @_;
	return getCommand($cmd)->{optional} // 0;
}

sub getCommandArgumentsAsString {
	my $cmd = shift;
	my @pairs = ();
	while( my ($key, $value) = each(getCommandArguments($cmd)) ){
		push @pairs, "$key" . ((defined $value) ? "=\"$value\"" : "");
	}
	my $str = join(", ", @pairs);
	return $str;
}

sub getCommandFiltersAsString {
	my $cmd = shift;
	my @pairs = ();
	while( my ($filter_name, $filter_value) = each(getCommandFilters($cmd)) ){
		my $operator;
		my $value = $filter_value;
		if(ref($value) eq 'HASH') {
			$operator = @$filter_value{operator};
			$value = @$filter_value{value};
		}
		$operator //= "=";
		push @pairs, "$filter_name$operator\"$value\"";
	}
	my $str = join(", ", @pairs);
	return $str;
}

sub commandAsString {
	my $cmd = shift;
	my $object = getCommandObject($cmd);
	my $action = getCommandAction($cmd);
	my $args = getCommandArgumentsAsString($cmd);
	my $filters = getCommandFiltersAsString($cmd);

	my $commandStr = "$object $filters $action $args";
	return $commandStr;
}

sub executeCommand {
	my $cmd = shift;

	my $commandStr = commandAsString($cmd);

	my $qa_command = "$perl $qa $commandStr 2>&1";
	my $cmd_output = `$qa_command`;
	my $output = $cmd_output->stdout();
	my $exit_code = $cmd_output->exitcode();
	storeCommandExecution($cmd, $exit_code, $output);

	return $exit_code;
}

sub evaluateCommand {
	my ($cmd) = @_;
	return evaluateHash(getCommand($cmd));
}

sub evaluateHash {
	my ($hash) = @_;

	for my $key (keys(%{$hash})){
		my $type = ref($hash->{$key});
		if($type eq "CODE"){
			$hash->{$key} = &{$hash->{$key}};
		} elsif ($type eq "HASH"){
			evaluateHash($hash->{$key});
		}
	}

	return 1;
}

sub storeCommandExecution {
	my ($cmd, $exit_code, $output) = @_;
	$command_outputs{$cmd}->{exit_code} = $exit_code;
	$command_outputs{$cmd}->{output} = $output;
	$command_outputs{$cmd}->{parsed_output} = parse_csv($output);
}

sub getCommandExitCode {
	my ($cmd) =  @_;
	return $command_outputs{$cmd}->{exit_code};
}

sub getCommandOutput {
	my ($cmd) =  @_;
	return $command_outputs{$cmd}->{output};
}

sub getCommandFields {
	my ($cmd) =  @_;
	return $command_outputs{$cmd}->{parsed_output}->{fields} // [];
}

sub getCommandRow {
	my ($cmd, $n) = @_;
	my $row = [];
	my @rows = @{$command_outputs{$cmd}->{parsed_output}->{rows} // []};
	if($n < @rows) { $row = $rows[$n] };
	return $row;
}

sub getCommandRowsNumber {
	my ($cmd) = @_;
	return @{$command_outputs{$cmd}->{parsed_output}->{rows} // []};
}

sub getCommandRowValue {
	my ($cmd, $row_n, $field) = @_;

	my @fields = @{getCommandFields($cmd)};
	my $field_index = first_index {$_ eq $field} @fields;
	my @row = @{getCommandRow($cmd, $row_n)};

	my $value = ($field_index != -1) ? $row[$field_index] : "" ;

	return $value;
}

sub getNewTenantName {
	my ($tenant_name, $tenant_list) = @_;
	my $new_tenant_name = $tenant_name;
	my $counter = 0;

	while ( (first_index { $_ eq $new_tenant_name } @$tenant_list) != -1 ) {
		$counter++;
		$new_tenant_name = "${tenant_name}_${counter}";
	}

	return $new_tenant_name;
}

sub parse_csv {
	my ($csv) = @_;
	my @lines = split("\n", $csv);
	my $csv_hash = {
		fields => [ split(";", $lines[0]) ],
		rows => [],
	};
	for(my $i = 1; $i < @lines; $i++) {
		push(@{$csv_hash->{rows}}, [ split(";", $lines[$i]) ]);
	}
	return $csv_hash;
}

### MAIN ###

# Set environment variables
while( my ($key, $value) = each(%env_variables) ) {
	$ENV{$key} = $value;
}

# Execute command list
my $error_found = 0;
my $error_message = "";
for my $cmd (getCommandList()){
	evaluateCommand($cmd);
	my $error_code = executeCommand($cmd);
	my $cmd_output = getCommandOutput($cmd);
	chomp($cmd_output);
	# TODO restoreCommand($cmd)

	print STDERR "$cmd - " . commandAsString($cmd) . " :\n";
	print STDERR "Exit(" . $error_code . ")\n";
	print STDERR $cmd_output;
	print STDERR "\n\n";

	if( (not isCommandOptional($cmd)) && ($error_code != 0)){
		$error_found = 1;
		$error_message = $cmd_output;
		last;
	}
}

print STDOUT ($error_found ? $error_message : getCommandRowValue(getCommandIdFromName("cmd_get_new_tenant"), 0, "name") ) . "\n";

exit($error_found ? $EXIT_ERROR_CODE : $EXIT_OK_CODE);
