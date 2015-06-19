package QVD::Admin4::REST::Statistics::Request;
use strict;
use warnings;
use Moo;
use QVD::Admin4::Exception;
use QVD::Admin4::DBConfigProvider;

has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type for attribute json_wrapper" 
						 unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; }, required => 1;


has 'administrator', is => 'ro', isa => sub { die "Invalid type for attribute administrator" 
						  unless ref(+shift) eq 'QVD::DB::Result::Administrator'; };

my $ACTIONS =
{
    'qvd_objects_statistics' => { users_total_number => { acls => [qr/^user\.stats/] },
				  blocked_users_total_number => { acls => [qr/^user\.stats\.blocked$/]},
				  vms_total_number => { acls => [qr/^vm\.stats/] },
				  blocked_vms_total_number => { acls => [qr/^vm\.stats\.blocked$/] },
				  running_vms_total_number => { acls => [qr/^vm\.stats\.running-vms$/] },
				  hosts_total_number => { acls => [qr/^host\.stats/] },
				  blocked_hosts_total_number => { acls => [qr/^host\.stats\.blocked$/] },
				  running_hosts_total_number => { acls => [qr/^host\.stats\.running-hosts$/] },
				  osfs_total_number => { acls => [qr/^osf\.stats/] },
				  dis_total_number => { acls => [qr/^di\.stats/] },
				  blocked_dis_total_number => { acls => [qr/^di\.stats\.blocked$/] },
				  vms_with_expitarion_date => { acls => [qr/^vm\.stats\.close-to-expire$/] },
				  the_most_populated_hosts => { acls => [qr/^host\.stats\.top-hosts-most-vms$/] }},
				  connected_users_count => { acls => [qr/^user\.stats\.connected-users$/]},
};


sub nested_actions
{
    my $self = shift;
    my $matrix_action = $self->json_wrapper->action //;
    my @nested_actions = 
	grep { $self->administrator->re_is_allowed_to(@{$ACTION->{$matrix_action}->{$_}->{acls}}) }
	keys %{$ACTION->{$matrix_action}};
    \@nested_actions;
}


1;
