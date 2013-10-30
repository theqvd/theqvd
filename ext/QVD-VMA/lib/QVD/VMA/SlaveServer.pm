package QVD::VMA::SlaveServer;

use strict;
use warnings;

our $VERSION = '0.01';

use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::Headers qw(header_eq_check header_lookup);
use QVD::HTTP::StatusCodes qw(:all);
use QVD::HTTPD;
use File::Spec;

use base 'QVD::HTTPD::INET';

my $mount_root = $ENV{HOME}.'/Redirected';
my $open_command = core_cfg('command.open_file');
my $command_sshfs = core_cfg('command.sshfs');
my $authentication_key;

BEGIN {
    my $slave_conf = core_cfg('internal.vma.slave.config');
    if (open my $fh, '<', $slave_conf) { 
        $authentication_key = <$fh> // '';
        chomp $authentication_key;
        close $fh;
        print STDERR "Read auth key $authentication_key\n";
    } else {
        print STDERR "Unable to read slave auth key: $!";
    }
}

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    $self->set_http_request_processor(\&handle_put_share, PUT => '/shares/*');
    $self->set_http_request_processor(\&handle_get_share, GET => '/shares/*');
    $self->set_http_request_processor(\&handle_open, POST => '/open/*');
    bless $self, $class;
}

sub auth {
    my ($self, $headers) = @_;
    if (my ($credentials) = header_lookup($headers, 'Authorization')) {
        if (my ($request_key) = $credentials =~ /^Basic (.*)/) {
            print STDERR "Client offers key $request_key\n";
            return 1 if $request_key eq $authentication_key;
        }
        print STDERR "Matching key not offered!\n";
        $self->throw_http_error(HTTP_FORBIDDEN);
    } else {
        print STDERR "Authorization not provided!\n";
        $self->throw_http_error(HTTP_UNAUTHORIZED, ['WWW-Authenticate: Basic realm="QVD"']);
    }
}

sub _url_to_mount_point {
    my ($url) = @_;
    chop $url if $url =~ /[\/\\]$/;  # remove dir separator if last character

    (my $mount_dir = $url) =~ s/.*[\/\\]//; # pick last part of path
    $mount_dir = 'ROOT' if ($mount_dir eq '');
    return $mount_dir;
}

sub handle_put_share {
    my ($self, $method, $url, $headers) = @_;

    $self->auth($headers);

    $self->send_http_error(HTTP_BAD_REQUEST)
        unless header_eq_check($headers, Connection => 'Upgrade')
            and header_lookup($headers, 'Upgrade');

    my $protocol = header_lookup($headers, 'Upgrade');
    unless ($protocol =~ m!qvd:sftp/1.0(?:;charset=(.*))?!) {
	$self->send_http_error(HTTP_BAD_REQUEST)
    }
    my $charset = $1;

    my $mount_dir = _url_to_mount_point($url);

    mkdir $mount_root unless -d $mount_root;
    my $mount_point = $mount_root.'/'.$mount_dir;

    if (-e $mount_point) {
	# Make sure mount point is empty
	rmdir $mount_point or $self->send_http_error(HTTP_CONFLICT);
    }

    mkdir $mount_point or die "Unable to create mount point $mount_point: $^E";

    $self->send_http_response(HTTP_SWITCHING_PROTOCOLS,
        "X-QVD-Share-Ticket: $mount_dir"
    );

    my $pid = fork();
    if ($pid) {
        wait;
        rmdir $mount_point;
    } else {
	my @cmd = ($command_sshfs => "qvd-client:", $mount_point, -o => 'slave', -o => 'idmap=user', -o => 'atomic_o_trunc');
	push @cmd, -o => "modules=iconv,from_code=$charset" if ($charset);
	exec @cmd;
        die "Unable to exec $command_sshfs: $^E";
    }
}

sub handle_get_share {
    my ($self, $method, $url, $headers) = @_;
    $self->auth($headers);
    # We don't allow clients to mount directories *from* the VM
    $self->send_http_error(HTTP_FORBIDDEN);
}

sub handle_open {
    my ($self, $method, $url, $headers) = @_;
    $self->auth($headers);

    my $mount_dir = header_lookup($headers, 'X-QVD-Share-Ticket');
    my $rel_path = ($url =~ m!/open/(.*)!, $1);
    my $abs_path = "$mount_root/$mount_dir/$rel_path";

    $self->send_http_error(HTTP_NOT_FOUND) unless -e $abs_path;

    my $pid = fork();
    if ($pid) {
        $self->send_http_response(HTTP_OK);
        wait;
    } else {
        $ENV{DISPLAY} = ':100';
	my @cmd = ($open_command, $abs_path);
	exec @cmd;
        die "Unable to exec: $^E";
    }
}

'QVD-VMA'

__END__

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

