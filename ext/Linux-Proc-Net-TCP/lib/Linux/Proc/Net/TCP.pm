package Linux::Proc::Net::TCP;

our $VERSION = '0.05';

use strict;
use warnings;

use Carp;
use Scalar::Util;

sub read {
    my ($class, %opts) = @_;

    my $ip4 = delete $opts{ip4};
    my $ip6 = delete $opts{ip6};
    my $mnt = delete $opts{mnt};

    %opts and croak "Unknown option(s) ". join(", ", sort keys %opts);

    $mnt = "/proc" unless defined $mnt;

    unless (-d $mnt and (stat _)[12] == 0) {
        croak "$mnt is not a proc filesystem";
    }

    my @fn;
    push @fn, "$mnt/net/tcp"  unless (defined $ip4 and not $ip4);
    push @fn, "$mnt/net/tcp6" if (defined $ip6 ? -f "$mnt/net/tcp6" : $ip6);

    my @entries;
    for my $fn (@fn) {
        local $_;
        open my $fh, '<', $fn
            or croak "Unable to open $fn: $!";
        <$fh>; # discard header
        while (<$fh>) {
            my @entry = /^\s*
                         (\d+):\s                                     # sl                        -  0
                         ([\dA-F]{8}(?:[\dA-F]{24})?):([\dA-F]{4})\s  # local address and port    -  1 y  2
                         ([\dA-F]{8}(?:[\dA-F]{24})?):([\dA-F]{4})\s  # remote address and port   -  3 y  4
                         ([\dA-F]{2})\s                               # st                        -  5
                         ([\dA-F]{8}):([\dA-F]{8})\s                  # tx_queue and rx_queue     -  6 y  7
                         (\d\d):([\dA-F]{8}|(?:F{9,}))\s              # tr and tm->when           -  8 y  9
                         ([\dA-F]{8})\s+                              # retrnsmt                  - 10
                         (\d+)\s+                                     # uid                       - 11
                         (\d+)\s+                                     # timeout                   - 12
                         (\d+)\s+                                     # inode                     - 13
                         (\d+)\s+                                     # ref count                 - 14
                         ((?:[\dA-F]{8}){1,2})                        # memory address            - 15
                         (?:
                             \s+
                             (\d+)\s+                                 # retransmit timeout        - 16
                             (\d+)\s+                                 # predicted tick            - 17
                             (\d+)\s+                                 # ack.quick                 - 18
                             (\d+)\s+                                 # sending congestion window - 19
                             (-?\d+)                                  # slow start size threshold - 20
                         )?
                         \s*
                         (.*)                                         # more                      - 21
                         $
                        /xi;
            if (@entry) {
                my $entry = \@entry;
                bless $entry, 'Linux::Proc::Net::TCP::Entry';
                push @entries, $entry
            }
            else {
                warn "unparseable line: $_";
            }
        }
    }
    bless \@entries, $class;
}

sub listeners {
    my $table = shift;
    my @l;
    for (@$table) {
	last unless $_->[5] eq '0A';
	push @l, $_;
    }
    @l;
}

sub listener_ports {
    my $table = shift;
    my @p;
    for (sort { $a <=> $b } map $_->local_port, $table->listeners) {
	push @p, $_ unless (($p[-1] || 0) == $_)
    }
    @p;
}

package Linux::Proc::Net::TCP::Entry;

my @st_names = ( undef,
		 qw(ESTABLISHED
		    SYN_SENT
		    SYN_RECV
		    FIN_WAIT1
		    FIN_WAIT2
		    TIME_WAIT
		    CLOSE
		    CLOSE_WAIT
		    LAST_ACK
		    LISTEN
		    CLOSING) );

sub _st2dual {
    my $st = hex shift;
    my $name = $st_names[$st];
    (defined $name ? Scalar::Util::dualvar($st, $name) : $st);
}

sub _hex2ip {
    my $bin = pack "C*" => map hex, $_[0] =~ /../g;
    my @l = unpack "L*", $bin;
    if (@l == 4) {
        return join ':', map { sprintf "%x:%x", $_ >> 16, $_ & 0xffff } @l;
    }
    elsif (@l == 1) {
        return join '.', map { $_ >> 24, ($_ >> 16 ) & 0xff, ($_ >> 8) & 0xff, $_ & 0xff } @l;
    }
    else { die "internal error: bad hexadecimal encoded IP address '$_[0]'" }
}

sub sl                        {          shift->[ 0] }
sub local_address             { _hex2ip  shift->[ 1] }
sub local_port                { hex      shift->[ 2] }
sub rem_address               { _hex2ip  shift->[ 3] }
sub rem_port                  { hex      shift->[ 4] }
sub st                        { _st2dual shift->[ 5] }
sub tx_queue                  { hex      shift->[ 6] }
sub rx_queue                  { hex      shift->[ 7] }
sub timer                     {          shift->[ 8] }
sub retrnsmt                  { hex      shift->[10] }
sub uid                       {          shift->[11] }
sub timeout                   {          shift->[12] }
sub inode                     {          shift->[13] }
sub reference_count           {          shift->[14] }
sub memory_address            { hex      shift->[15] }
sub retransmit_timeout        {          shift->[16] }
sub predicted_tick            {          shift->[17] }
sub ack_quick                 {          ( shift->[18] || 0 ) >> 1 }
sub ack_pingpong              {          ( shift->[18] || 0 ) &  1 }
sub sending_congestion_window {          shift->[19] }
sub slow_start_size_threshold {          shift->[20] }
sub _more                     {          shift->[21] }
sub ip4                       { length(shift->[ 1]) ==  8 }
sub ip6                       { length(shift->[ 1]) == 32 }


