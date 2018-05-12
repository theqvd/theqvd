package QVD::HKD::Hypervisor::KUBERNETES;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use strict;
use warnings;

use version;
use Linux::Proc::Mountinfo;
use Cwd qw(realpath);

use QVD::Log;
use QVD::HKD::Config::Network qw(netvms netnodes net_aton net_ntoa netstart_n network_n netmask_n netmask_len);
use QVD::HKD::VMHandler::KUBERNETES;

use parent qw(QVD::HKD::Hypervisor);


sub new_vm_handler {
    my $self = shift;
    QVD::HKD::VMHandler::KUBERNETES->new(@_, hypervisor => $self);
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    # TODO handle authentication to the cluster (create .kube ...)

    # TODO should we check here for kubernetes version?
    # Check that network settings and firewall settings are disabled
#    $self->_create_kubernetes_config;

    # Check that Token, namespace and API url is defined
    $self->_check_kubernetes_prereq or LOGDIE "Invalid Kubernetes config detected";
    $self->_create_kubernetes_config or LOGDIE "Invalid Kubernetes config setup";;
    $self;
}

sub _k8s_api_url {
    my $self = shift;
    my $host = $ENV{$self->_cfg('hkd.vm.kubernetes.api-host-env')};
    my $port = $ENV{$self->_cfg('hkd.vm.kubernetes.api-port-env')};
    my $url = "https://$host:$port";
    $url;
}

sub _k8s_token {
    my $self = shift;


    my $token = $self->_cfg('hkd.vm.kubernetes.token');
    DEBUG "kubernetes token hkd.vm.kubernetes.token: ".(defined($token) ? "is defined" : "<undef>");
    unless ($token) {
        my $filename = $self->_cfg('hkd.vm.kubernetes.token-file');
        open(my $fh, '<', $filename) or die "cannot open file $filename";
        {
            local $/;
            $token = <$fh>;
        }
        close($fh);
        DEBUG "kubernetes token hkd.vm.kubernetes.token-file=$filename: ".(defined($token) ? $token : "<undef>");

    }
    $token;
}


sub _create_kubernetes_config {
    my $self = shift;
    
    $self->_k8s_config_set_cluster;
    $self->_k8s_config_set_credentials;
    $self->_k8s_config_set_context;
    $self->_k8s_config_use_context;
    1;
}


sub _k8s_config_set_cluster {
   my $self = shift;
    
    $self->_run('kubectl', 'config', 
                    'set-cluster', $self->_cfg('hkd.vm.kubernetes.cluster-name'),
                    '--server='.$self->_k8s_api_url,
                    '--certificate-authority='.$self->_cfg('hkd.vm.kubernetes.api-cacert-file')) 
        or LOGDIE "Error setting kubernetes cluster config";

    1;
}
sub _k8s_config_set_credentials {
    my $self = shift;
    
    $self->_run('kubectl', 'config', 
                    'set-credentials', $self->_cfg('hkd.vm.kubernetes.user'),
                    '--token='.$self->_k8s_token)
        or LOGDIE "Error setting kubernetes credentials";


    1;
}

sub _k8s_config_set_context {
    my $self = shift;
    
    $self->_run('kubectl', 'config', 
                    'set-context', $self->_cfg('hkd.vm.kubernetes.namespace'), 
                    '--cluster='.$self->_cfg('hkd.vm.kubernetes.cluster-name'),
                    '--namespace='.$self->_cfg('hkd.vm.kubernetes.namespace'),
                    '--user='.$self->_cfg('hkd.vm.kubernetes.user'))
        or LOGDIE "Error setting kubernetes context";

    1;
}

sub _k8s_config_use_context {
    my $self = shift;
    
    $self->_run('kubectl', 'config', 
                    'use-context', $self->_cfg('hkd.vm.kubernetes.namespace'))
        or LOGDIE "Error setting default kubernetes context";


    1;
}

sub _check_kubernetes_prereq {
    my $self = shift;

    return unless $self->_valid_kubernetes_settings();
    return unless $self->_valid_kubernetes_version();

    1;
}


sub _valid_kubernetes_settings {
    my $self = shift;

    if ($self->_cfg('hkd.vm.kubernetes.usefuse') &&
        ! $self->_cfg('hkd.vm.kubernetes.useprivilegedcontainer')) {
        LOGDIE "If you set hkd.vm.kubernetes.usefuse you need also to set hkd.vm.kubernetes.useprivilegedcontainer";
    }


    # TODO validate that there is
    # url
    # namespace
    # token/bearer
    #

    1;
}

sub _valid_kubernetes_version {
    my $self = shift;

    # TODO check for valid kubernetes api
    # /api and /apis
    #
    # my $kubernetes_version_str;
    # my $kubernetes_min_version_str = $self->_cfg('vm.kubernetes.minversion');
    # my $kubernetes_max_version_str = $self->_cfg('vm.kubernetes.maxversion');
    # my $kubernetes_min_version = version->declare( $kubernetes_min_version_str );
    # my $kubernetes_max_version = version->declare( $kubernetes_max_version_str );
    # my $cmd = $self->_cfg('command.kubernetes')." version --format '{{.Server.Version}}'";
    # $kubernetes_version_str = `$cmd`;
    # chomp $kubernetes_version_str;
    # if ($?) {
	# ERROR "Unable to get kubernetes version, check if kubernetes has been started";
	# return;
    # }
    # my $kubernetes_version = version->declare($kubernetes_version_str);

    # if ($kubernetes_max_version < $kubernetes_version ||
	# $kubernetes_min_version > $kubernetes_version) {
    #     ERROR "Non supported kubernetes version $kubernetes_version_str. Min version:".$self->_cfg('vm.kubernetes.minversion').", Max version:".$self->_cfg('vm.kubernetes.maxversion');
    #     return;
    # }
    # DEBUG "Supported kubernetes version found. Version: $kubernetes_version_str. Min version:".$self->_cfg('vm.kubernetes.minversion').", Max version:".$self->_cfg('vm.kubernetes.maxversion');

    1;
}


sub _run {
    my ($self, $cmd, @args) =@_;
    my @cmd = $self->_cfg("command.$cmd");
    if (length(my $args = $self->_cfg("command.$cmd.args.extra", ''))) {
        push @cmd, < $args >;
    }

    push @cmd, @args;

	my $cmd_str = join(" ", @cmd);

	DEBUG "Running command:  $cmd_str\n";

    my $ret = system(@cmd);
	if ( $? == -1 ) {
		ERROR "Failed to execute '$cmd_str': $!";
		return undef;
	} elsif ( $? & 127 ) {
		ERROR sprintf("Command '$cmd_str' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without');
		return undef;
	} elsif ( ($? >> 8) > 0 )  {
		ERROR sprintf("Command '$cmd_str' exited with signal %d", $? >> 8);
		return undef;
	} else {
		DEBUG "Command '$cmd_str' executed successfully";
	}

	1;
}
1;

