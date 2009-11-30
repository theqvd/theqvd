package QVD::Admin::Web::Model::QVD::Admin::Web;

use Moose;
use QVD::DB;
use QVD::Admin;
extends 'Catalyst::Model';

has 'version' => (is => 'ro', isa => 'Str',
    default => sub { return "$QVD::Admin::Web::VERSION";  }
    );

has 'admin' => (is => 'ro', isa => 'QVD::Admin',
		default => sub { return QVD::Admin->new(); },
    );

has 'db' => (is => 'ro', isa => 'QVD::DB',
		default => sub { return QVD::DB->new(); },
    );
    

#sub BUILD {
#    my $self = shift;
#    $self->quiet(1);
#}

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

1;
