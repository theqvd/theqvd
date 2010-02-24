package QVD::ParallelNet::Constants;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( error => [qw(NETPAR_OK)] );
$EXPORT_TAGS{all} = [ map @{$EXPORT_TAGS{$_}}, keys %EXPORT_TAGS ];
our @EXPORT_OK = @{$EXPORT_TAGS{all}};

use constant NETPAR_OK => 0;

1;
