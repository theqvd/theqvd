#!/usr/bin/perl

use strict;
use warnings;
use Term::ANSIColor;
use File::Basename;
use File::Find;
use Module::CoreList;

my $exit_status = 0;
opendir(my $dh, ".") || print_msg("Can't opendir current directory: $!", "FATAL");

for my $dir (grep {-d $_} readdir($dh)) {
    my $module_folder = basename($dir);

    my $makefile_path = "$dir/Makefile.PL";
    my $build_path = "$dir/Build.PL";

    print_msg("Processing $module_folder", "INFO");
    if (-e $makefile_path || -e $build_path) {

        my $module_name = undef;
        my %builder_deps = ();
        if( -e $build_path) {
            $module_name = get_module_name_from_build( $build_path );
            %builder_deps = map {$_ => 1} get_deps_from_build( $build_path );
        } else {
            $module_name = get_module_name_from_makefile( $makefile_path );
            %builder_deps = get_deps_from_makefile( $makefile_path );
        }

        my %module_deps = map {$_ => 1} get_deps_from_module($dir);
        for my $dep (keys %module_deps) {
            delete $module_deps{$dep} if ($dep =~ /^$module_name(::\w+)*$/);
        }

        my $dependencies_ok = 1;
        for my $dep (keys %module_deps) {
            if(!exists $builder_deps{$dep}) {
                print_msg("\t$dep is missing in $module_folder builder", "ERROR");
                $dependencies_ok = 0;
            }
            delete $module_deps{$dep};
            delete $builder_deps{$dep};
        }

        for my $dep (keys %builder_deps) {
            if(module_is_core($dep)){
                my $version = $builder_deps{$dep};
                $version = undef if $version == 0;
                if(module_is_core($dep, $version)) {
                    print_msg("$dep is not required as dependency cause it is core", "WARN");
                    $dependencies_ok = 0;
                } else {
                    print_msg("Module $dep is core but $version is not included", "INFO");
                }
            } else {
                print_msg("$dep is not used in module $module_folder", "WARN");
                $dependencies_ok = 0;
            }
        }

        print_msg("Dependencies are correct for $module_folder", "OK") if $dependencies_ok;
    } else {
        print_msg("The module $module_folder does not have a builder", "INFO");
    }
}
closedir $dh;

exit($exit_status);

### FUNCTIONS ###

sub print_msg {
    my $msg = shift;
    my $type = shift // "INFO";

    my $color = "white";
    if($type eq 'OK') {
        $color = "green";
    } elsif($type eq 'INFO') {
        $color = "blue";
    } elsif ($type eq 'WARN') {
        $color = "yellow";
    } elsif ($type eq 'ERROR') {
        $color = "red";
        $exit_status = 1;
    } elsif ($type eq 'FATAL') {
        $color = "bold black on_white";
    }
    
    print colored("[$type]\t$msg\n", $color);

    exit(1) if $type eq 'FATAL';
}

