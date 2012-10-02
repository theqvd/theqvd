use ExtUtils::MakeMaker;

WriteMakefile( NAME => 'Crypt::OpenSSL::X509',
               VERSION_FROM => 'X509.pm',
               ABSTRACT_FROM => 'X509.pm',
               LIBS => '-L. -lcrypto'
             );
