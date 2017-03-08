package QVD::VMProxy;

use Moo;
use Mojo::IOLoop;
use Mojo::Util 'term_escape';
use QVD::Log;

has [qw/address port/] => ( is => 'ro' );

sub open {
    my ($self, $tx, $send_qvd_header) = @_;

    my %args = (
        address => $self->address,
        port    => $self->port,
    );
    my $loop = Mojo::IOLoop->singleton;
    my $delay = $loop->delay(
        sub {
            my $delay = shift;
            $loop->client(%args, $delay->begin);
        },
        sub {
            my ($delay, $err, $stream) = @_;

            die $err if $err;
            if($send_qvd_header){
                $stream->write("GET \/vma\/vnc_connect HTTP/1.1\nConnection: Upgrade\nUpgrade: VNC\n\n");

                my $cb = $delay->begin(0);
                $stream->on(read => sub {
                        my ($stream, $bytes) = @_;
                        DEBUG term_escape "-- <<< VMA ($bytes)\n";
                        if ($bytes =~ /101/){
                            $stream->stop();
                            $stream->unsubscribe('read');
                            $cb->($stream);
                        }
                    });
                $stream->start;
            } else {
                my $cb = $delay->begin(0);
                $cb->($stream);
            }
        },
        sub {
            my ($delay, $stream) = @_;

            $stream->timeout(0);

            $stream->on(error => sub {
                DEBUG term_escape "TCP error: $_[1]";
                $stream->emit('close');
            });

            $stream->on(close => sub {
                DEBUG term_escape "TCP connection closed";
                $tx->finish;
            });

            $stream->on(read => sub {
                my ($stream, $bytes) = @_;
                DEBUG term_escape "-- TCP >>> WebSocket ($bytes)\n";
                $tx->send({binary => $bytes});
            });

            $tx->on(binary => sub {
                my ($tx, $bytes) = @_;
                DEBUG term_escape "-- TCP <<< WebSocket ($bytes)\n";
                $stream->write($bytes);
            });

            $stream->start;
        },
    )->catch(sub { my ($delay, $err) = @_; die $err; });

    return $delay;
}

1;

__END__

=head1 NAME

QVD::VMProxy - Forwards x11 protocol data from QVD-VMA

=head1 SYNOPSIS

    my $connection = QVD::VMProxy->new( address => $ip, port => $port );
    $connection->open($tx, 60);

=head1 AUTHOR

Francisco Trapero, E<lt>ftrapero@qindel.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut


