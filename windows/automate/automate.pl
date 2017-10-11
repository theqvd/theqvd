#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use YAML;
use Path::Tiny;
use Getopt::Long;
use Log::Any::Adapter;
use HTTP::Tiny;
use Win32::ShellQuote ();

BEGIN { *w32q = \&Win32::ShellQuote::quote_system_string }


my $this_path = path($0)->realpath->parent;
my $cfg_fn = $this_path->child('automate.yaml');
my $log_fn = $this_path->child('log.txt');
my $log_level = 'info';
my $wd;
my @skip;
my @do;

GetOptions('config|cfg|f=s'   => \$cfg_fn,
           'log-level|ll|l=s' => \$log_level,
           'workdir|wd|w=s'   => \$wd,
           'skip|K=s'         => \@skip,
           'do|D=s'           => \@do)
    or die "Error in command line arguments\n";

Log::Any::Adapter->set(File => $log_fn, log_level => $log_level);
my $log = Log::Any->get_logger;

sub logdie {
    my $msg = join ': ', @_;
    $log->fatal($msg);
    die "$msg\n";
}

my $cfg = YAML::LoadFile($cfg_fn)
    or logdie($cfg_fn, "Loading configuration file failed");

$wd //= $cfg->{run}{workdir};
$wd = ($wd ? path($wd) : Path::Tiny->tempdir);
$log->info("Working dir: $wd");


@do = @{$cfg->{run}{do}} unless @do;

my %skip = map { lc($_) => 1 } @skip;
my %do = map { lc($_) => 1 } @do;

my $ua = HTTP::Tiny->new();

setup_msys2();
setup_strawberry_perl();
setup_cygwin();

build_pulseaudio();
build_nxproxy();
build_win_sftp_server();
build_slave_wrapper();

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
    my $cmd = join(" ", @_);
    $log->debug("Running command $cmd");
    system $cmd and logdie "Running command $cmd failed: $?"
}

sub skip_for {
    my $action = shift;
    my $tag = $action;
    do {
        return 1 if $do{$tag};
        last if $skip{$tag};
    } while ($tag =~ s/-[^\-]*$//);
    no warnings 'exiting';
    $log->warn("Skipping action $action");
    last SKIP;
}

sub mirror {
    my ($from, $target) = @_;
    $log->info("Downloading from $from to $target");
    my $res = $ua->mirror($from, $target);
    $res->{success} or logdie "mirroring of $from failed: $res->{status}";
    1;
}

sub wmic_look_for {
    my $name = shift;
    my @products = grep /^\Q$name\E\b/i, `wmic product get name`;
    s/^\s+//, s/\s+$// for @products;
    $log->debug('Previous installations of $product found: ' . scalar(@products));
    wantarray ? @products : $products[0];
}

sub wmic_uninstall {
    my $name = shift;
    runcmd "wmic product where name=".w32q($name)." call uninstall";
}

sub mkcmd_msys_c {
    join " ", (@_ > 1 ? join(' ', map posix_quote($_), @_) : $_[0]);
}

sub mkcmd_msys {
    state @wrapper;
    unless (@wrapper) {
        @wrapper = split /\s+/, $cfg->{run}{msys2}{wrapper};
        $wrapper[0] = w32q(path($wrapper[0])->absolute($cfg->{run}{msys2}{prefix})->canonpath);
    }
    return join " ", @wrapper, w32q(mkcmd_msys_c(@_));
}

sub w32_path_to_msys {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $cmd = mkcmd_msys cygpath => -u => $path;
        my $out = `$cmd`;
        chomp($out);
        $log->debug("win32 path $path translated to msys $out");
        $out
    };
}

sub msys_path_to_w32 {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $cmd = mkcmd_msys cygpath => -w => $path;
        my $out = `$cmd`;
        chomp($out);
        $log->debug("msys path $path translated to win32 $out");
        $out
    }
}

sub mkcmd_msys_in {
    my $dir = shift;
    join(' ', cd => posix_quote(w32_path_to_msys($dir->canonpath)), '&&', mkcmd_msys_c(@_))
}

sub mkcmd_mingw32 {
    state $env = do {
        my $prefix = path($cfg->{run}{mingw32}{prefix})
            ->absolute($cfg->{run}{msys2}{prefix});
        my $msys_prefix = posix_quote(w32_path_to_msys($prefix));
        my $msys_bin = posix_quote(w32_path_to_msys($prefix->child('bin')));
        "MSYSTEM=MINGW32 MINGW_PREFIX=$msys_prefix PATH=$msys_bin:\$PATH";
    };

    mkcmd_msys_c("$env ". mkcmd_msys_c(@_));
}

sub mkcmd_mingw32_in {
    my $dir = shift;
    mkcmd_msys_in $dir, mkcmd_mingw32 @_;
}

sub runcmd_msys {
    runcmd mkcmd_msys(@_);
}

sub runcmd_msys_in {
    runcmd_msys mkcmd_msys_in(@_);
}

