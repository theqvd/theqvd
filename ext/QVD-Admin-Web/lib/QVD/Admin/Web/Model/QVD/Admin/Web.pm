package QVD::Admin::Web::Model::QVD::Admin::Web;

use Moose;
use QVD::DB::Simple;
use QVD::Admin;
use Log::Log4perl qw(:easy);
use Data::Dumper;
extends 'Catalyst::Model';
with 'MooseX::Log::Log4perl';

BEGIN {
    Log::Log4perl->easy_init('log4perl.conf')
	unless Log::Log4perl->initialized;
}

sub version { $QVD::Admin::Web::VERSION }

sub admin { shift->{admin} ||= QVD::Admin->new }

# status 1 means Ok, and 0 means error, detail in error_msg
has 'status' => ( is => 'ro', isa => 'Int', default => 1 );

has 'error_msg' => ( is => 'ro', isa => 'Str', default => undef );

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
    $self->log->error($msg);
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

sub user_list {
    my ( $self, $filter ) = @_;
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

sub osi_list {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    [rs(OSI)->search($filter)];
}

sub osi_find {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    rs(OSI)->find($filter)  ;
}

sub osi_add {
    my ( $self, $params ) = @_;
    $self->reset_status;
    my $id = eval { $self->admin->cmd_osi_add(%$params) };
    $self->set_error($@) unless defined $id;
    $id;
}

sub osi_del {
    my ( $self, $id ) = @_;
    $self->reset_status;
    my $ok = eval {
	$self->admin->set_filter( id => $id );
	$self->admin->cmd_osi_del;
    };
    $self->set_error($@) unless defined $ok;
    $ok;
}

sub vm_list {
    my ( $self, $filter ) = @_;
    $self->reset_status;
    [rs(VM)->search($filter)];
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
				       select => ['vm_state',
						  { count => '*'}],
				       as => ['vm_state', 'vm_count'] }) ];
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

sub osi_total_stats {
    my ($self, $filter) = @_;
    rs(OSI)->search($filter)->count;
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

Nito Martinez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.




1;
