package QVD::Client::SlaveServer::Nsplugin;
use QVD::Log;
use Data::Dumper;
use Carp;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = \%params;
    bless $self, $class;
}

sub _plugin_path {
    my ($self, $plugin) = @_;

    DEBUG "_plugin_path plugin is $plugin";

    my %plugin_paths = (
	flash => '/usr/lib/adobe-flashplugin/libflashplayer.so',
	mplayer => '/usr/lib/mozilla/plugins-qvd/gecko-mediaplayer.so',
	divx => '/usr/lib/mozilla/plugins-qvd/gecko-mediaplayer-dvx.so',
	realplayer => '/usr/lib/mozilla/plugins-qvd/gecko-mediaplayer-rm.so',
	quicktime => '/usr/lib/mozilla/plugins-qvd/gecko-mediaplayer-qt.so',
	'windows media' => '/usr/lib/mozilla/plugins-qvd/gecko-mediaplayer-wmp.so',
	);

    foreach my $key (keys %plugin_paths) {
	DEBUG "Testing $key against $plugin";
	my $path = $plugin_paths{$key};
	if ($plugin =~ /$key/i) {
	    return $path if (-f $path);
	    croak "Detected plugin $plugin but $path does not seem to exist";
	}
    }

    croak "Detected plugin $plugin but $path does not seem to exist";
}

sub _npviewer_path {
    my ($self, $plugin) = @_;

    DEBUG "_npviewer_path plugin is $plugin";
    if ($^O eq 'VMS' || $^O eq 'MSWin32') {
	croak "Platform still not supported";
    }
    require POSIX;

    my ($sysname, $nodename, $release, $version, $machine) = POSIX::uname();
    my $losysname = lc $sysname;
    my $exe = "/usr/lib/nspluginwrapper/$machine/$losysname/npviewer";
    my $path = "$exe --plugin ".$self->_plugin_path($plugin).
	" --connection 127.0.0.1:11100 --remote-invocation id=myid-9509";

    return $path;
}

sub execute {
    my ($self, $plugin, $debug) = @_;

    # Created on new
    my $plugin = $self->{plugin};
    my $debug = $self->{debug};

    DEBUG "Nsplugin: execute with plugin $plugin";

    if ($debug) {
	$ENV{NPW_DEBUG}="7";
	$ENV{NPW_LOG}="/tmp/npw-viewer.$plugin.out";
    }


    $ENV{NPW_INIT_TIMEOUT}="300";
    $ENV{NPW_MESSAGE_TIMEOUT}="300";
    $ENV{NPW_DEBUG}="1";
    $ENV{NPW_LOG}="/tmp/npw-viewer.out";

    my $npviewer = $self->_npviewer_path($plugin);

    print STDERR "Invoking $npviewer\n";
    DEBUG "Invoking $npviewer\n";
    exec $npviewer;

}


1;

=head1 NAME

QVD::SlaveServer::Nsplugin - Enables to execute different slave services in QVD

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Executes the nsplugin wrapper between server and client

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::SlaveServer::Nsplugin

You can also look for information at:

=over 4

=item * QVD Support site

L<https://support.theqvd.com>

=item * Github

L<https://github.com/theqvd/theqvd>

=item * Search QVD web site

L<http://theqvd.com/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 QVD Team.

This program is released under the GNU Public License, version 3.
