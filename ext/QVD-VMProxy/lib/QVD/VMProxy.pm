package QVD::VMProxy;

use Mojo::Base 'Mojo::EventEmitter';
use Mojo::IOLoop;
use Mojo::Util 'term_escape';
use QVD::Log;

has ioloop => sub { Mojo::IOLoop->singleton };

has [qw/address port/];

sub open {
    my ($self, $tx, $timeout) = @_;

    my %args = (
        address => $self->address,
        port    => $self->port,
    );
    my $loop = $self->ioloop;
    $loop->delay(
        sub {
            my $delay = shift;
            $loop->client(%args, $delay->begin)
        },
        sub {
            my ($delay, $err, $stream) = @_;

            $self->emit(error => "TCP connection error: $err") if $err;

            die $err if $err;

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
        },
        sub {
            my ($delay, $stream) = @_;

            Mojo::IOLoop->stream($tx->connection)->timeout($timeout);
            $stream->timeout($timeout);

            $stream->on(error => sub { $self->emit(error => "TCP error: $_[1]") });
            $stream->on(close => sub { 
                $self->emit(error => "TCP connection closed");
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

            $tx->on(finish => sub {
                my ($tx, $code, $reason) = @_;
                $reason ||= '';
                DEBUG term_escape "-- Websocket Connection closed. Code: $code ($reason)\n";
                $stream->close;
                undef $stream;
                undef $tx;
            });
            $stream->start;
        },
    )->catch(sub { my ($delay, $err) = @_; die $err; })->wait;

    return $self;
}

1;

__END__

=head1 NAME

QVD::VMProxy - Forwards x11 protocol data from QVD-VMA

=head1 SYNOPSIS

    my $connection = QVD::VMProxy->new( address => $ip, port => $port );
    $connection->on( error => sub {
        print "Error " . $_[1] );
        $tx->finish();
    } );
    $connection->open($tx, 60);

=head1 AUTHOR

Francisco Trapero, E<lt>ftrapero@qindel.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut


