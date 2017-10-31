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
my $log_fn; # = $this_path->child('log.txt');
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

if (defined $log_fn) {
    Log::Any::Adapter->set(File => $log_fn, log_level => $log_level);
}
else {
    Log::Any::Adapter->set(Stderr => log_level => $log_level);
}
my $log = Log::Any->get_logger;

sub logdie {
    my $msg = join ': ', @_;
    $log->fatal($msg);
    die "$msg\n";
}

my $cfg = YAML::LoadFile($cfg_fn)
    or logdie($cfg_fn, "Loading configuration file failed");

$wd //= $cfg->{run}{workdir};
$wd = ($wd ? path($wd) : Path::Tiny->tempdir)->absolute;
$log->info("Working dir: $wd");

my $downloads = $wd->child('download');
my $src = $wd->child('src');
my $out = $wd->child('out');

@do = @{$cfg->{run}{do}} unless @do;

my %skip = map { lc($_) => 1 } @skip;
my %do = map { lc($_) => 1 } @do;

my $ua = HTTP::Tiny->new();

setup_skel();
setup_msys();
setup_strawberry_perl();
setup_cygwin();
setup_vcxsrv();
setup_ghostscript();
setup_gsview();

setup_env();

build_perl_libgettext();
build_perl_locale_gettext();
build_pulseaudio();
build_nxproxy();
build_win_sftp_server();
build_qvd_slaveserver_wrapper();
build_qvd_client();

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

sub rmtree {
    my $path = path(shift);
    if ($path->is_dir) {
        eval { runcmd 'rd', '/s', '/q', w32q($path->canonpath) };
    }
    if ($path->exists) {
        eval { $path->remove_tree({safe => 0}) };
        $log->warn("remove_tree for ".$path->canonpath." failed: $@") if $@
    }
}

sub skip_for {
    my $action = shift;
    my $tag = $action;
    while (1) {
        if ($do{$tag}) {
            $log->debug("Doing action $action");
            return 1;
        }
        $skip{$tag} and last;
        $tag =~ s/-[^\-]*$// or last;
    }
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

sub mkcmd_posix {
    join " ", (@_ > 1 ? join(' ', map posix_quote($_), @_) : $_[0]);
}

sub mkcmd_msys {
    state @wrapper;
    unless (@wrapper) {
        @wrapper = split /\s+/, $cfg->{run}{msys}{wrapper};
        $wrapper[0] = w32q(path($wrapper[0])->absolute($cfg->{run}{msys}{prefix})->canonpath);
    }
    return join " ", @wrapper, w32q(mkcmd_posix(@_));
}

sub mkcmd_perl_sh {
    state @wrapper;
    unless (@wrapper) {
        @wrapper = split /\s+/, $cfg->{run}{perl_sh}{wrapper};
        $wrapper[0] = w32q(path($wrapper[0])->absolute($cfg->{run}{msys}{prefix})->canonpath);
    }
    return join " ", @wrapper, w32q(mkcmd_posix(@_));
}

sub mkcmd_cygwin {
    state @wrapper;
    unless (@wrapper) {
        @wrapper = split /\s+/, $cfg->{run}{cygwin}{wrapper};
        $wrapper[0] = w32q(path($wrapper[0])->absolute($cfg->{run}{cygwin}{prefix})->canonpath);
    }
    return join " ", @wrapper, w32q(mkcmd_posix(@_));
}

sub capturecmd {
    my $cmd = join(" ", @_);
    $log->debug("Capturing command $cmd");
    my @out = `$cmd`;
    $? and logdie "Running command $cmd failed: $?";
    chomp @out;
    wantarray ? @out : $out[0];
}

sub w32_path_to_msys {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $out = capturecmd mkcmd_msys cygpath => -u => $path;
        $log->debug("win32 path $path translated to msys $out");
        $out
    };
}

sub msys_path_to_w32 {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $out = capturecmd mkcmd_msys cygpath => -w => $path;
        $log->debug("msys path $path translated to win32 $out");
        $out
    }
}

sub w32_path_to_cygwin {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $out = capturecmd mkcmd_cygwin cygpath => -u => $path;
        $log->debug("win32 path $path translated to cygwin $out");
        $out
    };
}

sub cygwin_path_to_w32 {
    my $path = shift;
    state %cache;
    $cache{$path} //= do {
        my $out = capturecmd mkcmd_cygwin cygpath => -w => $path;
        $log->debug("cygwin path $path translated to win32 $out");
        $out
    }
}

sub mkcmd_cmd_in {
    my $dir = shift;
    join(' ', cd => '/d', w32q($dir->canonpath), '&', @_);
}

sub mkcmd_msys_in {
    my $dir = shift;
    join(' ', cd => posix_quote(w32_path_to_msys($dir->canonpath)), '&&', mkcmd_posix(@_))
}

sub mkcmd_cygwin_in {
    my $dir = shift;
    join(' ', cd => posix_quote(w32_path_to_cygwin($dir->canonpath)), '&&', mkcmd_posix(@_))
}

sub mkcmd_perl_sh_in {
    my $dir = shift;
    mkcmd_perl_sh join(' ', cd => posix_quote(w32_path_to_msys($dir->canonpath)), '&&', mkcmd_posix(@_))
}

sub mkcmd_mingw32 {
    state $env = do {
        my $prefix = path($cfg->{run}{mingw32}{prefix})
            ->absolute($cfg->{run}{msys}{prefix});
        my $mingw32_prefix = posix_quote(w32_path_to_msys($prefix));
        my $mingw32_bin = posix_quote(w32_path_to_msys($prefix->child('bin')));
        my $mingw32_aclocal = posix_quote(w32_path_to_msys($prefix->child('share/aclocal')));
        my $mingw32_lib_pkgconfig = posix_quote(w32_path_to_msys($prefix->child('lib/pkgconfig')));
        my $mingw32_share_pkgconfig = posix_quote(w32_path_to_msys($prefix->child('share/pkgconfig')));
        my %env = ( MSYSTEM => 'MINGW32',
                    MSYSTEM_PREFIX => $mingw32_prefix,
                    MINGW_PREFIX => $mingw32_prefix,
                    PATH => "$mingw32_bin:\$PATH",
                    CONFIG_SITE => posix_quote(w32_path_to_msys($prefix->child('etc/config.site'))),
                    MSYSTEM_CHOST => 'i686-w64-mingw32',
                    MINGW_CHOST => 'i686-w64-mingw32',
                    ACLOCAL_PATH => "$mingw32_aclocal:\$ACLOCAL_PATH",
                    PKG_CONFIG_PATH => "$mingw32_lib_pkgconfig:$mingw32_share_pkgconfig" );
        join ' ', map { "$_=$env{$_}" } sort keys %env;
    };

    "$env ". mkcmd_posix(@_)
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

sub runcmd_cygwin {
    runcmd mkcmd_cygwin(@_);
}

sub runcmd_cygwin_in {
    runcmd_cygwin mkcmd_cygwin_in(@_);
}

sub runcmd_perl {
    my $prefix = path($cfg->{run}{perl}{prefix});
    local $ENV{PATH} = join(';',
                            w32q($prefix->child('perl/bin')),
                            w32q($prefix->child('c/bin')),
                            # w32q($msys_prefix->child('usr/bin')),
                            $ENV{PATH});
    runcmd @_;
}

sub runcmd_perl_msys {
    my $msys_prefix = path($cfg->{run}{msys}{prefix});
    my $mingw32_prefix = path($cfg->{run}{mingw32}{prefix})->absolute($msys_prefix);
    local $ENV{PATH} = join(';',
                            w32q($mingw32_prefix->child('bin')),
                            w32q($msys_prefix->child('usr/bin')),
                            $ENV{PATH});
    runcmd_perl @_;
}

sub runcmd_perl_sh_in {
    runcmd_perl_msys mkcmd_perl_sh_in @_;
}


sub runcmd_perl_in {
    runcmd_perl mkcmd_cmd_in(@_);
}

sub runcmd_env_in {
    my $env = shift;
    if ($env eq 'msys') {
        runcmd_msys_in(@_);
    }
    elsif ($env eq 'mingw32') {
        runcmd_mingw32_in(@_);
    }
    elsif ($env eq 'cygwin') {
        runcmd_cygwin_in(@_);
    }
    elsif ($env eq 'perl') {
        runcmd_perl_in(@_);
    }
    elsif ($env eq 'perl_sh') {
        runcmd_perl_sh_in(@_);
    }
    else {
        logdie("Bad environment designator '$env'");
    }
}

sub setup_skel {
    $wd->mkpath;
    $downloads->mkpath;
    $src->mkpath;
    $out->mkpath;
}

sub setup_msys {
    my $msys = $cfg->{setup}{msys};
    my $prefix = path($cfg->{run}{msys}{prefix});
    my $product = $msys->{product};
    my $commands = $msys->{commands};
 SKIP: {
        skip_for 'setup-msys-install';
        my $url = $msys->{url};
        my $exe = $downloads->child($url =~ s{.*/}{}r);
        my $script_url = $msys->{'autoinstall-script-url'};
        my $script = $downloads->child($script_url =~ s{.*/}{}r);
        mirror($url, $exe);
        mirror($script_url, $script);
        my $uninstall = $prefix->child($commands->{uninstall});
        if (-x $uninstall) {
        SKIP: {
                skip_for 'setup-msys-install-uninstall';
                $log->info("Removing previous installations of $product");
                runcmd w32q($uninstall);
            }
        }
        if (-d $prefix) {
        SKIP: {
                skip_for 'setup-msys-install-remove';
                $log->info("Removing previous installation at $prefix");
                rmtree($prefix);
            }
        }

        $log->info("Running $exe --script $script");
        runcmd w32q($exe->canonpath), '--script' => w32q($script->canonpath);
    }
 SKIP: {
        skip_for 'setup-msys-update';
        $log->info("Updating $product");
        for my $update (@{$commands->{update}}) {
            runcmd_msys $update;
        }
    }
 SKIP: {
        skip_for 'setup-msys-packages';
        $log->info("Installing packages");
        my $install = $commands->{install};
        for my $pkg (@{$msys->{packages}}) {
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
        my $exe = $downloads->child($url =~ s{.*/}{}r);
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
                rmtree($prefix);
            }
        }

        $log->info("Running $exe");
        runcmd 'MSIEXEC', '/i', w32q($exe->canonpath), '/passive';
    }

 SKIP: {
        skip_for 'setup-perl-modules';
        for my $module (@{$perl->{modules}}) {
            my $name = $module->{name};
            my $url = $module->{url};
            my $src = $url // $name;
            if (defined (my $branch = $module->{branch})) {
                $src .= '@' . $branch;
            }
            $log->info(defined($name)
                       ? "Installing Perl module '$name' from '$src'"
                       : "Installing Perl module from '$src'");
            if (defined $url and $url =~ /\.git$/) {
                runcmd_perl_msys cpanm => w32q($src);
            }
            else {
                runcmd_perl cpanm => w32q($src);
            }
        }
    }

    $log->info("$product installation completed");
}

