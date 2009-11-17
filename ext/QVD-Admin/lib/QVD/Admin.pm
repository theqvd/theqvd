package QVD::Admin;

use warnings;
use strict;

use QVD::DB;
use QVD::Config;

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

sub cmd_osi_add {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;

    # Default OSI parameters
    # FIXME Detect type of image and set use_overlay accordingly, iso=no overlay
    $params->{memory} //= 256;
    $params->{use_overlay} //= 1;
    
    use File::Basename qw/basename/;
    my $img = $params->{disk_image};
    $params->{disk_image} = basename($img);

    die "Invalid parameters" unless _set_equals([keys %$params],
	[qw/name memory use_overlay disk_image/]);

    # Copy image to ro-directory
    die "disk_image is not optional" unless defined $params->{disk_image};
    my $destination = QVD::Config->get('ro_storage_path');
    use File::Copy qw/copy/;
    copy($img, $destination) or die "Unable to copy $img to storage: $^E";

    $rs->create($params);
}

sub cmd_host_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    $rs->delete_all;
}

sub cmd_user_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    $rs->delete_all;
}

sub cmd_osi_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    $rs->delete_all;
}

sub _obj_setprop {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't let us
    while (my $obj = $rs->next) {
	foreach my $key (keys %$params) {
	    $obj->properties->search({key => $key})->update_or_create({
		    key => $key,
		    value => $params->{$key}
		    }
		    , {key => 'primary'}
		    );
	}
    }
}

sub cmd_host_setprop {
    shift->_obj_setprop(@_);
}

sub cmd_user_setprop {
    shift->_obj_setprop(@_);
}

sub _obj_getprop {
    my ($self, $display_cb, $rs, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my @props = $rs->search_related('properties', $condition);
    print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @props;
}

sub cmd_host_getprop {
    shift->_obj_getprop(sub { $_->host->name }, @_);
}

sub cmd_user_getprop {
    shift->_obj_getprop(sub { $_->user->login }, @_);
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
