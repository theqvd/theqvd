package QVD::VMA::SlaveServer;

use strict;
use warnings;

our $VERSION = '0.01';

use URI::Split qw(uri_split);
use IO::Handle;
use QVD::HTTP::Headers qw(header_eq_check);
use QVD::HTTP::StatusCodes qw(:all);
use QVD::HTTPD;

use base 'QVD::HTTPD::INET';

my $mount_root = '/tmp';

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    $self->set_http_request_processor(\&handle_shares, PUT => '/shares/*');
    bless $self, $class;
    $self;
}

#sub process_request {
#    my ($self) = @_;
#    $self->{server}{client} = IO::Handle->new_from_fd(fileno(STDIN), '+<');
#    $self->{server}{client}->autoflush();
#    $self->process_request();
#}

sub handle_shares {
    my ($httpd, $method, $url, $headers) = @_;

    $httpd->send_http_error(HTTP_BAD_REQUEST)
        unless header_eq_check($headers, Connection => 'Upgrade')
            and header_eq_check($headers, Upgrade => 'qvd:sftp/1.0');

    $httpd->send_http_error(HTTP_UNSUPPORTED_MEDIA_TYPE)
        unless header_eq_check($headers, 'Accept'=>'application/vnd.qvd-sftp');

    (my $remote_path = $url) =~ s/^\/shares//;
    (my $mount_dir = $remote_path) =~ s/^.*\///; # pick last part of path
    $mount_dir = 'ROOT' if ($mount_dir eq '');
    my $mount_point = $mount_root.'/'.$mount_dir;

    $httpd->send_http_error(HTTP_CONFLICT) if -e $mount_point;

    mkdir $mount_point;
    $httpd->send_http_response(HTTP_SWITCHING_PROTOCOLS);

    #my $flgs = fcntl($httpc->{socket}, F_GETFL, 0);
    #fcntl($httpc->{socket}, F_SETFL, $flgs & ~O_NONBLOCK) 
    #    or die "Unable set connection to blocking: $^E";

    #open STDIN, '<&', $httpc->{socket} or die "Unable to dup stdin: $^E";
    #open STDOUT, '>&', $httpc->{socket} or die "Unable to dup stdout: $^E";

    #close $httpc->{socket};
    #mkdir $mount_point;

    my $pid = fork();
    if ($pid) {
        wait;
        rmdir $mount_point;
    } else {
        exec(sshfs => "qvd-client:$remote_path", $mount_point, -o => 'slave');
        die "Unable to exec sshfs: $^E";
    }
}


=head1 NAME

QVD::VMA::SlaveServer - QVD slave server for the VMA side.

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