sub get_deps_from_makefile {
    my $makefile_path = shift;
    my %hash = ();

    my $string = read_file($makefile_path);

    if($string =~ /WriteMakefile\((.*)\)/s){
        no strict;
        no warnings;
        %hash = %{eval "{$1}"};
        %hash = %{$hash{PREREQ_PM} // {}};
    } else {
        print_msg("Cannot detect format of the makefile: $makefile_path", "ERROR");
    }
    
    return %hash;
}

sub get_module_name_from_makefile {
    my $makefile_path = shift;
    my $name = undef;

    my $string = read_file($makefile_path);

    if($string =~ /WriteMakefile\((.*)\)/s){
        no strict;
        no warnings;
        my %hash = %{eval "{$1}"};
        $name = $hash{NAME};
    }

    print_msg("Cannot find module name: $makefile_path", "ERROR") unless defined($name);

    return $name;
}

sub get_deps_from_build {
    my $build_path = shift;
    my @dep_list = ();

    my $string = read_file($build_path);

    if($string =~ /\s+requires\s*=>\s*{(.*?)}/s){
        no strict;
        no warnings;
        my %hash = %{eval "{$1}"};
        push @dep_list, keys (\%hash // {});
    } else {
        print_msg("Cannot detect format of the build file: $build_path", "ERROR");
    }

    return @dep_list;
}

sub get_module_name_from_build {
    my $build_path = shift;
    my $name = undef;

    my $string = read_file($build_path);

    if($string =~ /\s+module_name\s*=>\s*(.*?),/s){
        no strict;
        no warnings;
        $name = eval "$1";
    }

    print_msg("Cannot find module name: $build_path", "ERROR") unless defined($name);

    return $name;
}

sub get_deps_from_module {
    my $module_dir = shift;
    my %dep_hash = ();
    my @file_list = ();

    # Look for perl files in current module
    my $ext_exp = sub {
        my $path = $File::Find::name;
        my $dir = $File::Find::dir;
        if ($path =~ /\.(pm|pl)$/ || $dir =~ /bin$/) {
            push @file_list, $path;
        }
    };
    find({ wanted => $ext_exp, no_chdir=>1 }, $module_dir);

    # Find required modules in current module
    my %regex_sub = (
        # This expression captures the module(s) name for the following examples:
        ## use parent 'QVD::SimpleRPC::Server';
        ## use parent qw(QVD::SimpleRPC::Server);
        ## use QVD::API;
        ## require QVD::API;
        ## use Scalar::Util qw(dualvar);
        ## use lib::glob '*/lib:../g/p5*/lib:../../commercial/*/*/lib';
        ## use App::Daemon qw(daemonize);
        ## use base qw( CLI::Framework::Command::Meta );
        ## use qw( QVD::API);
        '^\s*(?:use(?: parent| base)?|require)\s+(?:(?:qw(?:\(|\/)\s*((?:\w|:|\s)+)\s*(?:\)|\/)\s*)|(?:\'((?:\w|:)+)\')|(?:((?:\w|:|\.)+)))' => sub {
            return [ split(/ /, $1 // ($2 // $3)) ];
        },
        # This expression captures the module(s) name for the following examples:
        ## plugin 'QVD::API::REST';
        ## plugin 'Directory' => {
        '^\s*(?:plugin)\s+\'?((\w|:)+)\'?' => sub {
            my $plugin = $1;
            return [ (($plugin =~ /QVD/)? "" : "Mojolicious::Plugin::") . "$plugin" ];
        },
    );
    my @exceptions = ("5.010", "Win32::API", "Win32::Process", "Wx::Frame", "QVD::HTTPD::.+",
        "QVD::Config::Core::Defaults");
    for my $file (@file_list) {
        open FILE, $file or print_msg("Couldn't open file: $!", "FATAL");
        while (my $line = <FILE>) {
            last if $line =~ /^__END__/;
            for my $regex (keys %regex_sub) {
                if ($line =~ /$regex/) {
                    $dep_hash{ $_ } = 1 for @{$regex_sub{$regex}->()};
                    next;
                }
            }
        }
        close FILE;
    }
    
    for my $exception (@exceptions) {
        for my $module (grep {$_ =~ /$exception/} keys %dep_hash) {
            delete $dep_hash{$module};
        }
    }
    
    for my $dep (keys %dep_hash) {
        delete $dep_hash{$dep} if module_is_core($dep);
    }

    return keys(%dep_hash);
}

sub module_is_core {
    my $module = shift;
    my $version = shift;
    return Module::CoreList::is_core($module, $version, '5.14.3');
}

sub read_file {
    my $path = shift;
    my $string = "";

    local $/ = undef;
    open FILE, $path or print_msg("Couldn't open file: $!", "FATAL");
    $string = <FILE>;
    close FILE;

    return $string;
}
