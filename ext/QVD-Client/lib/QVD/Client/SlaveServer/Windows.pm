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

sub _printer_config {
    my ($name, $key) = _cmd_quote @_;
    my $cmd = _cmd_quote "& Get-PrintConfiguration -PrinterName $name | Format-Wide -Property $key -Column 1";
    my $val = `Powershell.exe -windowstyle hidden $cmd`;
    $val =~ s/^\s+|\s+$//g;
    $val;
}

sub _printer_names {
    _trim `Powershell.exe -windowstyle hidden "& Get-Printer | Format-Wide -Property Name -Column 1"`;
}

sub _printers {
    my $self = shift;
    my @names = $self->_printer_names;
    s/\W/_/g for @names;

    my $id;
    my @prs = map {
        { Id => ++$id,
          Name => $_,
          Default_printer => 0, # unimplemented
          IsDuplex => _printer_config($_, 'DuplexingMode'),
          Color => _printer_config($_, 'Color') }
    } @names;
}

sub _print_file {
    my ($self, $printer_name, $fn) = @_;
    my $gsprint_exe     = File::Spec->rel2abs(core_cfg('command.gsprint'),
                                              $QVD::Client::SlaveServer::app_dir);
    my $ghostscript_exe = File::Spec->rel2abs(core_cfg('command.ghostscript'),
                                              $QVD::Client::SlaveServer::app_dir);
    DEBUG "gsprint.exe at '$gsprint_exe', ghostscript.exe at '$ghostscript_exe'";
    my @names = $self->_printer_names;
    for (@names) {
        my $real_name = $_;
        s/\W/_/g;
        if ($_ eq $printer_name) {
            DEBUG "Printer real name is '$real_name'";
            my $child;
            my $cmd = shortpathL($gsprint_exe);
            my $line = _cmd_quote($cmd,
                                  -ghostscript => $ghostscript_exe,
                                  -printer => $real_name,
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
