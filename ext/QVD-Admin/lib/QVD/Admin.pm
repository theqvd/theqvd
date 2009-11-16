package QVD::Admin;

use warnings;
use strict;

use QVD::DB;

sub new {
    my $class = shift;
    my $db = shift // QVD::DB->new();
    my $self = {db => $db,
		filter => {},
		objects => {
		    host => 'Host',
		    vm => 'VM',
		    user => 'User',
		    conf => 'Config',
		    osi => 'OSI',
		},
    };
    bless $self, $class;
}

sub _split_on_equals {
    my %r = map { my @a = split /=/; $a[0] => $a[1] } @_;
    \%r
}

sub _query_to_hash {
    # 'a=b,c=d' -> {'a' => 'b', 'c' => 'd}
    _split_on_equals split(/,\s*/, shift);
}

sub set_filter {
    my ($self, $filter_string) = @_;
    $self->{filter} = _query_to_hash $filter_string;
}

sub _get_result_set {
    my ($self, $obj) = @_;
    my $db_object = $self->{objects}{$obj};
    die "$obj: unsupported object" unless defined $db_object;
    if ($self->{filter}) {
    	$self->{db}->resultset($db_object)->search($self->{filter});
    } else {
    	$self->{db}->resultset($db_object);
    }
}

sub dispatch_command {
    my ($self, $object, $command, @args) = @_;
    my $rs = $self->_get_result_set($object);
    my $method = $self->can("cmd_${object}_${command}");
    if (defined $method) {
	$self->$method($rs, @args);
    } else {
	die "$object: $command not implemented";
    }
}

sub cmd_host_list {
    my ($self, $rs, @args) = @_;
    while (my $host = $rs->next) {
	printf "%s\t%s\t%s\n", $host->id, $host->name, $host->address;
    }
}

sub cmd_host_add {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    my @required_params = ('name', 'address');
    die "Invalid parameters" if keys %$params != @required_params;
    $rs->create($params);
}

1;

__END__

=head1 NAME

QVD::Admin - The great new QVD::Admin!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Admin;

    my $foo = QVD::Admin->new();
    ...

=head1 AUTHOR

Qindel Formacion y Servicios S.L., C<< <joni.salonen at qindel.es> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
