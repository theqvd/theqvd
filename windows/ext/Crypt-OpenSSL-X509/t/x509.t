
use Test::More tests => 49;

BEGIN { use_ok('Crypt::OpenSSL::X509') };

ok(my $x509 = Crypt::OpenSSL::X509->new_from_file('certs/vsign1.pem'), 'new_from_file()');

ok($x509->serial() eq '325033CF50D156F35C81AD655C4FC825', 'serial()');

ok($x509->fingerprint_md5() eq '51:86:E8:1F:BC:B1:C3:71:B5:18:10:DB:5F:DC:F6:20', 'fingerprint_md5()');
ok($x509->fingerprint_sha1() eq '78:E9:DD:06:50:62:4D:B9:CB:36:B5:07:67:F2:09:B8:43:BE:15:B3', 'fingerprint_sha1()');

ok($x509->exponent() eq '10001', 'exponent()');
ok($x509->pub_exponent() eq '10001', 'pub_exponent()'); # Alias

ok($x509->issuer() eq 'C=US, O=VeriSign, Inc., OU=Class 1 Public Primary Certification Authority', 'issuer()');
ok($x509->subject() eq 'C=US, O=VeriSign, Inc., OU=Class 1 Public Primary Certification Authority', 'subject()');

ok($x509->is_selfsigned(), 'is_selfsigned()');

# For some reason the hash hash changed with v1.0.0
# Verified with the openssl binary.
if (Crypt::OpenSSL::X509::OPENSSL_VERSION_NUMBER >= 0x10000000) {
  ok($x509->hash() eq '24ad0b63', 'hash()');
} else {
  ok($x509->hash() eq '2edf7016', 'hash()');
}

ok($x509 = Crypt::OpenSSL::X509->new_from_file('certs/thawte.pem'), 'new_from_file()');

ok($x509->email() eq 'server-certs@thawte.com', 'email()');

is($x509->version, '02', 'version');

is($x509->sig_alg_name, 'md5WithRSAEncryption', 'version');

is($x509->bit_length, 1024, 'bit_length()');

ok($x509->num_extensions() eq '1', 'num_extensions()');

ok($exts = $x509->extensions_by_oid(), 'extension_by_oid()');

ok($x509->has_extension_oid("2.5.29.19"), 'has_extension_oid(2.5.29.19)');

is($$exts{"2.5.29.19"}->object()->name(),"X509v3 Basic Constraints", "Extension->object()->name()");

ok($$exts{"2.5.29.19"}->is_critical(), "basic constraints is critical");
ok($$exts{"2.5.29.19"}->basicC("ca"), 'basicConstraints CA: TRUE 2.4.1');

ok($x509_b = Crypt::OpenSSL::X509->new_from_file('certs/balt.pem'), 'new_from_file()');
ok(my $exts_b = $x509_b->extensions_by_name(), "extensions_by_name()");
ok(not($$exts_b{'subjectKeyIdentifier'}->is_critical()), "subjectKeyIdentifier not critical");
my $subkeyid = (join ":", map{sprintf "%X", ord($_)} split //, $$exts_b{'subjectKeyIdentifier'}->keyid_data());
ok($subkeyid eq "E5:9D:59:30:82:47:58:CC:AC:FA:8:54:36:86:7B:3A:B5:4:4D:F0", "Extension{subjectKeyID}->keyid_data()");

ok($$exts_b{'keyUsage'}->is_critical(), "keyUsage is critical");
my %key_hash = $$exts_b{'keyUsage'}->hash_bit_string();
ok($key_hash{'Certificate Sign'}, "Extension->hash_bit_string()");

isa_ok($x509->subject_name(), "Crypt::OpenSSL::X509::Name", 'subject_name()');
isa_ok($x509->issuer_name(), "Crypt::OpenSSL::X509::Name", 'issuer_name()');
is($x509->subject_name()->as_string(), 'C=ZA, ST=Western Cape, L=Cape Town, O=Thawte Consulting cc, OU=Certification Services Division, CN=Thawte Server CA, emailAddress=server-certs@thawte.com', 'subject_name()->as_string()');
is($x509->issuer_name()->as_string(), 'C=ZA, ST=Western Cape, L=Cape Town, O=Thawte Consulting cc, OU=Certification Services Division, CN=Thawte Server CA, emailAddress=server-certs@thawte.com', 'issuer_name()->as_string()');

ok(my $subject_name_entries = $x509->subject_name()->entries(), 'subject_name()->entries()');
is(@$subject_name_entries[0]->as_string(),"C=ZA",'Name_Entry->as_string()');
is(@$subject_name_entries[2]->as_long_string(),"localityName=Cape Town",'Name_Entry->as_long_string()');
is(@$subject_name_entries[1]->type(),"ST",'Name_Entry->type');
is(@$subject_name_entries[1]->long_type(),"stateOrProvinceName",'Name_Entry->long_type');
is(@$subject_name_entries[1]->value(),"Western Cape",'Name_Entry->value');

ok($x509->subject_name()->has_entry("ST"),'Name->has_entry');
ok($x509->subject_name()->has_long_entry("stateOrProvinceName"),'Name->has_entry');
ok($x509->subject_name()->has_oid_entry("2.5.4.3"),'Name->has_oid_entry([CN])');
ok(not($x509->subject_name()->has_oid_entry("0.9.2342.19200300.100.1.25")),'not Name->has_oid_entry([DC])');
is($x509->subject_name()->get_index_by_type("ST"),1,'Name->get_index_by_type');
is($x509->subject_name()->get_index_by_long_type("localityName"),2,'Name->get_index_by_long_type');

isa_ok($x509->subject_name()->get_entry_by_type("ST"),"Crypt::OpenSSL::X509::Name_Entry",'Name->get_entry_by_type');
ok($x509->subject_name()->get_entry_by_type("ST")->is_printableString(),'Name_Entry->is_printableString');
ok(not($x509->subject_name()->get_entry_by_type("ST")->is_asn1_type(Crypt::OpenSSL::X509::V_ASN1_UTF8STRING)),'Name_Entry->is_asn1_type');

# Check new_from_string / as_string round trip.
{
  my $x509 = Crypt::OpenSSL::X509->new_from_string(
    Crypt::OpenSSL::X509->new_from_file('certs/balt.pem')->as_string(1),
  1);

  ok($x509);
  ok($x509->serial() eq '020000B9', 'serial()');
}
