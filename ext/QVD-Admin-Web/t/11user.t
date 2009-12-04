use strict;
use warnings;
use Test::More qw(no_plan);
#use Test::More tests => 2;
use HTTP::Headers;
use HTTP::Request::Common;
use LWP::UserAgent;
use Data::Dumper;

BEGIN { use_ok 'Catalyst::Test', 'QVD::Admin::Web' }

my $request = GET('/users/list');
my $response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/Usuarios/, "Check for listado de usuarios");


# Add a host form
$request = GET('/users/add');
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/Nuevo/, "Check for Add form");

# Invalid ip
$response = request POST '/hosts/add', [
        '_submitted_add' => "1",
        '_submit' => 'addhost',
	'name' => 'testhostname1231',
	'address' => '127.0.0.x',
    ];

ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "Check no response_success in add hosts. Invalid address");

# Invalid address
$response = request POST '/hosts/add',
    [
     '_submitted_add' => '1',
     '_submit' => 'addhost',
     'name' => '',
     'address' => '127.0.0.x',
    ];
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "Check no response_success in add hosts. Invalid name");

# No address parameter
$response = request POST '/hosts/add',
    [
     '_submitted_add' => '1',
     '_submit' => 'addhost',
     'name' => 'testhostname1232',
    ];
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "Check no response_success in add hosts. Invalid address");

# No name parameter
$response = request POST '/hosts/add',
    [
     '_submitted_add' => '1',
     '_submit' => 'addhost',
     'address' => '127.0.0.1',
    ];

ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "Check no response_success in add hosts. Missing address");


# Add a host
$response = request POST '/hosts/add',
    [
     '_submitted_add' => '1',
     '_submit' => 'addhost',
     'name' => 'testhostname1234',
     'address' => '10.0.0.1',
    ];

ok( $response->is_redirect, 'Request returns redirect' );
my $uri = URI->new($response->header('location'));
is($uri->path, '/hosts/list', 'Redirect should be /hosts/list');
my $cookie = $response->header('set-cookie');
$request = HTTP::Request->new(GET => $uri->path);
$request -> header(cookie=>$cookie);
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/testhostname1234/, "Check for hostname testhostname1234");
like( $response->content, qr/response_success/, "Check for hostname response_success");
my $id;
if ($response->content =~ /adido correctamente con id (\d+)/) {
   $id = $1;
}

# Delete a host
$response = request POST '/hosts/del',
    [
     'id' => $id
    ];
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "Check for eliminado de host");

# Delete an invalid id
# id is the max value of integer in the database +1
$response = POST '/hosts/del',
    [
     'id' => 2147483648
    ];
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
unlike( $response->content, qr/response_success/, "CCheck for response_error in add hosts");
