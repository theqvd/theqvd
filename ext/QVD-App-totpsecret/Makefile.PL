use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'QVD::App::totpsecret',
    AUTHOR           => q{QVD Team <qvd@qindel.com>},
    VERSION          => '4.0.0',
    ABSTRACT         => 'Provision tool for QVD totp module',
    LICENSE          => 'gpl_3',
    PL_FILES         => {},
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'QVD::Config' => 0,
        'Convert::Base32'  => '0.06',
        'Digest::HMAC_SHA1' => '1.03',
        'Image::PNG::QRCode' => 0,
        'Math::Random::MT' => 0,
        'MIME::Lite::TT' => 0,
        'Mojo::UserAgent' => 0,
        'URI::Escape' => 0,
    },
    EXE_FILES     => [ qw (
        bin/qvd-make-totp-secret.pl
    )] ,
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'QVD-App-totpsecret-*' },
);
