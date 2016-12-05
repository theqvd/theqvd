use strict;
use warnings;

use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME          => 'QVD::L7R::Authenticator::Plugin::TOTP',
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
    VERSION	     => '3.5'.$SUF_VERSION,
    ABSTRACT => 'lib/QVD/L7R/Authenticator/Plugin/TOTP.pm',
    LICENSE       => 'GPL3',
    PREREQ_PM     => {
        'Convert::Base32'  => '0.06',
        'Digest::HMAC_SHA1' => '1.03',
        'Image::PNG::QRCode' => 0,
        'Math::Random::MT' => 0,
        'MIME::Lite::TT' => 0,
        'Mojolicious::Plugin::and' => 0,
        'QVD::DB::Simple' => 0,
        'QVD::Config' => 0,
        'QVD::L7R::Authenticator::Plugin' => 0,
        'QVD::Log' => 0,
        'URI::Escape' => 0,
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-TOTP-*' }
);
