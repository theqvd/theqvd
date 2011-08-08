package QVD::Admin::Web::Model::QVD::Admin::Web;

use Moose;
use QVD::DB::Simple;
use QVD::Admin;
use QVD::Log;
use Data::Dumper;

extends 'Catalyst::Model';

sub version { $QVD::Admin::Web::VERSION }

sub admin { shift->{admin} ||= QVD::Admin->new }

# status 1 means Ok, and 0 means error, detail in error_msg
has 'status' => ( is => 'ro', isa => 'Int', default => 1 );

has 'error_msg' => ( is => 'ro', isa => 'Str', default => '' );

#sub BUILD {
#    my $self = shift;
#    $self->quiet(1);
#}

sub reset_status {
    my $self = shift;
    $self->{status} = 1;
    $self->admin->reset_filter;
}

sub set_error {
    my ( $self, $msg ) = @_;
    $self->{status}    = 0;
    $self->{error_msg} = $msg;
    DEBUG "$self->set_error($msg)";
}

sub host_add {
    my ( $self, $name, $address ) = @_;

    $self->reset_status;
    my $id = eval { $self->admin->cmd_host_add( name => $name, address => $address ) };
    defined $id or $self->set_error($@);
    $id;
}

sub host_list {
    my ( $self, $filter ) = @_;

    $self->reset_status;
    # FIXME later, please!
    # AFAIK, there is not need for the array ref
    # check also similar subs below
    return [rs(Host)->search($filter)];
}

# FIXME: it doesn't makes sense to pass a generic filter to find, just
# the row id should be given!
sub host_find {
    my ($self, $filter) = @_;
    $self->reset_status;
    rs(Host)->find($filter);
}

sub host_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    my $ok = eval {
        $self->admin->set_filter( id => $id );
        $self->admin->cmd_host_del;
    };
    $self->set_error($@) unless defined $ok;
    $ok;
}

sub host_block {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_host_block_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub host_unblock {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_host_unblock_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub user_list {
    my ( $self, $filter) = @_;
    $self->reset_status;
    [rs(User)->search($filter)];
}

sub user_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    rs(User)->find($filter);
}

sub user_add {
    my ( $self, $params ) = @_;
    $self->reset_status;
    my $id = eval { $self->admin->cmd_user_add(%$params) };
    $self->set_error($@) unless defined $id;
    $id;
}

sub user_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    my $ok = eval {
        $self->admin->set_filter( id => $id );
        $self->admin->cmd_user_del;
    };
    $self->set_error($@) unless $ok;
    $ok;
}

sub user_passwd {
    my ( $self, $user, $passwd ) = @_;
    $self->reset_status;
    my $ok = eval {
        $self->{admin}->set_password($user, $passwd);
    };
    $self->set_error($@) unless $ok;
    $ok;
}

sub osf_list {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    [rs(OSF)->search($filter)];
}

sub osf_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    rs(OSF)->find($filter);
}

sub osf_add {
    my ( $self, $params ) = @_;
    $self->reset_status;
    my $id = eval { $self->admin->cmd_osf_add(%$params) };
    $self->set_error($@) unless defined $id;
    $id;
}

sub osf_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    my $ok = eval {
        $self->admin->set_filter( id => $id );
        $self->admin->cmd_osf_del;
    };
    $self->set_error($@) unless defined $ok;
    $ok;
}

sub di_list {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    [rs(DI)->search($filter)];
}

sub di_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    rs(DI)->find($filter);
}

sub di_add {
    my ( $self, $params ) = @_;
    $self->reset_status;
    my $id = eval { $self->admin->cmd_di_add(%$params) };
    $self->set_error($@) unless defined $id;
    $id;
}

sub di_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    my $ok = eval {
        $self->admin->set_filter( id => $id );
        $self->admin->cmd_di_del;
    };
    $self->set_error($@) unless defined $ok;
    $ok;
}

sub vm_list {
    my ( $self, $filter, $attrs) = @_;
    $self->reset_status;
    [rs(VM)->search($filter, $attrs)];
}

sub vm_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    rs(VM)->find($filter);
}

sub vm_start {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_start_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_stop {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_stop_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_reset {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_reset_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_disconnect_user {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_disconnect_user_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_block {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_block_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_unblock {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval { $self->admin->cmd_vm_unblock_by_id($id) };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_add {
    my ($self, $params) = @_;
    $self->reset_status;
    my $id = eval { $self->admin->cmd_vm_add(%$params) };
    $self->set_error($@) unless defined $id;
    $id;
}

sub vm_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    eval {
        $self->admin->set_filter( id => $id );
        $self->admin->cmd_vm_del;
    };
    if ($@) {
        $self->set_error($@);
        return undef;
    }
    1;
}

sub vm_edit {
    my ($self, $params) = @_;
    $self->reset_status;
    my $count = eval { $self->admin->cmd_vm_edit(%$params) };
    $self->set_error($@) unless defined $count;
    $count;
}

sub vmrt_list {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    return [ rs(VM_Runtime)->search($filter) ]  ;
}

sub vmrt_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    return rs(VM_Runtime)->find($filter);
}

sub vm_stats {
    my ($self, $filter) = @_;
    [ rs(VM_Runtime)->search($filter,{ group_by => ['vm_state'],
                                       select   => ['vm_state',
                                                  { count => '*'}],
                                       as => ['vm_state', 'vm_count'] }) ];
}

sub host_stats {
    my ($self, $filter) = @_;
    [ rs(Host_Runtime)->search($filter,{ group_by => ['state'],
                                         select   => ['state',
                                                  { count => '*'}],
                                         as => ['host_state', 'host_count'] }) ];
}

# FIXME: use better names for these *_total_stats subs or just remove
# then and inline the ->count method call into the caller
sub user_total_stats {
    my ($self, $filter) = @_;
    rs(User)->search($filter)->count;
}

sub vm_total_stats {
    my ($self, $filter) = @_;
    rs(VM)->search($filter)->count;
}

sub host_total_stats {
    my ($self, $filter) = @_;
    rs(Host)->search($filter)->count;
}

sub osf_total_stats {
    my ($self, $filter) = @_;
    rs(OSF)->search($filter)->count;
}

sub session_connected_stats {
    my ($self, $filter) = @_;
    local $filter->{user_state} = 'connected';
    rs(VM_Runtime)->search($filter)->count;
}

=head 2 build_form_error_msg

Simple method that receives as input a Data::FormValidator::Results object
and returns a simple string with errors

=cut

# FIXME: it is not clear where this method belongs to the Model class
# as it generates presentation mark up.
sub build_form_error_msg {
    my ( $self, $results ) = @_;
    my $result_msg = '';
    if ( $results->has_missing ) {
        for my $f ( $results->missing ) {
            # FIXME: no HTML in the model, please!
            $result_msg .= "$f is missing<br>\n";
        }
    }

    # Print the name of invalid fields
    if ( $results->has_invalid ) {
        for my $f ( $results->invalid ) {
            # FIXME: no HTML in the model, please!
            $result_msg .=
              "$f is invalid: " . $results->invalid($f) . " <br>\n";
        }
    }

    # Print unknown fields
    if ( $results->has_unknown ) {
        for my $f ( $results->unknown ) {
            # FIXME: no HTML in the model, please!
            $result_msg .= "$f is unknown<br>\n";
        }
    }
    return $result_msg;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

QVD::Admin::Web::Model::QVD::Admin::Web - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Nito Martinez, Hugo Cornejo

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