sub runcmd_ming32 {
    runcmd_msys mkcmd_mingw32 @_;
}

sub runcmd_mingw32_in {
    runcmd_msys mkcmd_mingw32_in @_;
}

sub setup_msys2 {
    my $msys2 = $cfg->{setup}{msys2};
    my $prefix = path($cfg->{run}{msys2}{prefix});
    my $product = $msys2->{product};
    my $commands = $msys2->{commands};
 SKIP: {
        skip_for 'setup-msys2-install';
        my $url = $msys2->{url};
        my $exe = $wd->child($url =~ s{.*/}{}r);
        my $script_url = $msys2->{'autoinstall-script-url'};
        my $script = $wd->child($script_url =~ s{.*/}{}r);
        mirror($url, $exe);
        mirror($script_url, $script);
        my $uninstall = $prefix->child($commands->{uninstall});
        if (-x $uninstall) {
        SKIP: {
                skip_for 'setup-msys2-install-uninstall';
                $log->info("Removing previous installations of $product");
                runcmd w32q($uninstall);
            }
        }
        if (-d $prefix) {
        SKIP: {
                skip_for 'setup-msys2-install-remove';
                $log->info("Removing previous installation at $prefix");
                eval { $prefix->remove_tree({safe => 0}) };
            }
        }

        $log->info("Running $exe --script $script");
        runcmd w32q($exe->canonpath), '--script' => w32q($script->canonpath);
    }
 SKIP: {
        skip_for 'setup-msys2-update';
        $log->info("Updating $product");
        for my $update (@{$commands->{update}}) {
            runcmd_msys $update;
        }
    }
 SKIP: {
        skip_for 'setup-msys2-packages';
        $log->info("Installing packages");
        my $install = $commands->{install};
        for my $pkg (@{$msys2->{packages}}) {
            $log->info("Installing $pkg");
            runcmd_msys $install . " " . posix_quote($pkg);
        }
    }
    $log->info("$product installation completed");
}

sub setup_strawberry_perl {
    my $perl = $cfg->{setup}{perl};
    my $prefix = path($cfg->{run}{perl}{prefix});
    my $product = $perl->{product};
 SKIP: {
        skip_for 'setup-perl-install';
        my $url = $perl->{url};
        my $exe = $wd->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (my @p = wmic_look_for $product) {
        SKIP: {
                skip_for 'setup-perl-install-uninstall';
                $log->info("Removing previous installations of $product");
                wmic_uninstall $_ for @p;
            }
        }
        if (-d $prefix) {
        SKIP: {
                skip_for 'setup-perl-install-remove';
                $log->info("Removing previous installation at $prefix");
                eval { $prefix->remove_tree({safe => 0}) };
            }
        }

        $log->info("Running $exe");
        runcmd 'MSIEXEC', '/a', w32q($exe->canonpath), '/passive';
    }
    $log->info("$product installation completed");
}

sub setup_cygwin {
    $log->info("Cygwin installation completed");
}

sub git_in {
    my $dir = shift;
    $log->debug("running git command in directory $dir: git @_");
    runcmd_msys_in $dir, git => @_;
}

sub build_pulseaudio {
    my $pa = $cfg->{build}{pulseaudio};
    my $commands = $pa->{build}{commands};
    my $repo_url = $pa->{repository}{url};
    my $branch = $pa->{repository}{branch};
    my $pa_wd = $wd->child('pulseaudio');
    my $pa_src = $pa_wd->child('src');
    my $pa_out = $pa_wd->child('out');
 SKIP: {
        skip_for 'build-pulseaudio-out-remove';
        eval { $pa_out->remove_tree({safe => 0}) };
        $pa_out->mkpath;
    }
 SKIP: {
        skip_for 'build-pulseaudio-git-clone';

        if (-d $pa_src) {
        SKIP: {
                skip_for 'build-pulseaudio-git-clone-remove';
                eval { $pa_wd->remove_tree({safe => 0}) };
            }
        }
        $pa_src->mkpath;
        git_in($pa_src, clone => $repo_url, '.');
    }
 SKIP: {
        skip_for 'build-pulseaudio-git-checkout';
        git_in($pa_src, checkout => $pa->{repository}{branch});
    }
 SKIP: {
        skip_for 'build-pulseaudio-git-pull';
        git_in($pa_src, pull => 'origin', $pa->{repository}{branch});
    }
 SKIP: {
        skip_for 'build-pulseaudio-autogen';
        my $autogen = "$commands->{autogen} --prefix=".w32_path_to_msys($pa_out);
        runcmd_mingw32_in($pa_src, $commands->{autogen});
    }
 SKIP: {
        skip_for 'build-pulseaudio-make';
        runcmd_mingw32_in($pa_src, $commands->{make});
    }
 SKIP: {
        skip_for 'build-pulseaudio-install';
        runcmd_mingw32_in($pa_src, $commands->{install});
    }
}

sub build_nxproxy {
}

sub build_win_sftp_server {
}

sub build_slave_wrapper {
}
