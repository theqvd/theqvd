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

sub cmd_user_list {
    my ($self, $rs, @args) = @_;
    while (my $user = $rs->next) {
	printf "%s\t%s\n", $user->id, $user->login;
    }
}

sub _set_equals {
    my ($a, $b) = @_;
    return 0 if scalar @$a != scalar @$b;
    my @a = sort @$a;
    my @b = sort @$b;
    foreach my $i (0 .. @a-1) {
	return 0 if $a[$i] ne $b[$i];
    }
    return 1;
}

sub _obj_add {
    my ($self, $required_params, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    die "Invalid parameters" 
    	unless _set_equals([keys %$params], $required_params);
    $rs->create($params);
}

sub cmd_host_add {
    shift->_obj_add([qw/name address/], @_);
}

sub cmd_user_add {
    shift->_obj_add([qw/login password/], @_);
}

sub cmd_host_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    # To delete with cascade you would have to use delete_all.
    $rs->delete;
}

sub cmd_user_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    # To delete with cascade you would have to use delete_all.
    $rs->delete;
}

sub cmd_host_setprop {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't let us
    while (my $host = $rs->next) {
	foreach my $key (keys %$params) {
	    $host->properties->search({key => $key})->update_or_create({
		    key => $key,
		    value => $params->{$key}
		    }
		    , {key => 'primary'}
		    );
	}
    }
}

sub cmd_host_getprop {
    my ($self, $rs, @args) = @_;
    foreach my $key (@args) {
	my @props = $rs->search_related('properties', {key => $key});
	print join "\n", map { $_->host->name."\t".$_->key.'='.$_->value } @props;
	print "\n";
    }
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
