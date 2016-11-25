package QVD::API::REST::Request::Config_Field;

use strict;
use warnings;
use Moo;
use QVD::Config;
use QVD::Config::Core qw(core_cfg_unmangled);
use QVD::DB::Simple;
use QVD::API::ConfigClassifier;


has 'key', is => 'ro', isa => sub { die "Invalid type for attribute key" unless ref(+shift) eq ''; }, 
    required => 1;

has 'tenant_id', is => 'ro', isa => sub { die "Invalid type for attribute tenant_id" unless ref(+shift) eq ''; }, 
    required => 1;

# Public methods

sub BUILD
{
    my $self = shift;
}

sub operative_value {
    my $self = shift;
    return cfg($self->key, $self->tenant_id);
}

sub default_value {
    my $self = shift;
    return _get_default_cfg_value($self->key, $self->tenant_id);
}

sub is_default {
    my $self = shift;
    return _is_cfg_key_in_database($self->key, $self->tenant_id) ? 0 : 1,
}

sub is_hidden {
    my $self = shift;
    return QVD::API::ConfigClassifier::is_hidden_config($self->key);
}

# Private methods

sub _get_default_cfg_value {
    my $key = shift;
    my $tenant = shift // -1;

    if ($tenant != -1) {
        my $row = QVD::DB::Simple::rs( 'Config' )->search( { tenant_id => -1, key => $key } )->first();
        return $row->value if defined( $row );
    }

    my $value = core_cfg_unmangled($key);
    return $value if defined($value);

    return undef;
}

sub _is_cfg_key_in_database {
    my $key = shift;
    my $tenant = shift // -1;
    
    my $row = QVD::DB::Simple::rs( 'Config' )->search( { tenant_id => $tenant, key => $key } )->first();
    return defined( $row );
}

1;
