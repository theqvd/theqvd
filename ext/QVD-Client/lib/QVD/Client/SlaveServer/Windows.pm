package QVD::Client::SlaveServer::Windows;

use strict;
use warnings;

use QVD::Log;
use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::StatusCodes qw(:all);
use Win32::Process qw(INFINITE NORMAL_PRIORITY_CLASS CREATE_NO_WINDOW);
use Win32::LongPath;

sub _trim {
    my @r = @_;
    s/^\s+|\s+$//g for @r;
    grep /\S/, @r
}

sub _w32q {
    my $arg = shift;
    for ($arg) {
        $_ eq '' and return '""';
        if (/[ \t\n\x0b"]/) {
            s{(\\+)(?="|\z)}{$1$1}g;
            s{"}{\\"}g;
            return qq("$_")
        }
        return $_
    }
}

sub _cmd_quote {
    my @r = map _w32q($_), @_;
    wantarray ? @r : join(" ", @r);
}

sub _ptrpath {
    my $ptr = shift;
    my $name = $ptr->{PrinterName};
    my $server = $ptr->{ServerName};
    defined $server ? '\\$server\\$name' : $name;
}

sub _ptrid {
    my $id = _ptrpath(shift);
    $id =~ s/\W/_/g;
    $id
}

sub _printers {
    my $self = shift;

    require Win32::EnumPrinters;
    my $default = Win32::EnumPrinters::GetDefaultPrinter();

    map {
        my %data = ( qvd_id => _ptrid($_),
                     name   => _ptrpath($_) );
        $data{default} = 1 if $name eq $default;
        $data{duplex}  = 1 if $_->{DevMode}{Duplex} ne 'simplex';
        $data{color}   = 1 if $_->{DevMode}{Color}  eq 'color';
        \%data
    } Win32::EnumPrinters('local', undef, 2);
}

sub _print_file {
    my ($self, $printer_id, $fn) = @_;
    my $gsprint_exe     = File::Spec->rel2abs(core_cfg('command.gsprint'),
                                              $QVD::Client::SlaveServer::app_dir);
    my $ghostscript_exe = File::Spec->rel2abs(core_cfg('command.ghostscript'),
                                              $QVD::Client::SlaveServer::app_dir);
    DEBUG "gsprint.exe at '$gsprint_exe', ghostscript.exe at '$ghostscript_exe'";

    my ($drive, $gs_path) = File::Spec->splitpath($ghostscript_exe, 1);
    my @gs_exe_path= File::Spec->splitdir($gs_path);
    my $gs_path = File::Spec->catdir(@gs_exe_path[0..$#gs_exe_path - 2]);
    my $ghostscript_lib = shortpathL(File::Spec->catpath($drive, $gs_path, 'lib')) // do {
        ERROR "Unable to locate Ghostscript library directory";
        $self->throw_http_error(HTTP_INTERNAL_SERVER_ERROR, "Ghostscript installation is broken");
    };

    DEBUG "ghostscript drive: $drive, path: $gs_path, inc: $ghostscript_lib";

    for (Win32::EnumPrinters::EnumPrinters('local', undef, 2) {
        if (_ptrid($_) eq $printer_id) {
            my $path = _ptrpath($_);
            DEBUG "Printer real name is '$path'";
            my $child;
            my $cmd = shortpathL($gsprint_exe);
            my $line = _cmd_quote($cmd, '-color',
                                  # '-quiet', # we better let ghostscript tell the user what it is doing!
                                  "-I$ghostscript_lib",
                                  -ghostscript => $ghostscript_exe,
                                  -printer => $path,
                                  $fn);
            DEBUG "Running command '$cmd', line: '$line'";

            Win32::Process::Create($child, $cmd, $line, 0,
                                   NORMAL_PRIORITY_CLASS | CREATE_NO_WINDOW,
                                   "c:\\")
                    or $self->throw_http_error(HTTP_INTERNAL_SERVER_ERROR, $^E);
            $child->Wait(INFINITE);
            $child->GetExitCode(my $code);
            if ($code) {
                ERROR "gsprint failed, rc: $code";
                $self->throw_http_error(HTTP_INTERNAL_SERVER_ERROR, "gsprint failed, rc: $code");
            }
            DEBUG "gsprint exited with rc 0";
            return 1;
        }
    }
    $self->throw_http_error(HTTP_NOT_FOUND, "Printer not found");
}

1;
