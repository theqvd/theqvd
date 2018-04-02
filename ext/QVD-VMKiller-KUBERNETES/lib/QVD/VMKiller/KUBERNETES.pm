package QVD::VMKiller::KUBERNETES;

use strict;
use warnings;

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;

sub _k8s_api_url {
    my $host = $ENV{cfg('hkd.vm.kubernetes.api-host-env')};
    my $port = $ENV{cfg('hkd.vm.kubernetes.api-port-env')};
    my $url = "https://$host:$port";
    $url;
}

sub _k8s_token {
    my $token = cfg('hkd.vm.kubernetes.token');
    DEBUG "kubernetes token hkd.vm.kubernetes.token: ".(defined($token) ? "is defined" : "<undef>");
    unless ($token) {
        my $filename = cfg('hkd.vm.kubernetes.token-file');
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

sub _k8s_config_set_cluster {
    _run('kubectl', 'config', 
         'set-cluster', cfg('hkd.vm.kubernetes.cluster-name'),
         '--server='._k8s_api_url,
         '--certificate-authority='.cfg('hkd.vm.kubernetes.api-cacert-file')) 
        or LOGDIE "Error setting kubernetes cluster config";
    1;
}
sub _k8s_config_set_credentials {
    _run('kubectl', 'config', 
         'set-credentials', cfg('hkd.vm.kubernetes.user'),
         '--token='._k8s_token)
        or LOGDIE "Error setting kubernetes credentials";
    1;
}

sub _k8s_config_set_context {
    _run('kubectl', 'config', 
         'set-context', cfg('hkd.vm.kubernetes.namespace'), 
         '--cluster='.cfg('hkd.vm.kubernetes.cluster-name'),
         '--namespace='.cfg('hkd.vm.kubernetes.namespace'),
         '--user='.cfg('hkd.vm.kubernetes.user'))
        or LOGDIE "Error setting kubernetes context";
    1;
}

sub _k8s_config_use_context {
    _run('kubectl', 'config', 
         'use-context', cfg('hkd.vm.kubernetes.namespace'))
        or LOGDIE "Error setting default kubernetes context";
    1;
}

sub _configure_kubectl {
    DEBUG "Starting: _configure_kubectl";
    _k8s_config_set_cluster;
    _k8s_config_set_credentials;
    _k8s_config_set_context;
    _k8s_config_use_context;
    1;
}


sub _get_registered_qvd_nodes {
    my @hosts = map { $_->name } QVD::DB::Simple::rs('Host')->search({}, { columns => [ 'name' ]} );
    DEBUG '_get_registered_qvd_nodes: '.join(',',@hosts);
    \@hosts;
}

sub _get_running_qvdhkd_pods {
    my @listofpods = _qx('kubectl', 'get', 'pods',
                         '-l', 'app=qvdhkd',
                         '-o', 'jsonpath={.items..metadata.name}');
    DEBUG '_get_running_qvdhkd_pods: '.join(',',@listofpods);
    \@listofpods;
}

# Receives two array refs and returns:
# elements in both arrays, the elements only in the first array,
# and the elements only in the second array
sub _calculate_differences {
    my ($set1, $set2) = @_;
    my %set1keys = map { $_ => 1 } (@$set1);
    my %set2keys = map { $_ => 1 } (@$set2);
    my %union = (%set1keys, %set2keys);
    my (@intersection, @set1onlyelems, @set2onlyelems);

    foreach my $elem (keys %union) {
        if (exists $set1keys{$elem} && exists $set2keys{$elem}) {
            push @intersection, $elem;
        } elsif (exists $set1keys{$elem}) {
            push @set1onlyelems, $elem;
        } elsif (exists $set2keys{$elem}) {
            push @set2onlyelems, $elem;
        } else {
            LOGDIE "Internal error in _calculate_differences";
        }
    }

    return (\@intersection, \@set1onlyelems, \@set2onlyelems);
}

sub _delete_from_db_not_running_qvdhkd {
    my $nodes_to_delete = shift;
    # TODO
    # Check if host_runtimes are in lost state, probably not needed
    INFO "The following qvd hosts are registered but not running as qvdhkd pods. Deleting the hosts from DB: ".join(',',@$nodes_to_delete)
        if (@$nodes_to_delete);

    foreach my $host (@$nodes_to_delete) {
        QVD::DB::Simple::rs('Host')->search({ name => $host})->delete;
    }


    1;
}

sub _get_pods_by_hkd {
    my %pods_by_hkd;
    my @listofpods = _qx('kubectl', 'get', 'pods',
                         '-l', 'app=qvdvm', 
                         '-o', '\'jsonpath={range .items[*]}{@.metadata.name}{" "}{@.metadata.labels.qvdhkd}{"\n"}{end}\'');

    foreach my $pod (@listofpods) {
        chomp $pod;
        if ($pod =~ /^(\S+)\s+(\S+)$/) {
            my ($qvdvm, $qvdhkd) = ($1, $2);
            if (exists ($pods_by_hkd{$qvdhkd})) {
                push @{$pods_by_hkd{$qvdhkd}}, $qvdvm;
            } else {
                $pods_by_hkd{$qvdhkd} = [$qvdvm];
            }
        } else {
            ERROR "Parsing pods by hkd: Line not parseable <$pod>"
                unless ($pod eq '');
        }
    }
    return \%pods_by_hkd;
}
sub _delete_dangling_hkd {
    DEBUG "Starting: _delete_dangling_hkd";

    my $qvdnodes = _get_registered_qvd_nodes;
    my $qvdhkdpods = _get_running_qvdhkd_pods;

    my ($qvdnodes_running, $hkd_pods_running_but_not_registered, $nodes_registered_but_not_running) = _calculate_differences($qvdnodes, $qvdhkdpods);
    WARN "The following qvdhkd pods are running but are not registered as qvd hosts. Perhaps they are just starting:".join(',', @$hkd_pods_running_but_not_registered)
        if (@$hkd_pods_running_but_not_registered);
    _delete_from_db_not_running_qvdhkd($nodes_registered_but_not_running);
    
    DEBUG "End: _delete_dangling_hkd";
    1;
}

sub _delete_qvdvm_pods_without_hkd {

    DEBUG "Starting: _delete_qvdvm_pods_without_hkd";

    my $qvdnodes = _get_registered_qvd_nodes;
    # Get a hashmap where the key is an qvdhkd pod name a and the value is a list of qvdvm pods associated to the hkd
    my $pods_by_hkd = _get_pods_by_hkd;
    my @hkds_from_pods = (keys %$pods_by_hkd);
    
    my ($nodes_with_pods, $nodes_without_pods, $nodes_not_registered) = _calculate_differences($qvdnodes, \@hkds_from_pods);
    # $nodes_not_registered are qvdhkd pods that are not registered
    
    my @pods_without_registered_hkd = map { @{ $$pods_by_hkd{$_} }  } (@$nodes_not_registered);
    
    if (@pods_without_registered_hkd) {

        INFO 'The following qvdhkd pods are not registered as hosts <'.
            join(',', @$nodes_not_registered).
            '> and have associated qvdvm pods <'.join(',', @pods_without_registered_hkd).'>';
        
        
        _run('kubectl', 'delete', 
             'pods', join(',', @pods_without_registered_hkd))
            or LOGDIE 'Error deleting qvdvm pods <'.join(',', @pods_without_registered_hkd).'> not associated to a registered qvdhkd <'.join(',', @$nodes_not_registered).'>';
    }

    DEBUG "End: _delete_qvdvm_pods_without_hkd";

}

sub kill_dangling_vms {
    _configure_kubectl;
    _delete_dangling_hkd;
    _delete_qvdvm_pods_without_hkd;
}


sub _qx {
    my ($cmd, @args) =@_;
    _qx_or_system_run(1, $cmd, @args);
}

sub _run {
    my ($cmd, @args) =@_;
    _qx_or_system_run(0, $cmd, @args);
}

sub _qx_or_system_run {
    my ($qx, $cmd, @args) =@_;
    my @cmd = cfg("command.$cmd");
    if (defined(my $args = cfg("command.$cmd.args.extra", -1, 0))) {
        push @cmd, < $args >;
    }

    push @cmd, @args;

	my $cmd_str = join(" ", @cmd);

	DEBUG "Running command:  $cmd_str\n";

    my $ret;
    if ($qx) {
        $ret = qx(@cmd);
    } else {
        $ret = 1;
        system(@cmd);
    }
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

	$ret;
}

1;