sub setup_cygwin {
    my $cygwin = $cfg->{setup}{cygwin};
    my $prefix = path($cfg->{run}{cygwin}{prefix});
    my $product = $cygwin->{product};
 SKIP: {
        skip_for 'setup-cygwin-install';
        my $url = $cygwin->{url};
        my $exe = $downloads->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (-d $prefix) {
            skip_for 'setup-cygwin-install-remove';
            $log->info("Removing previous installation at $prefix");
            rmtree($prefix);
        }

        my $site = $cygwin->{site};
        my @cmd = (w32q($exe->canonpath),
                   '--root', w32q($prefix->canonpath),
                   '--site', w32q($site),
                   '--local-package-dir', w32q($downloads->canonpath),
                   '--quiet-mode', '--wait', '--no-admin', '--no-shortcuts');

        if (my @packages = @{$cygwin->{packages} // []}) {
            push @cmd, '--packages', join ',', map w32q($_), @packages;
        }

        runcmd @cmd;

    SKIP: {
            skip_for 'setup-cygwin-install-firstuse';
            runcmd_cygwin 'true';
        }
    }
    $log->info("Cygwin installation completed");
}

sub setup_vcxsrv {
    my $vcxsrv = $cfg->{setup}{vcxsrv};
    my $prefix = path($cfg->{run}{vcxsrv}{prefix});
    my $product = $vcxsrv->{product};
 SKIP: {
        skip_for 'setup-vcxsrv';
        my $url = $vcxsrv->{url};
        my $exe = $downloads->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (-d $prefix) {

        }
        $log->info("Installing VcXsrv");
        $prefix->mkpath;
        runcmd w32q($exe), '/S', '/D=' . $prefix->canonpath;
    }
    $log->info("VcXsrv installation completed");
}

sub setup_ghostscript {
    my $ghostscript = $cfg->{setup}{ghostscript};
    my $prefix = path($cfg->{run}{ghostscript}{prefix});
    my $product = $ghostscript->{product};
 SKIP: {
        skip_for 'setup-ghostscript';
        my $url = $ghostscript->{url};
        my $exe = $downloads->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (-d $prefix) {

        }
        $log->info("Installing Ghostscript");
        runcmd w32q($exe), '/S', "/D=" . $prefix->canonpath; # $prefix shouldn't be quoted here!!!
    }
    $log->info("Ghostscript installation completed");
}

sub setup_gsview {
    my $gsview = $cfg->{setup}{gsview};
    my $prefix = path($cfg->{run}{gsview}{prefix});
    my $product = $gsview->{product};
 SKIP: {
        skip_for 'setup-gsview';
        my $url = $gsview->{url};
        my $exe = $downloads->child($url =~ s{.*/}{}r);
        mirror($url, $exe);

        if (-d $prefix) {

        }
        $log->info("Installing Gsview");
        # runcmd w32q($exe);

        $prefix->mkpath;
        runcmd_msys_in($prefix, unzip => w32_path_to_msys($exe->canonpath));
    }
    $log->info("GSview installation completed");
}

sub git_env_in {
    my $env = shift;
    my $dir = shift;
    $env = 'perl_sh' if $env eq 'perl';
    $log->debug("running $env git command in directory $dir: git @_");
    runcmd_env_in $env, $dir, git => @_;
}

sub build_pulseaudio {
    build_from_repos('pulseaudio');
}

sub build_win_sftp_server {
    build_from_repos('win-sftp-server');
}

sub build_nxproxy {
    build_from_repos('nxproxy');
}

sub build_qvd_slaveserver_wrapper {
    build_from_repos('qvd-slaveserver-wrapper');
}

sub setup_env {
    for my $env (qw(perl cygwin msys gsview ghostscript vcxsrv)) {
        my $prefix = path($cfg->{run}{$env}{prefix});
        my $cp = $prefix->canonpath;
        $ENV{uc($env)."_PREFIX"} = w32q($cp);
        $ENV{uc($env)."_PREFIX_CYGWIN"} = w32_path_to_cygwin($cp);
        $ENV{uc($env)."_PREFIX_MSYS"} = w32_path_to_msys($cp);
    }
}


sub build_perl_libgettext {
    build_from_repos('perl-libgettext');
}

sub build_perl_locale_gettext {
    build_from_repos('perl-locale-gettext');
}

sub build_qvd_client {
    build_from_repos('qvd-client');
}

sub next_temp {
    my $name = shift;
    state $ix = 0;
    $ix++;
    $wd->child('temp', "$ix-$name");
}

sub build_from_repos {
    my ($name, $this, $parent) = @_;
    $this //= $cfg->{build}{$name};
    my $build = $this->{build};
    my $commands = $build->{commands};
    my ($longname, $unpackdir, $srcdir, $outdir, $env);
    if ($parent) {
        $longname = $this->{longname} //= join('-', grep defined, $parent->{longname}, $name);
        $unpackdir = path($this->{unpackdir} //= $parent->{unpackdir});
        $srcdir = path($this->{srcdir} //= path($parent->{srcdir})->child($this->{subdir} // $name)->stringify());
        $outdir = path($this->{outdir} //= $parent->{outdir});
        $env = $build->{env} //= $parent->{build}{env};
    }
    else {
        $longname = $this->{longname} //= $name;
        $unpackdir = path($this->{unpackdir} //= $wd->child('src', $name)->stringify);
        $srcdir = path($this->{srcdir} //= (defined($build->{subdir})
                                            ? $unpackdir->child($build->{subdir})
                                            : $unpackdir)->stringify);
        $outdir = path($this->{outdir} //= $wd->child('out', $name)->stringify);
        $env = $build->{env} //= 'mingw32';
    }

    my $tempdir = path($this->{tempdir} //= next_temp($longname)->stringify);

    my $envname = uc($longname =~ s/[\W]+/_/gr);
    $ENV{"${envname}_OUTDIR"} = w32q($outdir->canonpath);
    $ENV{"${envname}_SRCDIR"} = w32q($srcdir->canonpath);
    $ENV{"${envname}_TEMPDIR"} = w32q($tempdir->canonpath);
    $ENV{"${envname}_OUTDIR_CYGWIN"} = w32_path_to_cygwin($outdir->canonpath);
    $ENV{"${envname}_SRCDIR_CYGWIN"} = w32_path_to_cygwin($srcdir->canonpath);
    $ENV{"${envname}_TEMPDIR_CYGWIN"} = w32_path_to_cygwin($tempdir->canonpath);
    $ENV{"${envname}_OUTDIR_MSYS"} = w32_path_to_msys($outdir->canonpath);
    $ENV{"${envname}_SRCDIR_MSYS"} = w32_path_to_msys($srcdir->canonpath);
    $ENV{"${envname}_TEMPDIR_MSYS"} = w32_path_to_msys($tempdir->canonpath);

    #use Data::Dumper;
    #$log->debug("This: ".Dumper($this)."\nArgs: ".Dumper(\@_)."\nEnv: ".Dumper(\%ENV));

    if (-d $tempdir) {
    SKIP: {
            skip_for "build-$longname-temp-remove";
            $log->trace("cleaning $tempdir");
            rmtree($tempdir);
        }
    }

 SKIP: {
        skip_for "build-$longname-out-remove";
        rmtree($outdir);
        $outdir->mkpath;
    }
    if (my $repo = $this->{repository}) {
        my $repo_url = $this->{repository}{url};

        if ($repo_url =~ /\.git$/) {
            my $branch = $this->{repository}{branch};
        SKIP: {
                skip_for "build-$longname-git-clone";
                if (-d $unpackdir) {
                SKIP: {
                        skip_for "build-$longname-git-clone-remove";
                        rmtree($unpackdir);
                    }
                }
                else {
                    $log->debug("$unpackdir was empty");
                }
                $unpackdir->mkpath;
                # git_in($unpackdir, clone => -c => 'core.symlinks=true', $repo_url, '.');
                git_env_in($env, $unpackdir, clone => $repo_url, '.');
            }
        SKIP: {
                skip_for "build-$longname-git-checkout";
                git_env_in($env, $unpackdir, checkout => $this->{repository}{branch});
            }
        SKIP: {
                skip_for "build-$longname-git-pull";
                git_env_in($env, $unpackdir, pull => 'origin', $this->{repository}{branch});
            }
        }
        elsif ($repo_url =~ /\.t(?:ar\.)?gz$/) {
            my $tgz = $downloads->child($repo_url =~ s{.*/}{}r);
        SKIP: {
                skip_for "build-$longname-download";
                mirror($repo_url, $tgz);
            }
        SKIP: {
                skip_for "build-$longname-unpack";
                if (-d $unpackdir) {
                SKIP: {
                        skip_for "build-$longname-unpack-remove";
                        rmtree($unpackdir);
                    }
                }
                else {
                    $log->debug("$unpackdir was empty");
                }
                $unpackdir->mkpath;
                runcmd_env_in('msys', $unpackdir, tar => 'xzf', w32_path_to_msys($tgz->canonpath));
            }
        }
        else {
            logdie("unsupported termination in url: $repo_url");
        }

        if ($commands and $commands->{clean}) {
        SKIP: {
                skip_for "build-$longname-clean";
                runcmd_env_in($env, $unpackdir, $commands->{clean});
            }
        }
    }
    if ($commands) {
        if ($commands->{env}) {
        SKIP: {
                skip_for "build-$longname-env";
                runcmd_env_in($env, $srcdir, $commands->{env});
            }
        }
        if ($commands->{bootstrap}) {
        SKIP: {
                skip_for "build-$longname-bootstrap";
                runcmd_env_in($env, $srcdir, $commands->{bootstrap});
            }
        }
        if ($commands->{configure}) {
        SKIP: {
                skip_for "build-$longname-configure";
                my $configure = $commands->{configure};
                runcmd_env_in($env, $srcdir, $configure);
            }
        }
        if ($commands->{make}) {
        SKIP: {
                skip_for "build-$longname-make";
                runcmd_env_in($env, $srcdir, $commands->{make});
            }
        }
        if ($commands->{test}) {
        SKIP: {
                skip_for "build-$longname-test";
                runcmd_env_in($env, $srcdir, $commands->{test});
            }
        }
        if ($commands->{install}) {
        SKIP: {
                skip_for "build-$longname-install";
                runcmd_env_in($env, $srcdir, $commands->{install});
            }
        }
    }

    if (my $children = $this->{children}) {
        for my $child (@$children) {
            build_from_repos($child->{name}, $child, $this);
        }
    }
}

