package QVD::Test::AdminCLI;
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
use JSON;

sub check_environment : Test(startup => 2) {
    # FIXME check that node is running rather than if it can be executed
    my $noded_executable = 'QVD-Test/bin/qvd-noded.sh';

    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $noded_executable,		'QVD node installation');
}

sub main_test : Test {
    my $self = shift;
    my @tests = qw(user_add user_list_with_filter user_login_with_httpc
    user_passwd user_del osi_add vm_add vm_edit vm_del vm_delete_on_user_delete
    vm_start osi_del);
    foreach my $test (@tests) {
	$self->{adm} = new QVD::Test::Mock::AdminCLI(1);
	$self->$test;
    }
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

sub user_add {
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

sub user_list_with_filter {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('login=qvd0');
    $adm->cmd_user_list();
    my @user_list = map { $_->[1] } @{$adm->table_body};
    is_deeply(\@user_list, ['qvd0'], 'Check user list with filter');
}

sub user_login_with_httpc {
    my $self = shift;
    is($self->_check_login(qvd0=>'qvd'), 200,	'Check user qvd0 login');
    is($self->_check_login(xvd0=>'qvd'), 200,	'Check user xvd0 login');
}

sub user_passwd {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_mock_password('xvd0');
    $adm->cmd_user_passwd('xvd0');
    is($self->_check_login(xvd0=>'xvd0'), 200,	'Check login after password change');
    is($self->_check_login(qvd0=>'qvd'), 200,	'Check user qvd0 login');
}

sub user_del {
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
    my $response_code = 0;
    eval {
	my $httpc = QVD::HTTPC->new('localhost:8443',SSL=>1,SSL_verify_callback=>sub {1});
	my $auth = encode_base64("$user:$pass", '');
	$httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
	    "Accept: application/json"]);
	$response_code = ($httpc->read_http_response())[0];
    };

    $response_code
}

################################################################################
#
#
#
#	OSI and VM command tests
#
#
#
################################################################################

sub osi_add {
    my ($self) = @_;
    my $adm = $self->{adm};
    $adm->cmd_osi_add('name=qvd',
	'disk_image=/var/lib/qvd/storage/staging/ubuntu-10.04-i386.qcow2');
    $adm->cmd_osi_list();
    my %osi_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok($osi_list{qvd},				'Check creation of OSI "qvd"');
}

sub osi_del {
    my ($self) = @_;
    my $adm = $self->{adm};
    $adm->set_filter('name=qvd');
    $adm->cmd_osi_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_osi_list();
    my %osi_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(!exists$osi_list{qvd},			'Check deletion of OSI "qvd"');
}

sub vm_add {
    my $self = shift;
    my $adm = $self->{adm};
    foreach (0..9) {
	$adm->cmd_vm_add("name=vm$_", "user=qvd$_", "osi=qvd");
    }

    my $httpc = QVD::HTTPC->new('localhost:8443',SSL=>1,SSL_verify_callback=>sub {1});
    my $auth = encode_base64("qvd0:qvd", '');
    $httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
	    "Accept: application/json"]);
    my $response = from_json(($httpc->read_http_response)[3]);
    is(@$response, 1,				'Check vm list length for user qvd0');
    is($response->[0]{name}, 'vm0',		'Check creation of vm for user qvd0');
}

sub vm_edit {
    my $self = shift;
    my $adm = $self->{adm};
    # FIXME vm edit sin documentar
}

sub vm_del {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('name=vm9');
    $adm->cmd_vm_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    my %vm_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(!exists $vm_list{vm9},			'Check deletion of vm "vm9"');
}

sub vm_delete_on_user_delete {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('login=qvd0');
    $adm->cmd_user_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    my %vm_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(!exists $vm_list{vm0},			'Check deletion of vm for "qvd0"');
}

sub vm_start {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_start();

    sleep 60;
    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    my %vm_list = map { $_->[1] => $_->[5] } @{$adm->table_body};
    is($vm_list{vm1}, 'running',		'Check start of vm "vm1"');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    %vm_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(exists $vm_list{vm1},			'Check vm "vm1" still exists');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=qvd');
    $adm->cmd_osi_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_osi_list();
    my %osi_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(exists $osi_list{qvd},			'Check OSI "qvd" still exists');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_stop();

    sleep 60;
    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    %vm_list = map { $_->[1] => $_->[5] } @{$adm->table_body};
    is($vm_list{vm1}, 'stopped',		'Check stop of vm "vm1"');
}

1;
