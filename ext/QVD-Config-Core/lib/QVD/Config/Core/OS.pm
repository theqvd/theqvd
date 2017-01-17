package QVD::Config::Core::OS;

use strict;
use warnings;

sub __parse_file {
    my $fn = shift;
    if (open my $fh, '<', $fn) {
        my %h;
        while(<$fh>) {
            if (my ($k, $v, $v1) = /^(\w+)\s*=\s*(?:"([^"]*)"|(\S+))/) {
                #warn "k: $k, v: $v, v1: $v1, matched line: $_";
                my $k = uc $k;
                my $v = lc ($v // $v1);
                $h{lc $k} = lc($v // $v1);
            }
        }
        return %h;
    }
}

my %info; # cached!

sub detect_os {
    unless (%info) {
        my ($os, $version, $revision);
        if ($^O =~ /^linux/i) {
            if (my %osr = __parse_file("/etc/os-release")) {
                $os = $osr{name};
                $version = $osr{version_id};
                $revision = 0;
            }
            elsif (my %sv = __parse_file("/etc/SuSE-version")) {
                $os = 'suse';
                $version = $sv{version};
                $revision = $sv{patchlevel};
            }
        }
        elsif ($^O =~ /^mswin/) {
            $os = 'mswin';
            require Win32;
            if (my (undef, $major, $minor) = Win32::GetOSVersion()) {
                $version = $major;
                $revision = $minor;
            }
        }

        warn "Operating system not detected correctly"
            unless defined $os and defined $version and defined $revision;

        $info{os}       = $os       // 'unknown';
        $info{version}  = $version  // '0';
        $info{revision} = $revision // '0';
    }
    return %info;
}

1;
