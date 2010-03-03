package QVD::VMA::Config;

use strict;
use warnings;
use Carp;
use Config::Tiny;

use Exporter qw/import/;
our @EXPORT = qw(cfg);

my $ini = Config::Tiny->read("vma.ini")
    or croak "Unable to read configuration file 'vma.ini'";

sub cfg {
    my ($key, $default) = @_;
    my @key = split /\./, $key;
    $ini->{$key[0]}{$key[1]} // $default;
}

1;

__END__
