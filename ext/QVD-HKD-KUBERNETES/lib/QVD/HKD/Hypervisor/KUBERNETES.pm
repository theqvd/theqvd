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
    # TODO should we check here for kubernetes version?
    # Check that network settings and firewall settings are disabled
    # Check that Token, namespace and API url is defined
    $self->_check_kubernetes_prereq or LOGDIE "Invalid Kubernetes config detected";
    $self
}

sub _check_kubernetes_prereq {
    my $self = shift;

    return unless $self->_valid_kubernetes_settings();
    return unless $self->_valid_kubernetes_version();

    1;
}


sub _valid_kubernetes_settings {
    my $self = shift;

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


1;

