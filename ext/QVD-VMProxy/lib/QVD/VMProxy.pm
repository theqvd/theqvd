package QVD::VMProxy;

use Moo;
use Mojo::IOLoop;
use Mojo::Util 'term_escape';
use Mojo::URL;
use QVD::Log;

has [qw/url/] => ( is => 'ro' );

sub open_ws {
    my ($self, $tx, $ua) = @_;

    $ua->websocket($self->url => { Host => 'localhost'} => sub {
            my ($ua, $ws) = @_;

            ERROR "WebSocket handshake failed!\n" and return unless $ws->is_websocket;

            $ws->on(error => sub {
                    DEBUG "-- Docker connection error $_[1]\n";
                    $ws->finish;
                });
            $ws->on(finish => sub {
                    DEBUG "-- Docker connection closed\n";
                    $tx->finish;
                });
            $ws->on(binary => sub {
                    my ($ws, $message) = @_;
                    DEBUG "-- Docker >>> WebSocket ($message)\n";
                    $tx->send({binary => $message});
                });
            $tx->on(binary => sub {
                    my ($tx, $message) = @_;
                    DEBUG "-- Docker <<< WebSocket ($message)\n";
                    $ws->send({binary => $message});
                });
            $ws->send("START\n");
        }
    );

    return $ua;
}

sub open {
    my ($self, $tx, $send_qvd_header) = @_;

    my $url = Mojo::URL->new($self->url);
    my %args = (
        address => $url->host,
        port    => $url->port,
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

                        my $invalid_message = 1;
                        if ($bytes =~ /HTTP\/1.1 102 Processing/) {
                            INFO "Processing request message received";
                            $invalid_message = 0;
                        }
                        if ($bytes =~ /HTTP\/1.1 101 Switching Protocols/) {
                            INFO "Switching protocol message received";
                            $invalid_message = 0;
                            $stream->stop();
                            $stream->unsubscribe('read');
                            $cb->($stream);
                        }
                        if ($invalid_message) {
                            ERROR "Invalid response received when upgrading to VNC";
                            $tx->finish;
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
                ERROR "TCP error: $_[1]";
                $stream->close;
            });

            $stream->on(close => sub {
                INFO "TCP connection closed";
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
    
            $tx->on(finish => sub {
                my ($tx) = @_;
                INFO "Incoming TCP connection closed";
                $stream->close;
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


