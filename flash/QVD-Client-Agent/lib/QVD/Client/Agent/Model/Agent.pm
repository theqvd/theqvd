package QVD::Client::Agent::Model::Agent;
use Moose;
use namespace::autoclean;
use File::Spec;
use Data::Dumper;
use POSIX ":sys_wait_h";

extends 'Catalyst::Model';

=head1 NAME

QVD::Client::Agent::Model::Agent - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Nito,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
has windowid =>(is => 'rw', isa => 'Str', default => "0x5c0001e");

has host => (is => 'rw', isa => 'Str', default => '212.73.49.56');
#has host => (is => 'rw', isa => 'Str', default => '127.0.0.1');
has port => (is => 'rw', isa => 'Int', default => 4111);

has portMappings => (is => 'rw', isa => 'HashRef', default => sub { return {}; });
has pidMappings => (is => 'rw', isa => 'HashRef', default => sub { return {}; });
has allowed_exec_paths => 
    ( is => 'rw', 
      isa => 'HashRef', 
      default => sub 
      { 
	  my @paths = ('/usr/bin/',
		       '/usr/lib/nspluginwrapper/noarch/',
		       '/usr/lib/nspluginwrapper/x86_64/',
		       '/usr/lib/nspluginwrapper/i386/',
		       '/usr/lib/nspluginwrapper/i386/linux/',
	      );
	  my %map = map { $_ => 1 } @paths;
	  return \%map; 
      });


sub getPort {
    my ($self, $id) = @_;
    
    if (!exists($self->portMappings->{$id}->{port})) {
	$self->portMappings->{$id}->{port} = $self->port;
	$self->port($self->port + 1);
    }

    return $self->portMappings->{$id}->{port};
}


sub kill_plugin {
    my ($self, $id, $pid) = @_;
    print STDERR "kill_plugin kill pid $pid with id $id\n";

    if (!exists($self->portMappings->{$id}->{pid})
	&& ($self->portMappings->{$id}->{pid} != $pid)) {
	print STDERR "ERROR: kill_plugin pid $pid was not registered with id %id\n";
    }

    return unless (defined($pid) && $pid =~ /\d+/);
    return;
    my $count = 0;
    while (waitpid($pid, WNOHANG) > 0)
    {
	while ((waitpid($pid, WNOHANG) > 0) && $count < 3)
	{
	 $count ++;
	 sleep(1);
	 kill $SIG{TERM}, $pid;
	}
	sleep(1);
	kill $SIG{KILL}, $pid;
    }
}

sub executeask {
    my ($self, $id, $exec_string) = @_;
    my @args = split /\s+/, $exec_string;
    my $cmd = $args[0];
    my ($volume, $dir, $file) = File::Spec->splitpath($cmd);
    my $pid = -1;
    print STDERR "execute ".Dumper($id, $exec_string);

    if (!exists($self->allowed_exec_paths->{$dir}) &&
	!exists($self->allowed_exec_paths->{$cmd}))
    {
	print STDERR "Not allowed to execute <$exec_string>\n";
	return $pid;
    }

    system ("kdialog  --inputbox \"command to execute\". \"$exec_string\"");

    $self->portMappings->{$id}->{exec_string} = $exec_string;
    $self->portMappings->{$id}->{pid} = $pid;
    return $pid unless ($pid ==0);
}
sub execute {
    my ($self, $id, $exec_string) = @_;
    my @args = split /\s+/, $exec_string;
    my $cmd = $args[0];
    my ($volume, $dir, $file) = File::Spec->splitpath($cmd);
    my $pid = -1;
#    system ("kdialog  --inputbox \"command to execute\". \"$exec_string\"");

    print STDERR "execute ".Dumper($id, $exec_string);

    if (!exists($self->allowed_exec_paths->{$dir}) &&
	!exists($self->allowed_exec_paths->{$cmd}))
    {
	print STDERR "Not allowed to execute <$exec_string>\n";
	return $pid;
    }

    $pid = fork();
    if (!defined($pid)) {
	print STDERR "Error invoking fork\n";
	return -1;
    }
    if ($pid == 0) 
    {
	$ENV{NPW_MESSAGE_TIMEOUT}="300";
	$ENV{NPW_DEBUG}="7";
	$ENV{NPW_LOG}="/tmp/b.out";
	sleep 1;
#	system("xwininfo -tree -root > /tmp/x.out");
#	my $exec_string = "strace -f -s 1500 -o /tmp/strace.out $exec_string";
	exec $exec_string;
    }

    $self->portMappings->{$id}->{exec_string} = $exec_string;
    $self->portMappings->{$id}->{pid} = $pid;
    return $pid unless ($pid ==0);
}

sub translate_windowid {
    my ($self, $id, $windowid) = @_;
    my $newwindowid = `kdialog --inputbox "enter winid"`;
    chomp $newwindowid;
    $self->windowid($newwindowid);
    return $self->windowid;

}


__PACKAGE__->meta->make_immutable;

