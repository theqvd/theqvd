package QVD::Test::AdminCLI;
use parent qw(QVD::Test);

use lib 'lib';

use strict;
use warnings;
use Data::Dumper qw(Dumper);

use Test::More qw(no_plan);

$| = 1;

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
use Carp;

my $test_done;

sub check_environment : Test(startup => 2) {
    my $hkd_executable = '/etc/init.d/qvd-hkd';

    if ( $test_done ) {
        confess("Being called a second time!");
#    } else {
 #       confess("Being called the first time");
    }

    $test_done = 1;

    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $hkd_executable,		'QVD HKD installation');

    my $httpc = QVD::HTTPC->new('localhost:8443',SSL=>1,SSL_verify_callback=>sub {1});
    $httpc->send_http_request(GET => '/qvd/ping');
    my $response_code = ($httpc->read_http_response())[0];
    fail("QVD HKD not running (response $response_code)") if $response_code ne 200;
}

sub main_test : Test {
    my $self = shift;
    my @tests = qw(user_del_all di_del osf_del user_add user_list_with_filter user_login_with_httpc
    user_passwd user_del osf_add di_add vm_add vm_edit vm_del vm_delete_on_user_delete
    vm_start di_del osf_del config_get user_del_all);
    foreach my $test (@tests) {
        print "########## Test $test ############\n";
        eval {
        	$self->{adm} = new QVD::Test::Mock::AdminCLI(1);
	        $self->$test;
        };
        if ( $@ ) {
            warn $@;
        }
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
        eval {
	        $adm->cmd_user_add("login=qvd$i", "password=qvd");
        };
        if ( $@ ) {
            fail("Failed to create user qvd$i");
        } else {
            ok(1, "Create user qvd$i");
        }

        eval {
        	$adm->cmd_user_add("login=xvd$i", "password=qvd");
        }; 
        if ( $@ ) {
            fail("Failed to create user xvd$i");
        } else {
            ok(1, "Create user xvd$i");
        }
    }

    $adm->cmd_user_list();
    my %user_list = map { $_->[1] => 1 } @{$adm->table_body};

    for my $i (0..9) {
        ok($user_list{"qvd$i"},	"Verify: User qvd$i was created");
        ok($user_list{"xvd$i"},	"Verify: User xvd$i was created");
    }
}

sub user_del_all {
    my $self = shift;
    my $adm = $self->{adm};

    $adm->set_filter('login=qvd*');
    $adm->cmd_user_del();

    $adm->cmd_user_list();
    my %user_list = map { $_->[1] => 1 } @{$adm->table_body};

    for my $i (0..9) {
        ok(!exists $user_list{qvd0},	'User qvd0 was deleted');
        ok(!exists $user_list{xvd0},	'User xvd0 was deleted');
    }
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
    $adm->cmd_user_passwd('user=xvd0');
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

sub osf_add {
    my ($self) = @_;
    my $adm = $self->{adm};
    $adm->cmd_osf_add('name=qvd');
#	'disk_image=/var/lib/qvd/storage/staging/ubuntu-10.04-i386.qcow2');
    $adm->cmd_osf_list();
    my %osf_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok($osf_list{qvd},				'Check creation of OSF "qvd"');
}

sub osf_del {
    my ($self) = @_;
    my $adm = $self->{adm};
    $adm->set_filter('name=vm*');
    $adm->cmd_vm_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=qvd');
    $adm->cmd_osf_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_osf_list();
    my %osf_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(!exists$osf_list{qvd},			'Check deletion of OSF "qvd"');
}

sub di_add {
    my ($self) = @_;
    my $adm = $self->{adm};
    my $id = $self->get_osf_id('qvd');

    $adm->cmd_di_add("osf_id=$id", 'path=/var/lib/qvd/storage/staging/2-test.tgz');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_di_list();
    my %osf_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok($osf_list{$id},				'Check creation of OSF "qvd"');
}

sub di_del {
    my ($self) = @_;
    my $adm = $self->{adm};
    my $id = $self->get_osf_id('qvd');

    if ( $id ) {
        $adm->set_filter("osf_id=$id");
        $adm->cmd_di_del();
    }

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_di_list();
    my %di_list = map { $_->[1] => 1 } @{$adm->table_body};
    print "DI list:\n" .  Dumper(\%di_list);
    ok(!exists$di_list{$id},			'Check deletion of DI of OSF "qvd"');
}


sub vm_add {
    my $self = shift;
    my $adm = $self->{adm};
    foreach (0..9) {
	    $adm->cmd_vm_add("name=vm$_", "user=qvd$_", "osf=qvd");
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

    my %vm_list;

    wait_for_col_value( vm => 'vm1', col => 'State', value => 'running', message => 'Check start of vm "vm1"', timeout => 300);

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_vm_list();
    %vm_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(exists $vm_list{vm1},			'Check vm del fail with vm running');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=qvd');
    $adm->cmd_osf_del();

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_osf_list();
    my %osf_list = map { $_->[1] => 1 } @{$adm->table_body};
    ok(exists $osf_list{qvd},			'Check osf del fail with VMs defined');

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_block();

    wait_for_col_value( vm => 'vm1', col => 'Blocked', value => '1', message => 'Wait for vm1 to become blocked', timeout => 30);

    $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->set_filter('name=vm1');
    $adm->cmd_vm_stop();

    wait_for_col_value( vm => 'vm1', col => 'State', value => 'stopped', message => 'Check stop of vm "vm1"', timeout => 300);
    
}

sub config_get {
    my $self = shift;
    my $adm = $self->{adm};
    $adm->cmd_config_get;
}

sub get_osf_id {
    my ($self, $osf) = @_;
    
    my $adm = new QVD::Test::Mock::AdminCLI(1);
    $adm->cmd_osf_list();
    my %osf_list = map { $_->[1] => $_ } @{$adm->table_body};
    return $osf_list{qvd}->[0];
}




sub wait_for_col_value {
    my %args = @_;

    die "Missing arguments" unless ( $args{vm} && $args{col} && $args{value} && $args{message} && $args{timeout} );

    my $adm = new QVD::Test::Mock::AdminCLI(1);
    my $time = 0;

    while(1) {
        $adm->cmd_vm_list();
        my %vm_list = $adm->table_column("Name", $args{col});

        if ( !exists $vm_list{ $args{vm} } ) {
            die "VM " . $args{vm} . " doesn't exist. VMs: " . join(', ', keys %vm_list);
        }

        if ( $time++ > $args{timeout} || ( $vm_list{$args{vm}} eq  $args{value} ) ) {
            print "\n";
            is($vm_list{$args{vm}}, $args{value}, $args{message});
            last;
        }
       
        print ".";
        sleep(1); 
    }

}

1;
