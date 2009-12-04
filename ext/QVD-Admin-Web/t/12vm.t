use strict;
use warnings;
use Test::More qw(no_plan);
#use Test::More tests => 2;
use HTTP::Headers;
use HTTP::Request::Common;
use Data::Dumper;

BEGIN { use_ok 'Catalyst::Test', 'QVD::Admin::Web' }

my $request = GET('/vm/list');
my $response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/M.*?quinas virtuales/, "Check for listado de vm");


# Add a vm with all the elements
$response = request POST '/vm/add',
    [
     'vm_name' => 'testvm123',
     'user_id' => '1',
     'osi_id' => '1',
     'vm_ip' => '10.0.0.1',
    ];

ok( $response->is_redirect, 'Request returns redirect' );
my $uri = URI->new($response->header('location'));
is($uri->path, '/vm/list', 'Redirect should be /vm/list');
my $cookie = $response->header('set-cookie');
$request = HTTP::Request->new(GET => $uri->path);
$request -> header(cookie=>$cookie);
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/testvm123/, "Check for hostname testhostname1234");
like( $response->content, qr/response_success/, "Check for hostname response_success");
my $id;
if ($response->content =~ /adido correctamente con id (\d+)/) {
   $id = $1;
}


