#!/usr/bin/perl

use strict;
use warnings;
use 5.022;

use Path::Tiny;

my $comp = shift if @ARGV > 1;
$comp //= 'client';

my $dest = path(shift // '.');

$dest = $dest->child('lib') unless $dest =~ /\blib\b/;

$dest->is_dir or die "target directory $dest does not exist";


my $qvd_src = path($0)->realpath->parent->parent->parent;

warn "qvd-src: $qvd_src\n";


my %module = (client => [qw( QVD::Client QVD::Config::Core QVD::Config
	                     QVD::HTTP QVD::HTTPC QVD::HTTPD
                             QVD::Log QVD::SimpleRPC QVD::URI
                             IO::Socket::Forwarder)],
	      vma => [qw( QVD::VMA QVD::HTTPD QVD::HTTPC QVD::Config::Core QVD::Config QVD::Log QVD::SimpleRPC)]);

for my $module (@{$module{$comp}}) {

    my $top = $qvd_src->child('ext', ($module =~ s/::/-/gr), 'lib');
    #warn "top: $top\n";

    $top->visit(sub {
                    my $path = shift;
                    if ($path =~ /\.pm$/i) {
                        my $rel = $path->relative($top);
                        my $to = $dest->child($rel);
                        if (!$to->exists or $path->stat->[9] > $to->stat->[9]) {
                            warn "updating $rel!\n";
                            $path->copy($to);
                        }
                        else {
                            # warn "file $rel did not change.\n";
                        }
                    }
                },
                {recurse => 1});
}
