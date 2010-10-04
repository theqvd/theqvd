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

my $node;
my $noded_executable;

sub check_environment : Test(startup => 2) {
    # FIXME better to use something derived from $0
    $noded_executable = 'QVD-Test/bin/qvd-noded.sh';

    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $noded_executable,		'QVD node installation');
}

sub user_add : Test(2) {
    my $adm = new QVD::Test::Mock::AdminCLI;
    my $i;
    for my $i (0..9) {
	$adm->cmd_user_add("login=qvd$i", "password=qvd");
	$adm->cmd_user_add("login=xvd$i", "password=qvd");
    }
    $adm->cmd_user_list();
    my $user_list = $adm->table_body;
    use Data::Dumper;
    print Dumper $user_list;
}

sub _check_connect {
    my $httpc = QVD::HTTPC->new('localhost:8443', SSL => 1, SSL_verify_callback => sub {1});
    die "connect" if (!$httpc);
    my $auth = encode_base64('qvd:qvd', '');
    $httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
								    "Accept: application/json"]);
    return ($httpc->read_http_response())[0];
}

1;
