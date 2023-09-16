package QVD::Config::Core::OS;

use strict;
use warnings;

my $os_release_path = $ENV{QVD_OS_RELEASE_PATH} || '/etc/os-release';
my $suse_version_path = $ENV{QVD_SUSE_VERSION_PATH} || '/etc/SuSE-version';

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
            if (my %osr = __parse_file($os_release_path)) {
                $os = $osr{name};
                if ($osr{id} eq 'ubuntu') {
                    $version = $osr{version_id};
                    $revision = ($osr{version} =~ /^\s*$version\.(\d+)/) ? $1 : 0;
                }
                elsif (grep { $osr{id} eq $_ } qw{rhel rocky}) {
                    $os = $osr{id};
                    ($version, $revision) = split /\./, $osr{version_id};
                }
                else {
                    if ($osr{version_id} =~ /^(\d+)(?:\.(\d+))?/) {
                        $version = $1;
                        $revision = $2 // '0';
                    }
                }
            }
            elsif (my %sv = __parse_file($suse_version_path)) {
                $os = 'suse';
                $version = $sv{version};
                $revision = $sv{patchlevel};
            }
        }
        elsif ($^O =~ /^mswin/i) {
            $os = 'mswin';
            require Win32;
            if (my (undef, $major, $minor) = Win32::GetOSVersion()) {
                $version = $major;
                $revision = $minor;
            }
        } elsif ( $^O =~ /darwin/i ) {
            my $major;
            my @vers = `/usr/bin/sw_vers`;
            die "Failed to run /usr/bin/sw_vers, return code $? $!" if ($?);
            chomp @vers;

            foreach my $line (@vers) {
                if ( $line =~ /^ProductVersion:\s*(.*)$/ ) {
                    ($major, $version, $revision) = split(/\./, $1);
                    last;
		}
            }

            if ( !defined $major) {
                die "Failed to parse version info. Output was: " . join("\n", @vers);
            } elsif ( $major == 10 ) {
                $os = "osx";
            } else {
                die "Running on Darwin, but not OSX. Unrecognized major version '$major'. Please fix."
            }
        }

        defined and s/\s+Linux$//i for ($os);
        defined and s/\s+/_/g for ($os, $version, $revision);

        warn "Operating system not detected correctly"
            unless defined $os and defined $version and defined $revision;

        $info{os}       = $os       // 'unknown';
        $info{version}  = $version  // '0';
        $info{revision} = $revision // '0';
    }
    return %info;
}

1;
