package QVD::DB::Translator;
use strict;
use warnings;
use feature 'state';
use QVD::Log;

=head1 NAME

QVD::DB::Translator - Translator for the QVD Postgresql Database

=head1 DESCRIPTION

This package adds the features to translate to Postgresql queries that are not
supported by DBIx::Class package.

Errors during the translation will be written in the QVD::Log;

=cut

sub _check_arg_list {
    my ($name, $args, %opts) = @_;
    my $value = $args->{$name};

    $value //= $opts{default};

    unless (defined $value and @$value) {
        $opts{optional} and return;
        LOGDIE "Argument $name is mandatory (list)"
    }

    if ($opts{uc}) {
        $value = [map uc, @$value];
    }

    if (my $valid = $opts{valid}) {
        grep($_, @$valid) or LOGDIE "Argument $name item '$_' is not valid"
            for @$value;
    }
    elsif ($opts{keyword} // 1) {
        /^\w+$/ or LOGDIE "Argument $name item '$_' is not a valid keyword"
            for @$value;
    }
    @$value;
}

sub _check_arg {
    my ($name, $args, %opts) = @_;
    my $value = $args->{$name};

    $value //= $opts{default};

    unless (defined $value) {
        $opts{optional} or return;
        LOGDIE "Argument $name is mandatory (list)";
    }

    $value = uc $value if $opts{uc};

    if (my $valid = $opts{valid}) {
        grep($_ eq $value, @$valid) or LOGDIE "Argument $name value '$value' is not valid"
    }
    elsif ($opts{keyword} // 1) {
        $value =~ /^\w+$/ or LOGDIE "Argument $name value '$value' is not a valid keyword"
    }
    $value
}

sub _sql_join { join(' ', grep { defined and length } @_) }

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

    my $name = _check_arg(name => $args);
    my $replace = _check_arg(replace => $args, default => 0);
    my $returns = _check_arg(returns => $args, keyword => 0);
    my $language = _check_arg(language => $args, default => 'plpgsql');
    my $sql = _check_arg(sql => $args, keyword => 0);
    my @params = _check_arg_list(parameters => $args, optional => 1);

    _sql_join('CREATE',
              ($replace ? 'OR REPLACE' : ''),
              "FUNCTION $name(", join(', ', @params), ')',
              ($returns ? "RETURNS $returns" : ''),
              "LANGUAGE $language as $sql");
}

=head2 translate_drop_procedure

Generate a query to delete a procedure from the database.

The input is a hash reference with the following keys:
- name       -> Name of the procedure (Compulsory)

Returns undef in case an error is encounter during the translation.

=cut

sub translate_drop_procedure {
    my ($args) = @_;
    my $name = _check_arg(name => $args);

    "DROP FUNCTION IF EXISTS $name();";
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

    my $name = _check_arg(name => $args);
    my $procedure = _check_arg(procedure => $args);
    my $table = _check_arg(on_table => $args);
    my $when = _check_arg(when => $args, uc => 1,
                          valid => ['AFTER', 'BEFORE', 'INSTEAD OF']);
    my $scope = _check_arg(scope => $args,
                           valid => [qw(ROW STATEMENT)]);

    my @events = _check_arg_list(events => $args, uc => 1,
                                 valid => [qw(INSERT UPDATE DELETE TRUNCATE )]);
    my @fields = _check_arg_list(fields => $args, optional => 1);
    my @params = _check_arg_list(parameters => $args, optional => 1);

    _sql_join("CREATE TRIGGER $name $when",
              (join ' OR ', @events),
              (@fields ? (OF => join(', ', @fields)) : ''),
              "ON $table FOR EACH $scope EXECUTE PROCEDURE",
              "$procedure(", join(', ', @params), ")");
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

    my $name = _check_arg(name => $args);
    my $table = _check_arg(on_table => $args);

    "DROP TRIGGER IF EXISTS $name on $table";
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
