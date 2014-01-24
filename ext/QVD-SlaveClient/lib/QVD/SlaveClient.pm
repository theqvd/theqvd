package QVD::SlaveClient;

use 5.010;
use strict;
use warnings FATAL => 'all';



use QVD::Config::Core qw(core_cfg);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use IO::Socket::INET;
use IO::Socket::Forwarder qw(forward_sockets);
use QVD::Log;
use feature 'switch';


=head1 NAME

QVD::Client::SlaveClient - The great new QVD::Client::SlaveClient!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Client::SlaveClient;

    my $foo = QVD::Client::SlaveClient->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

sub new {
    my ($class, $target, %opts) = @_;
    my $self = {
        target => $target,
        opts   => \%opts

    };
    bless $self, $class;
    $self
}


=head2 ping

Ping the slave server on the client side

=cut

sub ping {
    my ($self) = @_;

    my $httpc = $self->_make_httpc();
    my ($code, $msg, $headers, $data) =
    $httpc->make_http_request(GET => '/ping');

    die "Slave server replied $code $msg" if ($code != HTTP_OK);
    return 0;
}


=head2 version

Return the version of the slave server on the client side

=cut

sub version {
    my ($self) = @_;

    my $httpc = $self->_make_httpc();

    my ($code, $msg, $headers, $data) =
    $httpc->make_http_request(GET => '/version');

    die "Slave server replied $code $msg" if ($code != HTTP_OK);

    return $data;
}


=head2 forward_port($port, $remote_side_port)

Listen on local port $port and forward connections to $remote_side_port
on the client side.

=cut

sub forward_port {
    my ($self, $port, $remote_side_port) = @_;


    my %children;
#    $SIG{CHLD} = sub { waitpid; }


    my $serv = new IO::Socket::INET( Listen    => 5,
                                     LocalAddr => 'localhost',
                                     LocalPort => $port,
                                     Proto     => 'tcp' );

    die "Failed to listen on port $port: $!" unless ($serv);

    while( my $socket = $serv->accept() ) {


        my $pid = fork();
        if ( $pid == 0 ) {
            INFO "Child started, connecting to port $remote_side_port on the remote side";

            my $httpc = $self->_make_httpc();

            my ($code, $msg, $headers, $data) =
                 $httpc->make_http_request(POST => "/tcp/connect/$remote_side_port");

            die "Slave server replied $code $msg" if ($code != HTTP_SWITCHING_PROTOCOLS);

            INFO "Forwarding";
            forward_sockets($httpc->{socket}, $socket);
            INFO "Child terminated";
            exit(0);
        } elsif ( $pid > 0 )  {
            INFO "Spawned child $pid";
            $children{$pid} = 1;
        } else {
            ERROR "Fork failed!";
            $socket->close;
        }

    }


    return 0;
}


sub _make_httpc {
    my $self = shift;

    return QVD::HTTPC->new($self->{target}, %{$self->{opts}})
}

=head1 AUTHOR

Vadim Troshchinskiy, C<< <vadim at qindel.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-client-slaveclient at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-Client-SlaveClient>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::Client::SlaveClient


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-Client-SlaveClient>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-Client-SlaveClient>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-Client-SlaveClient>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-Client-SlaveClient/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Vadim Troshchinskiy.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.


=cut

1; # End of QVD::Client::SlaveClient
