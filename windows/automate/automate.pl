#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use YAML;
use Path::Tiny;
use Getopt::Long;
use Log::Any::Adapter;
use HTTP::Tiny;
use Win32::ShellQuote qw(quote_system_string quote_native);

my $this_path = path($0)->realpath->parent;
my $cfg_fn = $this_path->child('automate.yaml');
my $log_fn = $this_path->child('log.txt');
my $log_level = 'info';
my $wd;
my @skip;

GetOptions('config|cfg|f=s'   => \$cfg_fn,
           'log-level|ll|l=s' => \$log_level,
           'workdir|wd|w=s'   => \$wd,
           'skip|K=s'         => \@skip)
    or die "Error in command line arguments\n";

Log::Any::Adapter->set(File => $log_fn, log_level => $log_level);
my $log = Log::Any->get_logger;

sub logdie {
    my $msg = join ': ', @_;
    $log->fatal($msg);
    die "$msg\n";
}

$wd = ($wd ? path($wd) : Path::Tiny->tempdir);
$log->info("Working dir: $wd");

my $cfg = YAML::LoadFile($cfg_fn)
    or logdie($cfg_fn, "Loading configuration file failed");

my %skip = map { lc($_) => 1 } @skip;

my $ua = HTTP::Tiny->new();

install_msys2();
install_strawberry_perl();
install_cygwin();

exit(0);

sub posix_quote {
    state $noquote_class = '.\\w/\\-@,:';
    join(' ',
         map {
             my $quoted = join '',
                 map { ( m|\A'\z|                  ? "\\'"    :
                         m|\A'|                    ? "\"$_\"" :
                         m|\A[$noquote_class]+\z|o ? $_       :
                         "'$_'"   )
                   } split /('+)/, $_;
             length $quoted ? $quoted : "''"
         } @_);
}

sub runcmd {
    my $cmd = quote_system_string(@_);
    $log->debug("Running command $cmd");
    system $cmd and logdie "Running command $cmd failed: $?"
}

sub skip {
    my $action = shift;
    my $tag = $action;
    do {
        if ($skip{$tag}) {
            no warnings 'exiting';
            $log->warn("Skipping action $action");
            last SKIP
        }
    } while ($tag =~ s/-[^\-]*$//);
    1
}

sub mirror {
    my ($from, $target) = @_;
    $log->info("Downloading from $from to $target");
    my $res = $ua->mirror($from, $target);
    $res->{success} or logdie "mirroring of $from failed: $res->{status}";
    1;
}

sub install_msys2 {
    my $msys2 = $cfg->{msys2};
    my $prefix = path($msys2->{prefix});
 SKIP: {
        skip 'msys2-install';
        my $url = $msys2->{url};
        my $exe = $wd->child($url =~ s{.*/}{}r);
        my $script_url = $msys2->{'script-url'};
        my $script = $wd->child($script_url =~ s{.*/}{}r);
        mirror($url, $exe);
        mirror($script_url, $script);
        if (-d $prefix) {
        SKIP: {
                skip 'msys2-install-remove';
                $log->info("Removing previous installation at $prefix");
                eval { $prefix->remove_tree({safe => 0}) };
            }
        }

        $log->info("Running $exe --script $script");
        runcmd $exe->canonpath, '--script' => $script->canonpath;
    }
    my $commands = $msys2->{commands};
    my @wrapper = split /\s+/, $commands->{wrapper};
    $wrapper[0] = path($wrapper[0])->absolute($prefix)->canonpath;
 SKIP: {
        skip 'msys2-update';
        $log->info("Updating MSYS2");
        for my $update (@{$commands->{update}}) {
            runcmd @wrapper, $update;
        }
    }
 SKIP: {
        skip 'msys2-packages';
        $log->info("Installing packages");
        my $install = $commands->{install};
        for my $pkg (@{$msys2->{packages}}) {
            $log->info("Installing $pkg");
            runcmd @wrapper, $install . " " . posix_quote($pkg);
        }
    }
    $log->info("MSYS installation completed");
}

sub install_strawberry_perl {
    my $perl = $cfg->{perl};
    my $prefix = path($perl->{prefix});
 SKIP: {
        skip 'perl-install';
        my $url = $perl->{url};
        my $exe = $wd->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (-d $prefix) {
        SKIP: {
                skip 'perl-install-remove';
                $log->info("Removing previous installation at $prefix");
                eval { $prefix->remove_tree({safe => 0}) };
            }
        }

        $log->info("Running $exe");
        runcmd $exe->canonpath;
    }
    $log->info("Perl installation completed");
}

sub install_cygwin {
    $log->info("Cygwin installation completed");
}
