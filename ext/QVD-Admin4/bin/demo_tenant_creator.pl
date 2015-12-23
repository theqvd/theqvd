#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(first_index);
use Getopt::Long;

# Get input parameters
my $tenant_superadmin = "*";
my $login_superadmin = "superadmin";
my $password_superadmin = "superadmin";

my $tenant_name;
my $admin_name = "admin";
my $user_name = "user";

GetOptions (
	"stenant=s"   => \$tenant_superadmin,
	"slogin=s"    => \$login_superadmin,
	"spass=s"     => \$password_superadmin,
	"newtenant=s" => \$tenant_name,
	"newadmin=s"  => \$admin_name,
	"newuser=s"   => \$user_name,
) or die("[ERROR] Command line arguments not valid\n");

die("[ERROR] New tenant name not defined\n") if not defined $tenant_name;

# qvd-administrator tool directory
my $perl = "/usr/lib/qvd/bin/perl -Mlib::glob=./*/lib";
my $qa = "./QVD-Admin4/bin/qa -t CSV ";

# Environment variables to be set
my %env_variables = (
	QVD_ADMIN_TENANT => $tenant_superadmin,
	QVD_ADMIN_PASSWORD => $password_superadmin,
	QVD_ADMIN_LOGIN => $login_superadmin,
);

# Commands order
my @order_array = qw/
	cmd_new_tenant
	cmd_new_admin
	cmd_assign_role
	cmd_new_user
	cmd_new_osf
	cmd_new_di
	cmd_new_vm/;
my %order_hash = map { $order_array[$_] => $_ + 1 } 0 .. $#order_array;

# Commands to be executed
my %command_outputs = ();
my %commands = (
	$order_hash{cmd_new_tenant} => {
		object => "tenant",
		action => "new",
		arguments => {
			name => $tenant_name,
		},
	},
	$order_hash{cmd_new_admin}  => {
		object => "admin",
		action => "new",
		arguments => {
			name => "$admin_name",
			tenant_id => sub { getCommandRowValue($order_hash{cmd_new_tenant}, 0, "id") },
			password => "$admin_name",
		},
	},
	$order_hash{cmd_assign_role}  => {
		object => "admin",
		action => "assign role",
		filters => {
			id => sub { getCommandRowValue($order_hash{cmd_new_admin}, 0, "id") },
		},
		arguments => {
			"Administrator" => undef,
		},
	},
	$order_hash{cmd_new_user}  => {
		object => "user",
		action => "new",
		arguments => {
			name => "$user_name",
			password => "$user_name",
			tenant_id => sub { getCommandRowValue($order_hash{cmd_new_tenant}, 0, "id") },
		},
	},
	$order_hash{cmd_new_osf}  => {
		object => "osf",
		action => "new",
		arguments => {
			name => "osf_default",
			tenant_id => sub { getCommandRowValue($order_hash{cmd_new_tenant}, 0, "id") },
		},
	},
	$order_hash{cmd_new_di}  => {
		object => "di",
		action => "new",
		arguments => {
			osf_id => sub { getCommandRowValue($order_hash{cmd_new_osf}, 0, "id") },
			disk_image => "empty-image.tar.gz",
			#disk_image => "ubuntu-13.04-i386-qvd.tar.gz",
		},
	},
	$order_hash{cmd_new_vm}  => {
		object => "vm",
		action => "new",
		arguments => {
			user_id => sub { getCommandRowValue($order_hash{cmd_new_user}, 0, "id") },
			osf_id => sub { getCommandRowValue($order_hash{cmd_new_osf}, 0, "id") },
			di_tag => "default",
			name => "vm_default",
		},
	}
);

# Command methods

sub getCommandList {
	return sort(keys(%commands));
}

sub getCommand {
	my $cmd = shift;
	return $commands{$cmd};
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
	while( my ($key, $value) = each(getCommandFilters($cmd)) ){
		push @pairs, "$key=\"$value\"";
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
	my $output = `$qa_command`;
	my $exit_code = ( ($? == -1) ? $! : 0 );
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
for my $cmd (getCommandList()){
	evaluateCommand($cmd);
	print "$cmd - " . commandAsString($cmd) . " :\n";
	print "Exit(" . executeCommand($cmd) . ")\n";
	print getCommandOutput($cmd);
	print "\n";
	# TODO restoreCommand($cmd)
}
