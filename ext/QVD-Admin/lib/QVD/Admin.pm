package QVD::Admin;

use warnings;
use strict;

use QVD::DB;
use QVD::Config;

sub new {
    my $class = shift;
    my $quiet = shift;
    my $db = shift // QVD::DB->new();
    my $self = {db => $db,
		filter => {},
		quiet => $quiet,
		objects => {
		    host => 'Host',
		    vm => 'VM',
		    user => 'User',
		    config => 'Config',
		    osi => 'OSI',
		},
    };
    bless $self, $class;
}

sub _split_on_equals {
    my %r = map { my @a = split /=/, $_, 2; $a[0] => $a[1] } @_;
    \%r
}

sub set_filter {
    my ($self, $filter_string) = @_;
    # 'a=b,c=d' -> {'a' => 'b', 'c' => 'd}
    my $conditions = _split_on_equals split /,\s*/, $filter_string;
    while (my ($k, $v) = each %$conditions) {
	if ($v =~ /[*?]/) {
	    $v =~ s/([_%])/\\$1/g;
	    $v =~ tr/*?/%_/;
	    $self->{filter}{$k} = {like => $v};
	} else {
	    $self->{filter}{$k} = $v;
	}
    }
}

sub _get_result_set {
    my ($self, $obj) = @_;
    my $db_object = $self->{objects}{$obj};
    die_and_help ("$obj: Unsupported object") unless defined $db_object;
    if ($self->{filter}) {
    	$self->{db}->resultset($db_object)->search($self->{filter});
    } else {
    	$self->{db}->resultset($db_object);
    }
}

sub dispatch_command {
    my ($self, $object, $command, @args) = @_;
    my $rs = $self->_get_result_set($object);
    die_and_help ("$object: Valid command expected") unless defined $command;
    my $method = $self->can("cmd_${object}_${command}");
    if (defined $method) {
	$self->$method($rs, @args);
    } else {
	die_and_help ("$object: $command not implemented");
    }
}

sub _format_timespan {
    my $seconds = shift;
    my $secs = $seconds%60;
    my $mins = ($seconds /= 60) % 60;
    my $hours = ($seconds /= 60);
    return sprintf "%02d:%02d:%02d", $hours, $mins, $secs;
}

sub _print_header {
    my @titles = @_;
    print join("\t", @titles)."\n";
    print join("\t", map { s/./-/g; $_ } @titles)."\n";
}

sub cmd_host_list {
    my ($self, $rs, @args) = @_;
    _print_header "Id", "Name", "Address ","HKD", "VMs assigned"
	    unless $self->{quiet};

    while (my $host = $rs->next) {
	# FIXME proper formatting
	my $hkd_ts = defined $host->runtime ? $host->runtime->hkd_ok_ts : undef;
	my $mins = defined $hkd_ts ? _format_timespan(time - $hkd_ts) : '-';
	print join "\t", $host->id, $host->name, $host->address, $mins,
			    $host->vms->count;
	print "\n";

    }
}

sub cmd_user_list {
    my ($self, $rs, @args) = @_;
    _print_header "Id","Login" unless $self->{quiet};
    while (my $user = $rs->next) {
	printf "%s\t%s\n", $user->id, $user->login;
    }
}

sub cmd_vm_list {
    my ($self, $rs, @args) = @_;
    _print_header "Id","Name","State","Host" unless $self->{quiet};
    while (my $vm = $rs->next) {
	my $vm_runtime = $vm->vm_runtime;
	my $host = $vm_runtime->host;
	my $host_name = defined $host ? $host->name : '-';
	print join "\t", $vm->id, $vm->name, $vm_runtime->vm_state, $host_name;
	print "\n";
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
    my $self = shift;
    my $row = $self->_obj_add([qw/name address/], @_);
    $self->{db}->resultset('Host_Runtime')
			    ->create({host_id => $row->id});
    print "Host added with id ".$row->id."\n" unless $self->{quiet};
}

sub cmd_vm_add {
    my $self = shift;
    my $row = $self->_obj_add([qw/name user_id osi_id ip/], @_);
    $self->{db}->resultset('VM_Runtime')
			    ->create({vm_id => $row->id});
    print "VM added with id ".$row->id."\n" unless $self->{quiet};
}

sub cmd_user_add {
    my $self = shift;
    my $row = $self->_obj_add([qw/login password/], @_);
    print "User added with id ".$row->id."\n" unless $self->{quiet};
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
    # FIXME Overwriting existing image should be an error
    die "disk_image is not optional" unless defined $params->{disk_image};
    my $destination = QVD::Config->get('ro_storage_path');
    use File::Copy qw/copy/;
    copy($img, $destination) or die "Unable to copy $img to storage: $^E";

    my $row = $rs->create($params);

    print "OSI added with id ".$row->id."\n" unless $self->{quiet};
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

sub cmd_vm_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    $rs->delete_all;
}

sub cmd_osi_del {
    my ($self, $rs, @args) = @_;
    # FIXME Ask for confirmation if try to delete all without filter?
    # FIXME Should we delete the actual image file?
    $rs->delete_all;
}

sub _obj_propset {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't seem to let us
    while (my $obj = $rs->next) {
	foreach my $key (keys %$params) {
	    $obj->properties->search({key => $key})->update_or_create(
		{ key => $key, value => $params->{$key} },
		{ key => 'primary' }
	    );
	}
    }
}

sub cmd_host_propset {
    shift->_obj_propset(@_);
}

sub cmd_user_propset {
    shift->_obj_propset(@_);
}

sub cmd_vm_propset {
    shift->_obj_propset(@_);
}

sub _obj_propget {
    my ($self, $display_cb, $rs, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my @props = $rs->search_related('properties', $condition);
    print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @props;
}

sub cmd_host_propget {
    shift->_obj_propget(sub { $_->host->name }, @_);
}

sub cmd_user_propget {
    shift->_obj_propget(sub { $_->user->login }, @_);
}

sub cmd_vm_propget {
    shift->_obj_propget(sub { $_->vm->name }, @_);
}

sub cmd_config_set {
    my ($self, $rs, @args) = @_;
    my $params = _split_on_equals @args;
    foreach my $key (keys %$params) {
	$rs->update_or_create({
		key => $key,
		value => $params->{$key}
	    });
    }
}

sub cmd_config_get {
    my ($self, $rs, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my @configs = $rs->search($condition);
    print map { $_->key.'='.$_->value."\n" } @configs;
}

sub die_and_help {
    my ($message) = @_;
    
    $message = "Unknown error" unless defined($message);
    
    my @funcs = do {
	no strict;
	grep exists &{"QVD::Admin::$_"}, keys %{"QVD::Admin::"};
    };
    #@funcs = grep {/^cmd/} @funcs;
    @funcs = grep {s/^cmd_//} @funcs;
    @funcs = grep {s/_/ > /} @funcs;
    
    print $message.", try one of this commands:\n\n";
    
    print join "\n", sort @funcs;
    print "\n\n";
    
    die;
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
