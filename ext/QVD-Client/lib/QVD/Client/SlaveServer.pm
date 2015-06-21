package QVD::Client::SlaveServer;

use strict;
use warnings;
use QVD::Config::Core qw(core_cfg set_core_cfg);
use File::Spec;

BEGIN {
    my $WINDOWS = ($^O eq 'MSWin32');

    my $user_dir = File::Spec->rel2abs($WINDOWS
        ? File::Spec->join($ENV{APPDATA}, 'QVD')
        : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir $user_dir;

    set_core_cfg('client-slaveserver.log.filename', File::Spec->join($user_dir, 'qvd-client-slaveserver.log'))
        unless defined core_cfg('client-slaveserver.log.filename', 0);
    $QVD::Log::DAEMON_NAME = 'client-slaveserver';
}


our $VERSION = '0.03';
use QVD::Log;
use QVD::HTTP::Headers qw(header_eq_check header_lookup);
use QVD::HTTP::StatusCodes qw(:all);
use QVD::HTTPD;
use File::Spec;
use URI::Split qw(uri_split);
use URI;
use QVD::Client::SlaveServer::Nsplugin;
use base 'QVD::HTTPD::INET';

my $socat = "/usr/bin/socat";

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    $self->set_http_request_processor(\&handle_ping      , GET  => '/ping');
    $self->set_http_request_processor(\&handle_version   , GET  => '/version');
    $self->set_http_request_processor(\&handle_connect   , POST => '/tcp/connect/*');
    $self->set_http_request_processor(\&handle_port_check, GET  => '/tcp/portcheck/*');
    $self->set_http_request_processor(\&handle_get_nsplugin, GET => '/nsplugin');


    bless $self, $class;
}

sub _url_to_port {
    my ($self, $url) = @_;
    chop $url if $url =~ /[\/\\]$/;  # remove dir separator if last character

    (my $port = $url) =~ s/.*[\/\\]//; # pick last part of path

    if ( $port =~ /^\d+$/ && $port >=0 && $port <= 65535 ) {
        return $port;
    } else {
        return undef;
    }

}

sub handle_ping {
    my ($self, $method, $url, $headers) = @_;

    $self->send_http_response_with_body(HTTP_OK, 'text/plain', [], "Pong!\n");
}

sub handle_version {
    my ($self, $method, $url, $headers) = @_;

    $self->send_http_response_with_body(HTTP_OK, 'text/plain', [], "$VERSION\n");
}

sub handle_connect {
    my ($self, $method, $url, $headers) = @_;

    my $port = $self->_url_to_port($url);

    unless ($port) {
        $self->send_http_error(HTTP_BAD_REQUEST, "Bad port number");
        return;
    }

    my $pid = fork();
    if ($pid) {
        $self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
        wait;
    } else {
        INFO "Connecting to tcp:localhost:$port,nonblock,reuseaddr,nodelay,retry=5";
        my @cmd = ($socat, "-", "tcp:localhost:$port,nonblock,reuseaddr,nodelay,retry=5");
        exec @cmd;
        die "Unable to exec: $^E";
    }
}

sub handle_port_check {
    my ($self, $method, $url, $headers) = @_;

    my $port = $self->_url_to_port($url);

    unless ($port) {
        $self->send_http_error(HTTP_BAD_REQUEST, "Bad port number");
        return;
    }

    my $sock = new IO::Socket::INET( PeerAddr => 'localhost',
                                     PeerPort => $port,
                                     Proto    => 'tcp' );

    if ( $sock ) {
        $self->send_http_response(HTTP_OK);
    } else {
        $self->send_http_error(HTTP_FORBIDDEN, $!);
    }
}

sub handle_get_nsplugin {
    my ($httpd, $method, $url, $headers) = @_;

    $httpd->send_http_error(HTTP_BAD_REQUEST)
        unless header_eq_check($headers, Connection => 'Upgrade')
           and header_eq_check($headers, Upgrade => 'qvd:slave/1.0');

    my $uri = URI->new($url);
    my %query = $uri->query_form();
    my $plugin = QVD::Client::SlaveServer::Nsplugin->new(%query);

    $httpd->send_http_response(HTTP_SWITCHING_PROTOCOLS);

    $plugin->execute();
}


'QVD-Client'

__END__

=head1 NAME

QVD::Client::SlaveServer - QVD slave server for the client side.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::VMA::SlaveServer

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-SlaveServer>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-SlaveServer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-SlaveServer>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-SlaveServer/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 QVD Team.

This program is released under the GNU Public License, version 3.
