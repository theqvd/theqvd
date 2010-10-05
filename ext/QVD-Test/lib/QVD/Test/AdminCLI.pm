package QVD::Test::SingleServer;
use parent qw(QVD::Test);

use lib::glob '*/lib';

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    $QVD::Config::USE_DB = 0;
}

use QVD::Config;
use QVD::DB::Simple;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;
use QVD::Test::Mock::AdminCLI;
use MIME::Base64 qw(encode_base64);

sub check_environment : Test(startup => 2) {
    # FIXME check that node is running rather than if it can be executed
    my $noded_executable = 'QVD-Test/bin/qvd-noded.sh';

    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $noded_executable,		'QVD node installation');
}

sub create_adm : Test(setup) {
    my $self = shift;
    $self->{adm} = new QVD::Test::Mock::AdminCLI(1);
}


################################################################################
#
#
#
#	User command tests
#
#
#
################################################################################

sub aa_user_add : Test(2) {
    my $self = shift;
    my $adm = $self->{adm};
    for my $i (0..9) {
	$adm->cmd_user_add("login=qvd$i", "password=qvd");
	$adm->cmd_user_add("login=xvd$i", "password=qvd");
    }
    $adm->cmd_user_list();
    my %user_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok($user_list{qvd0},	'User qvd0 was created');
    ok($user_list{xvd0},	'User xvd0 was created');
}

sub aa_user_list_with_filter : Test(1) {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('login=qvd0');
    $adm->cmd_user_list();
    my @user_list = map { $_->[1] } @{$adm->table_body};
    is_deeply(\@user_list, ['qvd0'], 'Check user list with filter');
}

sub aa_user_login_with_httpc : Test(2) {
    my $self = shift;
    is($self->_check_login(qvd0=>'qvd'), 200,	'Check user qvd0 login');
    is($self->_check_login(xvd0=>'qvd'), 200,	'Check user xvd0 login');
}

sub aa_user_passwd : Test(2) {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_mock_password('xvd0');
    $adm->cmd_user_passwd('xvd0');
    is($self->_check_login(xvd0=>'xvd0'), 200,	'Check login after password change');
    is($self->_check_login(qvd0=>'qvd'), 200,	'Check user qvd0 login');
}

sub ab_user_del : Test(3) {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('login=xvd*');
    $adm->cmd_user_del();
    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_user_list();
    my %user_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(!exists $user_list{xvd0},		'Check user xvd0 was deleted');
    ok($user_list{qvd0},			'Check user qvd0 still exists');
    is($self->_check_login(xvd0=>'xvd0'), 401,	'Check login after account deletion');
}

sub _check_login {
    my ($self, $user, $pass) = @_;
    my $httpc = QVD::HTTPC->new('localhost:8443', SSL => 1, SSL_verify_callback => sub {1});
    die "connect" if (!$httpc);
    my $auth = encode_base64("$user:$pass", '');
    $httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
								    "Accept: application/json"]);
    return ($httpc->read_http_response())[0];
}

################################################################################
#
#
#
#	VM command tests
#
#
#
################################################################################

sub ba_alta_osi : Test {
    my ($self) = @_;
    my $adm = $self->{adm};
    $adm->cmd_osi_add('name=qvd',
	'disk_image=/var/lib/qvd/storage/staging/ubuntu-10.04-i386.qcow2');
}

1;
