#!perl
package QVD::Test::Defaults;
use File::Temp;

# Please define the test SMTP attributes
#our $test_smtphost;
#our $test_smtpto;
#our $test_smtpfrom;
#our $test_smtpsubject;
#our $test_smtpdebug;
#our $test_dbhost;
#our $test_dbname;
#our $test_dbuser;
#our $test_dbpass;

# Example:
our $test_user = 'nito';
our $test_pass = 'nito';
our $test_smtphost = 'smtp.qindel.com';
our $test_smtpto = 'nito@qindel.es';
our $test_smtpfrom = 'nito@deiro.com';
our $test_smtpsubject = '';
our $test_smtpdebug = 1;
our $test_dbhost = '127.0.0.1';
our $test_dbname = 'QVDDatabase';
our $test_dbuser = 'QVDUser';
our $test_dbpass = 'qvd';


# Subroutines

sub createTestConfig {
    my $fh = File::Temp->new(UNLINK => 0);
    my $filename = $fh->filename;
    print $fh <<EOF;
auth.notifybymail.smtphost = $test_smtphost
auth.notifybymail.smtpto = $test_smtpto
auth.notifybymail.smtpfrom = $test_smtpfrom
auth.notifybymail.smtpsubject = $test_smtpsubject
auth.notifybymail.smtpdebug = $test_smtpdebug
database.host = $test_dbhost
database.name = $test_dbname
database.user = $test_dbuser
database.password = $test_dbpass
EOF

    close $fh;

    return $filename;
}

1;
