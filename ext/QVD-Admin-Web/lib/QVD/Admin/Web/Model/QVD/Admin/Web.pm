package QVD::Admin::Web::Model::QVD::Admin::Web;

use Moose;
use QVD::DB;
use QVD::Admin;
use QVD::Config;
use Log::Log4perl qw(:easy);
use Readonly;
extends 'Catalyst::Model';
with 'MooseX::Log::Log4perl';

BEGIN {
    if(!(Log::Log4perl->initialized())) {
	Log::Log4perl->easy_init('log4perl.conf');
    }
}


has 'version' => (is => 'ro', isa => 'Str',
    default => sub { return "$QVD::Admin::Web::VERSION";  }
    );

has 'admin' => (is => 'ro', isa => 'QVD::Admin',
		default => sub { return QVD::Admin->new(); },
    );

has 'db' => (is => 'ro', isa => 'QVD::DB',
		default => sub { return QVD::DB->new(); },
    );

# status 1 means Ok, and 0 means error, detail in error_msg 
has 'status' => (is => 'ro', isa => 'Int', default => 1 );
    
has 'error_msg' => (is => 'ro', isa => 'Str', default => undef );
    

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
    my ($self, $msg) = @_;
    $self->{status} = 0;
    $self->{error_msg} = $msg;
    $self->log->error($msg);
} 

sub host_add {
    my ($self, $name, $address) = @_;
    my $result;
    
    $self->reset_status;
 
# old API   
#    if (!eval{$result = $self->admin->cmd_host_add("name=$name", "address=$address"); 1}) {

    if (!eval{$result = $self->admin->cmd_host_add(name=>$name, address=>$address); 1}) {
	$self->set_error($@);
    } 
    
    return $result;   
}

sub host_list {
    my ($self, $filter) = @_;
    
    $self->reset_status;
    my $rs = $self->db->resultset('Host');
    return [$rs->search];
        
    #my @var = map { { id => $_->id, name => $_->name, address => $_->address } } ;

}

sub host_del {
    my ($self, $id) = @_;
    my $result;
    
    $self->reset_status;
    
    if (!eval{
	    $self->admin->set_filter("id=$id");
	    $result = $self->admin->cmd_host_del;
	    1
	    }) {
	$self->set_error($@);
    } 
    
    return $result;   
}


=head 2 build_form_error_msg

Simple method that receives as input a Data::FormValidator::Results object
and returns a simple string with errors

=cut
sub build_form_error_msg {
    my ($self, $results) = @_;
    my $result_msg = '';
    if ( $results->has_missing ) {
	for my $f ( $results->missing ) {
	    $result_msg .= "$f is missing<br>\n";
	}
    }

    # Print the name of invalid fields
    if ( $results->has_invalid ) {
	for my $f ( $results->invalid ) {
	    $result_msg .= "$f is invalid: ".$results->invalid($f)." <br>\n";
	}
    }
    
    # Print unknown fields
    if ( $results->has_unknown ) {
	for my $f ( $results->unknown ) {
	    $result_msg .= "$f is unknown<br>\n";
	}
    }
    return $result_msg;
}
=head1 NAME

QVD::Admin::Web::Model::QVD::Admin::Web - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Nito Martinez,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
