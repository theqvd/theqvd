package QVD::VMProxy;

use Mojo::Base 'Mojo::EventEmitter';
use Mojo::IOLoop;
use Mojo::Util 'term_escape';
use QVD::Log;

has ioloop => sub { Mojo::IOLoop->singleton };

has [qw/address port/];

sub open {
    my ($self, $tx) = @_;

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

