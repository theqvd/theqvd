#!/usr/bin/perl

use strict;
use warnings;
use 5.022;

use Path::Tiny;

my $dest = path(shift // '.')->child('lib');
$dest->is_dir or die "target directory $dest does not exist";


my $qvd_src = path($0)->realpath->parent->parent->parent;

warn "qvd-src: $qvd_src\n";

for my $module (qw( QVD::Client QVD::Config::Core QVD::Config
                    QVD::HTTP QVD::HTTPC QVD::HTTPD
                    QVD::Log QVD::SimpleRPC QVD::URI
                    IO::Socket::Forwarder )) {


    my $top = $qvd_src->child('ext', ($module =~ s/::/-/gr), 'lib');
    #warn "top: $top\n";

    $top->visit(sub {
                    my $path = shift;
                    if ($path =~ /\.pm$/i) {
                        my $rel = $path->relative($top);
                        my $to = $dest->child($rel);
                        if ($to->is_file) {
                            if ($path->stat->[9] > $to->stat->[9]) {
                                warn "updating $rel!\n";
                                $path->copy($to);
                            }
                            else {
                                # warn "file $rel did not change.\n";
                            }
                        }
                        else {
                            warn "$rel does not exists in target, ignoring it.\n";
                        }
                    }
                },
                {recurse => 1});
}
