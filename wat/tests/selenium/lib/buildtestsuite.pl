use strict;
use warnings;

my $filename = $ARGV[0];

# Open firefox IDE suite file

open(my $fh, '<:encoding(UTF-8)', $filename)
or die "Could not open file '$filename' $!";


# Parse case files to get perl case files

my @caseplfiles;

while (my $row = <$fh>) {
    chomp $row;
    $row =~ /<a.*href="\.\.\/([\s\S]+?)".*>/;
    if (defined $1) {
        my $caseplfile = 'pl-' . $1 . '.pl';
        push @caseplfiles, $caseplfile;
    }
}


# Build suite perl executable

print `cat lib/connection.pl`;

foreach my $caseplfile (@caseplfiles) {
    print `cat $caseplfile`;
}