sub tm_when { # work around bug in Linux kernel
    my $when = shift->[9];
    $when =~ /^F{8,}$/ ? -1 : hex $when
}


1;
__END__

=head1 NAME

Linux::Proc::Net::TCP - Parser for Linux /proc/net/tcp and /proc/net/tcp6

=head1 SYNOPSIS

  use Linux::Proc::Net::TCP;
  my $table = Linux::Proc::Net::TCP->read;

  for my $entry (@$table) {
    printf("%s:%d --> %s:%d, %s\n",
           $entry->local_address, $entry->local_port,
           $entry->rem_address, $entry->rem_port,
           $entry->st );
  }

=head1 DESCRIPTION

This module can read and parse the information available from
/proc/net/tcp in Linux systems.

=head1 API

=head2 The table object

=over

=item $table = Linux::Proc::Net::TCP->read

=item $table = Linux::Proc::Net::TCP->read(%opts)

reads C</proc/net/tcp> and C</proc/net/tcp6> and returns an object
representing a table of the connections.

Individual entries in the table can be accessed just dereferencing the
returned object. For instance:

  for my $entry (@$table) {
    # do something with $entry
  }

The table entries are of class C<Linux::Proc::Net::TCP::Entry>
described below.

This method accepts the following optional arguments:

=over 4

=item ip4 => 0

disables parsing of the file /proc/net/tcp containing state
information for TCP over IP4 connections

=item ip6 => 0

disables parsing of the file /proc/net/tcp6 containing state
information for TCP over IP6 connections

=item mnt => $procfs_mount_point

overrides the default mount point for the procfs at C</proc>.

=back

=item $table->listeners

returns a list of the entries that are listeners:

  for my $entry ($table->listeners) {
    printf "listener: %s:%d\n", $entry->local_address, $entry->local_port;
  }

=item $table->listener_ports

returns the list of TCP ports where there are some service listening.

This method can be used to find some unallocated port:

  my @used_ports = Linux::Proc::Net::TCP->read->listener_ports;
  my %used_port = map { $_ => 1 } @used_ports;
  my $port = $start;
  $port++ while $used_port{$port};

=back

=head2 The entry object

The entries in the table are of class
C<Linux::Proc::Net::TCP::Entry> and implement the following read only
accessors:

   sl local_address local_port rem_address rem_port st tx_queue
   rx_queue timer tm_when retrnsmt uid timeout inode reference_count
   memory_address retransmit_timeout predicted_tick ack_quick
   ack_pingpong sending_congestion_window slow_start_size_threshold
   ip4 ip6

=head1 The /proc/net/tcp documentation

This is the documentation about /proc/net/tcp available from the Linux
kernel source distribution:

 This document describes the interfaces /proc/net/tcp and
 /proc/net/tcp6.  Note that these interfaces are deprecated in favor
 of tcp_diag.

 These /proc interfaces provide information about currently active TCP
 connections, and are implemented by tcp4_seq_show() in
 net/ipv4/tcp_ipv4.c and tcp6_seq_show() in net/ipv6/tcp_ipv6.c,
 respectively.

 It will first list all listening TCP sockets, and next list all
 established TCP connections. A typical entry of /proc/net/tcp would
 look like this (split up into 3 parts because of the length of the
 line):

   46: 010310AC:9C4C 030310AC:1770 01 
   |      |      |      |      |   |--> connection state
   |      |      |      |      |------> remote TCP port number
   |      |      |      |-------------> remote IPv4 address
   |      |      |--------------------> local TCP port number
   |      |---------------------------> local IPv4 address
   |----------------------------------> number of entry

   00000150:00000000 01:00000019 00000000  
      |        |     |     |       |--> number of unrecovered RTO timeouts
      |        |     |     |----------> number of jiffies until timer expires
      |        |     |----------------> timer_active (see below)
      |        |----------------------> receive-queue
      |-------------------------------> transmit-queue

   1000        0 54165785 4 cd1e6040 25 4 27 3 -1
    |          |    |     |    |     |  | |  | |--> slow start size threshold, 
    |          |    |     |    |     |  | |  |      or -1 if the threshold
    |          |    |     |    |     |  | |  |      is >= 0xFFFF
    |          |    |     |    |     |  | |  |----> sending congestion window
    |          |    |     |    |     |  | |-------> (ack.quick<<1)|ack.pingpong
    |          |    |     |    |     |  |---------> Predicted tick of soft clock
    |          |    |     |    |     |              (delayed ACK control data)
    |          |    |     |    |     |------------> retransmit timeout
    |          |    |     |    |------------------> location of socket in memory
    |          |    |     |-----------------------> socket reference count
    |          |    |-----------------------------> inode
    |          |----------------------------------> unanswered 0-window probes
    |---------------------------------------------> uid

 timer_active:
  0  no timer is pending
  1  retransmit-timer is pending
  2  another timer (e.g. delayed ack or keepalive) is pending
  3  this is a socket in TIME_WAIT state. Not all fields will contain 
     data (or even exist)
  4  zero window probe timer is pending


=head1 AUTHOR

Salvador FandiE<ntilde>o E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010, 2012 by Qindel Formacion y Servicios S.L.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
