package QVD::API::ConfigClassifier;
use  5.010;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw(is_hidden_config);

# This class provides a classifier for the default configuration

my @hidden_regex = ("vma\.", "internal\.", "client\.", "database\.");

my $HIDDEN_TOKENS = sprintf('^(%s)', join("|", (@hidden_regex)));
my $EVERY_TOKEN = '.*'; # Matches everything
my $NO_TOKEN = 'a^'; # Matches nothing

# Returns 1 if the configuration key is a hidden token or
# 0 otherwise
sub is_hidden_config {
    my ($key) = @_;

    my $regex = $HIDDEN_TOKENS;

    return ($key =~ /$regex/);
}

1;
