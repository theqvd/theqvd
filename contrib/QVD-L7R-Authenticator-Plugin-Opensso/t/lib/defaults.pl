#!perl
package QVD::Test::Defaults;
use File::Temp;

# Please define the OpenSSO test attributes
#our $test_authenticate_uri;
#our $test_authorize_uri;
#our $test_target_uri;
#our $test_user;
#our $test_user_roles;
#our $test_pass;
#our $test_dbhost;
#our $test_dbname;
#our $test_dbuser;
#our $test_dbpass;

# Example:
our $test_authenticate_uri = 'http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate';
our $test_authorize_uri = 'http://ptemsso.int.qindel.com:8080/opensso/identity/authorize';
our $test_target_uri = 'http://ptemsso.int.qindel.com:8080/myqvd';
our $test_user = 'qvdtu';
our $test_user_roles = 'Cajero:Ejecutivo';
our $test_pass = 'qvd123';
our $test_dbhost = '127.0.0.1';
our $test_dbname = 'QVDDatabase';
our $test_dbuser = 'QVDUser';
our $test_dbpass = 'qvd';

# Subroutines

sub createTestConfig {
    my $fh = File::Temp->new(UNLINK => 0);
    my $filename = $fh->filename;
    print $fh <<EOF;
auth.opensso.rest_auth_uri = $test_authenticate_uri
auth.opensso.rest_authorize_uri = $test_authorize_uri
auth.opensso.target_uri = $test_target_uri
database.host = $test_dbhost
database.name = $test_dbname;
database.user = $test_dbuser
database.password = $test_dbpass
log.level = DEBUG
EOF

    close $fh;

    return $filename;
}

1;
