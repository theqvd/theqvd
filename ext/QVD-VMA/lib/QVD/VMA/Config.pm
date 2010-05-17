# this package is named QVD::VMA::Config but it supplants QVD::Config;

package QVD::Config;
$INC{QVD/Config.pm} = $INC{QVD/VMA/Config.pm};

use strict;
use warnings;

use Config::Properties;

use Exporter qw/import/;
our @EXPORT = qw(core_cfg core_cfg_all cfg);

my $defaults = Config::Properties->new;
$defaults->load(*DATA);

my $vma_cfg = Config::Properties->new($defaults);

open my $cfg_fh, '<', '/etc/qvd/vma.conf'
    or die "unable to read configuration file /etc/qvd/vma.conf'\n";
$vma_cfg->load($cfg_fh);
close $cfg_fh;

sub core_cfg {
    my $value = $vma_cfg->requireProperty(@_);
    $value =~ s/\$\{(.*?)\}/core_cfg($1)/ge;
    $value;
}

sub core_cfg_all {
    map { $_ => vma_cfg($_) } $vma_cfg->propertyNames
}

*cfg = \&core_cfg;

1;

__DATA__

path.run = /var/run/qvd
path.log = /var/log

log.filename = ${path.log}/qvd-vma.log
log.level = INFO

vma.pid_file = /var/run/qvd/vma.pid
vma.as_user = root

command.nxagent = nxagent
