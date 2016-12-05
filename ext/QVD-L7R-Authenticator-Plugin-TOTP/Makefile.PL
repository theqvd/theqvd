use strict;
use warnings;

use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile( NAME          => 'QVD::L7R::Authenticator::Plugin::TOTP',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION	     => '3.5'.$SUF_VERSION,
	       ABSTRACT => 'lib/QVD/L7R/Authenticator/Plugin/TOTP.pm',
	       LICENSE       => 'GPL3',
	       PREREQ_PM     => { 'Test::More'       => 0,
				  'QVD::Config'      => 0,
				  'QVD::L7R'         => 0,
				  'QVD::Log'         => 0,
                                  'Convert::Base32'  => '0.06',
                                  'Digest::HMAC'     => '1.03',
	       dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-TOTP-*' } );
