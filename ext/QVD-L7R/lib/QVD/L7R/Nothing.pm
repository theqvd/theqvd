package QVD::L7R::Nothing;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::HTTP::StatusCodes qw(:status_codes);

use Time::HiRes qw(sleep);

use base qw(QVD::L7R);

my $x_start_timeout = cfg('internal.l7r.nothing.timeout.x_start');
my $x_state_timeout = cfg('internal.l7r.nothing.timeout.x_state');
my $x_run_forwarder_timeout = cfg('internal.l7r.nothing.timeout.run_forwarder');

my $delay = sub {
    my $timeout = shift;
    sleep($timeout * (0.6 + 0.8 * rand));
};

sub _vma_client {
    my ($l7r, $vm) = @_;
    my $host = $vm->vm_address;
    my $port = $vm->vm_port;
    return QVD::L7R::Nothing::VMAClient->new(host => $host, port => $port);
}

sub _run_forwarder {
    my ($l7r, $vm, %params) = @_;
    my $vm_id = $vm->vm_id;
    my $vm_address = $vm->vm_address;
    my $vm_x_port = $vm->vm_x_port;
    my $this_host = this_host;
    $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');

    $l7r->_tell_client("Connecting X session for VM_ID: " . $vm->id);

    txn_do { $this_host->counters->incr_nx_attempts; };
    $delay->($x_run_forwarder_timeout);
    txn_do { $this_host->counters->incr_nx_ok; };
    $delay->($x_run_forwarder_timeout);
    txn_do {
        $vm->discard_changes;
        $l7r->_check_abort($vm);
        $vm->set_user_state('connected');
    };

    $l7r->_tell_client("Connection established");
    $l7r->send_http_response(HTTP_SWITCHING_PROTOCOLS,
                             "X-QVD-Slave-Key: $params{'qvd.slave.key'}");
    $delay->($x_run_forwarder_timeout);
    DEBUG "Starting socket forwarder for VM " . $vm->id;
    db->storage->disconnect;
}

package QVD::L7R::Nothing::VMAClient;

sub new {
    my ($class, %opts) = @_;
    my $self = \%opts;
    bless $self, $class;
}

sub x_start {
    my ($self, @params) = @_;
    $delay->($x_start_timeout);
    1;
}

sub x_state {
    $delay->($x_state_timeout);
    'listening';
}

1;
