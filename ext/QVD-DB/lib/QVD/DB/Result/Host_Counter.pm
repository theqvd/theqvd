package QVD::DB::Result::Host_Counter;

use strict;
use warnings;

use parent qw(DBIx::Class);

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_counters');
__PACKAGE__->add_columns(
    host_id        => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    http_requests  => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    auth_attempts  => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    auth_ok        => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    nx_attempts    => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    nx_ok          => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    short_sessions => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
);
__PACKAGE__->set_primary_key('host_id');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');


sub _incr_field {
    my ($host, $field) = @_;

    for (1..5) {
        eval { $host->update ({ $field => 1 + $host->$field }); };
        last unless $@;
        if ($@ =~ /could not serialize access due to concurrent update/) {
            select undef, undef, undef, 0.2 + rand 0.3;
        }
    }
}

sub incr_http_requests  { shift->_incr_field ('http_requests'); }
sub incr_auth_attempts  { shift->_incr_field ('auth_attempts'); }
sub incr_auth_ok        { shift->_incr_field ('auth_ok'); }
sub incr_nx_attempts    { shift->_incr_field ('nx_attempts'); }
sub incr_nx_ok          { shift->_incr_field ('nx_ok'); }
sub incr_short_sessions { shift->_incr_field ('short_sessions'); }

1;
