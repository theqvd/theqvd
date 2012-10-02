
use Test::More tests => 11;
use Encode;

binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# use Devel::Peek;

my $debug = 0;

BEGIN { use_ok('Crypt::OpenSSL::X509') };

my ($x509, $sub);

######  first a pure ascii cert #####

ok($x509 = Crypt::OpenSSL::X509->new_from_file('certs/vsign1.pem'), 'new_from_file()');
$sub = $x509->subject();

Dump($sub) if ($debug);
ok(! utf8::is_utf8($sub), "ascii subject should not be an utf8 string");


######  then a hardcore UTF8 cert #####

ok($x509 = Crypt::OpenSSL::X509->new_from_file('certs/turk.pem'), 'new_from_file()');

ok($x509->serial() eq '01', 'serial()');
ok($x509->fingerprint_md5() eq '37:A5:6E:D4:B1:25:84:97:B7:FD:56:15:7A:F9:A2:00', 'fingerprint_md5()');

$sub = $x509->subject();
Dump($sub) if ($debug);
my $sub_ok = "CN=T\x{dc}RKTRUST Elektronik Sertifika Hizmet Sa\x{11f}lay\x{131}c\x{131}s\x{131}, C=TR, L=Ankara, O=T\x{dc}RKTRUST Bilgi \x{130}leti\x{15f}im ve Bili\x{15f}im G\x{fc}venli\x{11f}i Hizmetleri A.\x{15e}. (c) Kas\x{131}m 2005";

ok(utf8::is_utf8($sub), "subject is really an utf8 string");
is($sub, $sub_ok, "utf8 subject as expected");


######  and a broken UTF8 cert #####

# OpenSSL v1.0.0 (and higher?) fails to read this cert.
SKIP: {
  skip "OpenSSL v1.0.0 can't read broken certs.", 3 if Crypt::OpenSSL::X509::OPENSSL_VERSION_NUMBER >= 0x10000000;

  ok($x509 = Crypt::OpenSSL::X509->new_from_file('certs/broken-utf8.pem'), 'new_from_file()');
  $sub = $x509->subject();
  Dump($sub) if ($debug);

  ok(utf8::is_utf8($sub), "subject is utf8");
  is($sub, "C=PL, ST=mazowieckie, L=Warszawa, O=D.A.S. Towarzystwo Ubezpieczen Ochrony Prawnej S.A., OU=Dzi\x{fffd} Informatyki, CN=das.pl", "utf8 subject as expected");
};

0;
