use strict;
use warnings;
use Test::More qw(no_plan);
#use Test::More tests => 2;
use HTTP::Headers;
use HTTP::Request::Common;

BEGIN { use_ok 'Catalyst::Test', 'QVD::Admin::Web' }

my $request = GET('/hosts/list');
my $response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/Listado de hosts/, "Check for listado de hosts");


# Add a host form
$request = GET('/hosts/add');
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/adir host/, "Check for listado de hosts");

# Add a host
$request = POST(
    '/hosts/add_submit',
    'Content-Type' => 'form-data',
    'Content' => [
	'name' => 'testhostname1234',
	'address' => '127.0.0.1',
    ]);
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/adido correctamente con id/, "Check for add de hosts");
like( $response->content, qr/testhostname1234/, "Check for hostname testhostname1234");
my $id;
if ($response->content =~ /adido correctamente con id (\d+)/) {
   $id = $1;
}

# Delete a host
$request = POST(
    '/hosts/del_submit',
    'Content-Type' => 'form-data',
    'Content' => [
	'id' => $id
    ]);
$response = request($request);
ok( $response->is_success, 'Request should succeed' );
is( $response->content_type, 'text/html', "Check for html content");
like( $response->content, qr/eliminado correctamente/, "Check for eliminado de host");
