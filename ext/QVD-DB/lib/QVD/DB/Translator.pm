package QVD::DB::Translator;
use strict;
use warnings FATAL => 'all';
use QVD::Log;
use List::Util qw(sum);

=head1 NAME

QVD::DB::Translator - Translator for the QVD Postgresql Database

=head1 DESCRIPTION

This package adds the features to translate to Postgresql queries that are not
supported by DBIx::Class package.

Errors during the translation will be written in the QVD::Log;

=cut

=head2 translate_create_procedure

Generate a query to create a new procedure in the database.

The input is a hash reference with the following keys:
- replace    -> 1 to overwrite the procedure if exists, 0 otherwise (Optional)
- name       -> Name of the procedure (Compulsory)
- returns    -> Type of value returned by the procedure (Optional)
- language   -> Language of the query (Optional, "plpgsql" by default)
- sql        -> SQL query (Compulsory)
- parameters -> Array of parameters of the procedure (Optional)

Returns undef in case an error is encounter during the translation.

=cut

sub translate_create_procedure {
	my ($args) = @_;
	my @checks = ();

	my $replace = (($args->{replace} // 0) >= 1 ) ? "OR REPLACE" : "";
	my $name = $args->{name} // "";
	my $returns = (($args->{returns} // "") ne "") ? "RETURNS $args->{returns}" : "";
	my $language = ($args->{language} // "plpgsql");
	my $sql = ($args->{sql} // "");
	my @params = @{$args->{parameters} // []};

	ERROR "Procedure {name} cannot be empty" if ( $checks[push(@checks, $name eq "") - 1] );
	ERROR "Procedure {sql} command cannot be empty" if ( $checks[push(@checks, $sql eq "") - 1] );

	my $translation = undef;
	if ( (sum(@checks) // 0) == 0) {
		$translation = "CREATE $replace FUNCTION $name(".join(",",@params).") $returns LANGUAGE $language AS $sql;";
	}

	return $translation;
}

=head2 translate_drop_procedure

Generate a query to delete a procedure from the database.

The input is a hash reference with the following keys:
- name       -> Name of the procedure (Compulsory)

Returns undef in case an error is encounter during the translation.

=cut

sub translate_drop_procedure {
	my ($args) = @_;
	my @checks = ();

	my $name = $args->{name} // "";

	ERROR "Procedure {name} cannot be empty" if ( $checks[push(@checks, $name eq "") - 1] );

	my $translation = undef;
	if ( (sum(@checks) // 0) == 0) {
		$translation = "DROP FUNCTION IF EXISTS $name();";
	}

	return $translation;
}

=head2 translate_create_trigger

Generate a query to create a new trigger in the database.

The input is a hash reference with the following keys:
- name       -> Name of the trigger (Compulsory)
- when       -> Array of conditions of the trigger: "AFTER", "BEFORE", "INSTEAD OF" (Compulsory)
- events     -> Array of events of the trigger: "INSERT", "UPDATE", "DELETE", "TRUNCATE" (Compulsory)
- fields     -> Array of fields affected by the trigger (Optional)
- on_table   -> Table affected by the trigger (Compulsory)
- scope      -> Scope of the trigger: "ROW", "STATEMENT" (Compulsory)
- procedure  -> Procedure name to be executed if trigger is triggered (Compulsory)
- parameters -> Parameters of the procedure (Optional)

Returns undef in case an error is encounter during the translation.

=cut

sub translate_create_trigger {
	my ($args) = @_;
	my @checks = ();

	my $name = $args->{name} // "";
	my $when = uc($args->{when} // "");
	my @when_params = ("AFTER", "BEFORE", "INSTEAD OF");
	my @events = map { uc } @{($args->{events} // ())};
	my @events_params = {"INSERT", "UPDATE", "DELETE", "TRUNCATE"};
	my @fields = @{$args->{fields} // []};
	my $table = $args->{on_table} // "";
	my $scope = $args->{scope} // "";
	my @scope_params = ("ROW", "STATEMENT");
	# TODO add condition
	my $procedure = $args->{procedure} // "";
	my @params = @{$args->{parameters} // []};

	ERROR "Trigger {name} cannot be empty" if ( $checks[push(@checks, $name eq "") - 1] );
	ERROR "Trigger {when} cannot be empty" if ( $checks[push(@checks, $when eq "") - 1] );
	ERROR "Trigger {when} invalid parameters. Expected: @when_params"
		if ( $checks[push(@checks, not($when ~~ @when_params))- 1] );
	ERROR "Trigger {events} cannot be empty" if ( $checks[push(@checks, "@events" eq "") - 1] );
	ERROR "Trigger {on_table} cannot be empty" if ( $checks[push(@checks, $table eq "") - 1] );
	# FIXME Check events_params
	ERROR "Trigger {scope} cannot be empty" if ( $checks[push(@checks, $scope eq "") - 1] );
	ERROR "Trigger {scope} invalid parameters. Expected: @scope_params"
		if ( $checks[push(@checks, not($scope ~~ @scope_params))- 1] );

	my $translation = undef;
	if ( (sum(@checks) // 0) == 0) {
		# FIXME fields are not asociated with the UPDATE event
		$translation = "CREATE TRIGGER $name $when ".join(" OR ", @events).
			(@fields ? " OF ".join(",",@fields) : "").
			" ON $table FOR EACH $scope EXECUTE PROCEDURE $procedure(".join(",",@params).")";
	}

	return $translation;
}

=head2 translate_drop_trigger

Generate a query to delete a trigger from the database.

The input is a hash reference with the following keys:
- name       -> Name of the trigger (Compulsory)
- on_table   -> Table affected by the trigger (Compulsory)

Returns undef in case an error is encounter during the translation.

=cut

sub translate_drop_trigger {
	my ($args) = @_;
	my @checks = ();

	my $name = $args->{name} // "";
	my $table = $args->{on_table} // "";

	ERROR "Trigger {name} cannot be empty" if ( $checks[push(@checks, $name eq "") - 1] );
	ERROR "Trigger {on_table} cannot be empty" if ( $checks[push(@checks, $table eq "") - 1] );

	my $translation = undef;
	if ( (sum(@checks) // 0) == 0) {
		$translation = "DROP TRIGGER IF EXISTS $name on $table";
	}

	return $translation;
}

=head1 AUTHOR

QVD

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut

1;