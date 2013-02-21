package QVD::Client::SlaveServer;

use strict;
use warnings;

our $VERSION = '0.01';

use QVD::HTTPD;
use base 'QVD::HTTPD::INET';

use URI::Split qw(uri_split);
use IO::Handle;
use QVD::HTTP::Headers qw(header_eq_check);
use QVD::HTTP::StatusCodes qw(:all);
use QVD::Config::Core qw(core_cfg);

## SFTP server
my $command_sftp_server = core_cfg('command.sftp_server');

sub new {
    my ($class) = @_;
    my $self = {};
    my $httpd = QVD::HTTPD->new();
    $httpd->set_http_request_processor(\&handle_qvd,  GET => '/qvd/resources');
    $httpd->set_http_request_processor(\&handle_get_shared, GET => '/shared/*');
    $httpd->set_http_request_processor(\&handle_put_shared, PUT => '/shared/*');
    $self->{httpd} = $httpd;
    bless $self, $class;
    $self;
}

sub handle_qvd {
    my ($httpd) = @_;
    my @resources;
    for my $dir ('/', $ENV{HOME}) {
        unshift @resources, {uri => '/shared'.$dir};
    }

    $httpd->send_http_response_with_body(HTTP_OK, 'application/json', [], 
        $httpd->json->encode([\@resources]));
}

sub handle_get_shared {
    my ($httpd, $method, $url, $headers) = @_;

    $httpd->send_http_error(HTTP_BAD_REQUEST)
        unless header_eq_check($headers, Connection => 'Upgrade')
            and header_lookup($headers, 'Upgrade');

    $httpd->send_http_error(HTTP_NOT_IMPLEMENTED) unless header_eq_check(Upgrade => 'qvd:slave/1.0');

    # Extract root from URI
    my ($scheme, $host, $path, $query, $frag) = uri_split($url);
    (my $realpath = $path) =~ s/^\/shared//;

    # Run sftp-server from root
    chdir $realpath or die "Unable to chdir to $realpath: $^E";

    $httpd->send_http_response(HTTP_SWITCHING_PROTOCOLS);
    exec $command_sftp_server;
}

sub handle_put_shared {
    my ($httpd, $method, $url, $headers) = @_;

    # The client does not allow mounting shares from the VM for the moment.
    $httpd->send_http_error(HTTP_FORBIDDEN);
}

1;

=head1 NAME

QVD::SlaveServer - The great new QVD::SlaveServer!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::SlaveServer;

    my $foo = QVD::SlaveServer->new();
    ...

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::SlaveServer

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

