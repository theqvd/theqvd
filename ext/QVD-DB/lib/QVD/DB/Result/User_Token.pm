package QVD::DB::Result::User_Token;
use base qw/DBIx::Class/;
use strict;
use warnings;
use QVD::DB::Simple qw(db rs);
use Session::Token;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_tokens');
__PACKAGE__->add_columns(
    token      => { data_type => 'varchar(256)' },
    user_id    => { data_type => 'integer' },
    vm_id      => { data_type => 'integer', is_nullable => 1 },
    expiration => { data_type => 'integer' }
);

__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');
__PACKAGE__->belongs_to(vm  => 'QVD::DB::Result::VM',  'vm_id');

__PACKAGE__->set_primary_key('token');

sub is_expired {
    my $self = shift;
    return time > $self->expiration;
}

sub expire {
    my $self = shift;

    $self->update({expiration => 0});

    return $self;
}

1;