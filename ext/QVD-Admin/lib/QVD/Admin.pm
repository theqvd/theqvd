package QVD::Admin;

our $VERSION = '0.01';

use warnings;
use strict;
use 5.010;

use File::Copy qw(copy move);
use File::Basename qw(basename);

use QVD::DB::Simple;
use QVD::Config;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
use QVD::Log;

my $osf_default_memory   = cfg('osf.default.memory');
my $osf_default_overlay  = cfg('osf.default.overlay');
my $osf_default_is_application = cfg('osf.default.is_application');



my $images_path          = cfg('path.storage.images');
my $case_sensitive_login = cfg('model.user.login.case-sensitive');

sub new {
    my $class = shift;
    my $quiet = shift;
    my $self = { filter => {},
                 quiet => $quiet,
                 tenant_id => undef,
                 objects => { host => 'Host',
                              vm => 'VM',
                              user => 'User',
                              config => 'Config',
                              osf => 'OSF',
                              di => 'DI' } };
    bless $self, $class;
}

sub set_filter {
    my ($self, %conditions) = @_;
    while (my ($k, $v) = each %conditions) {
        $k = 'me.id' if $k eq 'id';
        if (defined($v)) {
            if (ref $v) {
                $self->{filter}{$k} = $v;
            } elsif ($v =~ /[*?]/) {
                $v =~ s/([_%])/\\$1/g;
                $v =~ tr/*?/%_/;
                $self->{filter}{$k} = {like => $v};
            } else {
                $self->{filter}{$k} = $v;
            }
        }
    }
}

my %tenant_aware = map { $_ => 1 } qw(osf user config);
my %tenant_super  = map { $_ => 1 } qw(config);

sub set_tenant_id {
    my ($self, $tenant_id) = @_;
    $self->{tenant_id} = $tenant_id;
}

sub _tenant_id {
    my ($self, $obj) = @_;
    $self->{tenant_id} // ($tenant_super{$obj} ? -1 : 1);
}

sub reset_filter {
    shift->{filter} = {}
}

sub debug {
    db->storage->debug(1);
}

sub get_resultset {
    my ($self, $obj) = @_;
    my $db_object = $self->{objects}{$obj};
    if (!defined $db_object) {
        die("$obj: Unsupported object");
    }
    my $method = $self->can("get_result_set_for_${obj}");
    if ($method) {
        return $self->$method;
    }
    my $rs = rs($db_object);
    if ($tenant_aware{$obj}) {
        $self->{filter}{tenant_id} //= $self->_tenant_id($obj);
    }
    $rs = $rs->search($self->{filter})
        if defined $self->{filter};

    $rs
}

sub _filter_obj {
    my ($self, $term_map) = @_;
    my $filter = $self->{filter};
    while (my ($src,$dst) = each %$term_map) {
        $filter->{$dst} = delete $filter->{$src} if exists $filter->{$src}
    }
    $filter
}

sub get_result_set_for_vm {
    my ($self, @args) = @_;
    my %term_map = ( name => 'me.name',
                     osf => 'osf.name',
                     user => 'user.login',
                     host => 'host.name',
                     state => 'vm_runtime.vm_state' );
    my $filter = $self->_filter_obj(\%term_map);
    $filter->{'osf.tenant_id'} //= $self->_tenant_id('vm');

    # Be able to filter VMs by properties - #1354
    my @joins = ('osf', 'user', { vm_runtime => 'host'});
    my @prop_keys = map {/^property\.(.*)/ ? $1 : ()} keys %$filter;
    if (@prop_keys) {
        push @joins, "properties";
        foreach my $key (@prop_keys) {
            $filter->{'properties.key'} = $key;
            $filter->{'properties.value'} = delete $filter->{'properties.'.$key};
        }
    }
    rs(VM)->search($filter,
                   { join => \@joins,
                     columns => [qw(id name user_id ip osf_id di_tag)],
                     distinct => 1 })
}

sub get_result_set_for_di {
    my ($self, @args) = @_;
    my %term_map = ( name => 'me.name',
                     osf => 'osf.name',
		     tag => 'tags.tag' );
    my $filter = $self->_filter_obj(\%term_map);
    $filter->{'osf.tenant_id'} //= $self->_tenant_id('di');

    # Be able to filter VMs by properties - #1354
    my @joins = ('osf', 'tags');
    my @prop_keys = map {/^property\.(.*)/ ? $1 : ()} keys %$filter;
    if (@prop_keys) {
        push @joins, "properties";
        foreach my $key (@prop_keys) {
            $filter->{'properties.key'} = $key;
            $filter->{'properties.value'} = delete $filter->{'properties.'.$key};
        }
    }
    rs(DI)->search($filter,
                   { join => \@joins,
                     columns => [qw(id osf_id version path)],
                     distinct => 1 });
}

sub _set_equals {
    my ($a, $b) = @_;
    return 0 if scalar @$a != scalar @$b;
    my @a = sort @$a;
    my @b = sort @$b;
    foreach my $i (0 .. @a-1) {
        return 0 if $a[$i] ne $b[$i];
    }
    return 1;
}

sub _aton { unpack('N', pack('C4', split /\./, shift)) }
sub _ntoa { join '.', unpack('C4', pack('N', shift)) }

sub _get_free_ip {
    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_) => 1 } rs(VM)->get_column('ip')->all;
    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}

sub _obj_add {
    my ($self, $obj, $required_params, @args) = @_;
    my $params = ref $args[0] ? $args[0] : {@args};
    unless (_set_equals([keys %$params], $required_params)) {
        die "The required parameters are: ",
            join(", ", @$required_params), " (you supplied ",
            join(", ", keys %$params), ")";
    }
    if ($tenant_aware{$obj}) {
        $params->{tenant_id} = $self->_tenant_id($obj);
    }
    my $rs = $self->get_resultset($obj);
    $rs->create($params);
}

sub _obj_del {
    my ($self, $obj) = @_;
    my $rs = $self->get_resultset($obj);
    $rs->delete_all;
}

sub _obj_propget_rs {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};
    scalar $rs->search_related('properties', $condition);
}

sub _obj_propget { [ shift->_obj_propget_rs(@_)->all ] }

sub _obj_propset {
    my ($self, $obj, @args) = @_;
    my $params = {@args};
    my $rs = $self->get_resultset($obj);
    # In principle you should be able to avoid looping over the result set using
    # search_related but the PostgreSQL driver doesn't seem to let us
    my $ci = 0;
    my $success = 0;
    while (my $obj = $rs->next) {
        foreach my $key (keys %$params) {
            $obj->properties->search({key => $key})->update_or_create(
                { key => $key, value => $params->{$key} },
                { key => 'primary' }
            );
            $success = 1;
        }
        $ci = $ci + 1;
    }
    if (!$success) {
        $ci = -1;
    }
    $ci;
}

my $lb;
sub _assign_host {
    my ($self, $vmrt) = @_;
    if (!defined $vmrt->host_id) {
        $lb //= do {
            require QVD::L7R::LoadBalancer;
            QVD::L7R::LoadBalancer->new();
        };
        my $free_host = $lb->get_free_host($vmrt->vm) //
            die "Unable to start machine, no hosts available";

        $vmrt->set_host_id($free_host);
    }
}

sub _disconnect_user {
    my ($self, $vmrt) = @_;
    $vmrt->send_user_abort;
}

sub _lenton {
    my $len = shift;
    my $zeros = 32 - $len;
    return ((0xffffffff >> $zeros) << $zeros);
}

sub propset {
    my ($self, $object, @args) = @_;
    $self->_obj_propset($object, @args);
}

sub propget { shift->_obj_propget(@_) }

sub propget_rs { shift->_obj_propget_rs(@_) }

sub propdel {
    my ($self, $obj, @keys) = @_;
    my $rs = $self->get_resultset($obj);
    my $condition = (@keys > 0 ? {key => \@keys} : {});
    $rs->search_related('properties', $condition)->delete;
}

sub _password_to_token {
    my ($self, $password) = @_;
    require Digest::SHA;
    Digest::SHA::sha256_base64(cfg('l7r.auth.plugin.default.salt') . $password);
}

sub set_password {
    my ($self, $user, $password) = @_;
    my $row = rs('User')->find({login => $user}) or die "No such user: $user";
    $row->update({password => $self->_password_to_token($password)});
}

sub cmd_config_del {
    my ($self, @keys) = @_;

    my $rs = $self->get_resultset("config");
    my $condition = scalar @keys > 0 ? {key => \@keys} : {};

    my $ci;
    txn_do {
        $ci = $rs->search($condition)->count;
        $rs->search($condition)->delete;
        notify(qvd_config_changed);
    };
    $ci;
}

sub cmd_config_get {
    my ($self, @args) = @_;
    my $condition = scalar @args > 0 ? {key => [@args]} : {};
    my $rs = $self->get_resultset('config');
    my @configs = $rs->search($condition);
    return \@configs;
}

sub cmd_config_set {
    my ($self, %args) = @_;
    txn_do {
        my $rs = $self->get_resultset('config');
        foreach my $key (keys %args) {
            if ($key =~ /^l7r\.ssl\./) {
                warn "to set SSL keys and certificates use the 'config ssl' command\n";
            }
            else {
                $rs->update_or_create({ key => $key,
                                        tenant_id => $self->_tenant_id('config'),
                                        value => $args{$key}
                                      });
                notify(qvd_config_changed);
            }
        }
    };
}

sub cmd_config_ssl {
    my ($self, %args) = @_;
    my $cert = delete $args{cert} or die "Certificate is required";
    my $key = delete $args{key} or die "Private key is required";
    my $crl = delete $args{crl};
    my $ca = delete $args{ca};

    txn_do {
        rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.cert',
                                           value => $cert });
        rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.key',
                                           value => $key });

        if (defined $crl) {
            rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.crl',
                                               value => $crl })
        }
        else {
            rs(SSL_Config)->search({ key => 'l7r.ssl.crl' })->delete;
        }

        if (defined $ca) {
            rs(SSL_Config)->update_or_create({key => 'l7r.ssl.ca',
                                              value => $ca });
        }
        else {
            rs(SSL_Config)->search({ key => 'l7r.ssl.ca' })->delete;
        }

        notify(qvd_config_changed);
    };
    1
}

sub cmd_host_add {
    my ($self, @args) = @_;
    txn_do {
        my $row = $self->_obj_add('host',
                                  [qw/name address frontend backend/],
                                  @args, frontend => 1, backend => 1);
        rs(Host_Runtime)->create({ host_id  => $row->id,
                                   state    => 'stopped',
                                   blocked  => 'false' });
        rs(Host_Counter)->create({ host_id  => $row->id });
        $row->id
    };
}

sub cmd_host_block {
    my ($self, @args) = @_;

    my $counter;
    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('host');
        while (defined(my $host = $rs->next)) {
            $host->runtime->block;
            $counter++;
        }
        # FIXME: report errors
    };
    ($@ ? 0 : $counter);
}

sub cmd_host_block_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
        my $hostrt = rs(Host_Runtime)->find($id) //
            die "Host $id doesn't exist";
        $hostrt->block;
    };
}

sub cmd_host_del {
    shift->_obj_del('host', @_);
}

#sub cmd_host_propget {
#    shift->_obj_propget('host', @_);
#}

sub cmd_host_propset {
    shift->_obj_propset('host', @_);
}

sub cmd_host_unblock {
    my ($self, @args) = @_;
    my $counter;
    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('host');
        while (defined(my $host = $rs->next)) {
            $host->runtime->unblock;
            $counter++;
        }
        # FIXME: report errors
    };
    ($@ ? 0 : $counter)
}

sub cmd_host_unblock_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
        my $hostrt = rs(Host_Runtime)->find($id) //
            die "Host $id doesn't exist";
        $hostrt->unblock;
    };
}

my ($parser, $now);
sub _parse_datetime {
    my $spec = shift // return;

    unless ($parser) {
        require DateTime::Format::GnuAt;
        $parser = DateTime::Format::GnuAt->new;
        $now = DateTime->now(time_zone => 'local');
    }

    my $ts = eval { $parser->parse_datetime($spec, now => $now) } //
        die "invalid datetime specification '$spec'";
    $ts->set_time_zone('UTC');
    $ts;
}

sub _expire_vms {
    my ($self, $rs, $params) = @_;
    my $expire_soft = _parse_datetime delete $params->{'expire-soft'};
    my $expire_hard = _parse_datetime delete $params->{'expire-hard'};
    my $count = $rs->count;
    if ($count and (defined $expire_soft or defined $expire_hard)) {
        while (defined (my $vmrt = $rs->next)) {
            $vmrt->update({ vm_expiration_soft => $expire_soft }) if defined $expire_soft;
            $vmrt->update({ vm_expiration_hard => $expire_hard }) if defined $expire_hard;
        }
        # FIXME: notify nodes here!
        warn("$count VM have had their expiration dates set (".
             ($expire_soft // 'undef').
             ", ".
             ($expire_hard // 'undef') .
             ")!\n") if $count;
        return $count;
    }
    0;
}

sub cmd_di_add {
    my ($self, %params) = @_;

    mkdir $images_path, 0755;
    -d $images_path or die "Directory $images_path does not exist";

    my $version = delete $params{version};
    my $osf_id = delete $params{osf_id};
    my $osf_name = delete $params{osf};
    my $src = delete $params{path};
    my $file = basename($src);
    my $tmp = "$images_path/$file.tmp-" . rand;
    copy($src, $tmp) or die "Unable to copy $src to $tmp: $!\n";

    my ($id, $new_file);

    # The image may take a couple of minutes to copy, so we retry the
    # transaction a couple of times before bailing out. Otherwise adding
    # two images at the same time may fail. See trac #1166

    die 'Both OSF id and OSF name given' if defined $osf_name and defined $osf_id;
    for (1 .. 5) {
        txn_eval {
            if (defined $osf_name) {
                my $rs = rs(OSF)->search({name=>$osf_name});
                die "OSF not found" if ($rs->count() < 1);
                $osf_id = $rs->single->id;
            }
            my $osf = rs(OSF)->find($osf_id) or die "OSF not found";
            my $v = $version;
            unless (defined $v) {
                my ($y, $m, $d) = (localtime)[5, 4, 3];
                $m ++;
                $y += 1900;
                for (0..999) {
                    $v = sprintf("%04d-%02d-%02d-%03d", $y, $m, $d, $_);
                    last unless $osf->di_by_tag($v);
                }
            }
            $osf->delete_tag('head');
            $osf->delete_tag($v);
            my $rs = $self->get_resultset('di');
            my $di = $rs->create({osf_id => $osf_id, path => '', version => $v});
            $id = $di->id;
            rs(DI_Tag)->create({di_id => $id, tag => $v, fixed => 1});
            rs(DI_Tag)->create({di_id => $id, tag => 'head'});
            rs(DI_Tag)->create({di_id => $id, tag => 'default'})
                unless $osf->di_by_tag('default');
            $new_file = "$id-$file";
            $di->update({path => $new_file});
            move($tmp, "$images_path/$new_file")
                or die "Unable to move '$tmp' to its final destination at '$images_path/$new_file': $!";

            my $vms = rs(VM_Runtime)->search({ 'vm.osf_id' => $osf_id,
                                               'vm.di_tag' => 'head',
                                               'vm_state'  => { '!=' => 'stopped' } },
                                             { join => 'vm' });
            $self->_expire_vms($vms, \%params);
        };

        return $id unless $@;

        $@ =~ /concurrent update/ or last;
    }
    unlink $tmp;
    unlink "$images_path/$new_file" if defined $new_file;
    die;
}

sub cmd_di_tag {
    my ($self, %params) = @_;
    my @required_params = qw/di_id tag/;
    my $di_id = delete $params{di_id};
    my $tag = delete $params{tag};
    my $id;
    txn_do {
        ## #760: pay attention to OSFs
        my $osf_id = rs(DI)->find($di_id)->osf_id;
        my @ids = map { $_->id } rs(DI)->search({osf_id => $osf_id});
        rs(DI_Tag)->search({tag => $tag, fixed => 1, di_id => \@ids})->first 
            and die "There is a DI with the tag $tag fixed\n";
        rs(DI_Tag)->search({tag => $tag, di_id => \@ids})->delete_all;
        $id = rs(DI_Tag)->create({di_id => $di_id, tag => $tag});

        my $rs = rs(VM_Runtime)->search( { 'vm.osf_id' => $osf_id,
                                           'vm.di_tag' => $tag,
                                           'vm_state' => { '!=' => 'stopped' },
                                           'current_di_id' => { '!=' => $di_id } },
                                         { join => 'vm' } );
        $self->_expire_vms($rs, \%params);
    };
    $id;
}

sub cmd_di_untag {
    my ($self, %params) = @_;
    my @required_params = qw/di_id tag/;
    my $di_id = delete $params{di_id};
    my $tag = delete $params{tag};
    txn_do {
        my $old = rs(DI_Tag)->search({tag => $tag, di_id => $di_id})->first;
        $old or die "DI $di_id is not tagged as $tag\n";
        $old->fixed and die "DI $di_id tag $tag is fixed\n";
        $old->delete;

        my $osf_id = rs(DI)->find($di_id)->osf_id;
        my $rs = rs(VM_Runtime)->search( { 'vm.osf_id' => $osf_id,
                                           'vm.di_tag' => $tag,
                                           'vm_state' => { '!=' => 'stopped' },
                                           'current_di_id' => $di_id },
                                         { join => 'vm' } );
        $self->_expire_vms($rs, \%params);
    };
    1
}

sub cmd_di_del {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('di');
    while (my $di = $rs->next) {
        if ($di->vm_runtimes->count == 0) {
            ## #759: reassign 'default' and 'head' tags to another DI. Using the most recent DI here.
            foreach my $tag (qw/default head/) {
                next unless $di->has_tag ($tag);
                my @potentials = grep { $_->id ne $di->id } $di->osf->dis;
                if (@potentials) {
                    my $new_di = $potentials[-1];
                    $self->cmd_di_tag (di_id => $new_di->id, tag => $tag);
                }
            }
            #warn "deleting di ".$di->id;
            $di->delete;
            $counter++;
            # FIXME Should we delete the actual image file?
        }
    }
    $counter
}

sub cmd_di_propset {
    shift->_obj_propset('di', @_);
}

sub cmd_osf_add {
    my ($self, %params) = @_;
    my @required_params = qw/name memory use_overlay/;

    # FIXME: detect type of image and set use_overlay accordingly, iso => no overlay
    $params{memory}      //= $osf_default_memory;
    $params{use_overlay} //= $osf_default_overlay;
    $params{tenant_id}   //= $self->_tenant_id('osf');
    $params{is_application} //= $osf_default_is_application;

    #die "The required parameters are ".join(", ", @required_params)
    #    unless _set_equals([keys %params], \@required_params);

    if ($params{'user_storage_size'}) {
        $params{'user_storage_size'} =~ s/\s+//g;
        if ($params{'user_storage_size'} =~ /^(.*)kb?$/i) {
            $params{'user_storage_size'} = int ($1 * 1024);
        } elsif ($params{'user_storage_size'} =~ /^(.*)mb?$/i) {
            $params{'user_storage_size'} = int ($1 * 1024*1024);
        } elsif ($params{'user_storage_size'} =~ /^(.*)gb?$/i) {
            $params{'user_storage_size'} = int ($1 * 1024*1024*1024);
        }
    }

    my $id;
    txn_do {
        my $rs = $self->get_resultset('osf');
        # use Data::Dumper;
        # print Dumper $self;
        my $row = $rs->create(\%params);
        $id = $row->id;
    };
    $id
}

sub cmd_osf_del {
    my ($self, @args) = @_;
    my $counter = 0;
    my $rs = $self->get_resultset('osf');
    while (my $osf = $rs->next) {
        if ($osf->vms->count == 0) {
            #warn "deleting osf ".$osf->id;
            $osf->delete;
            $counter++;
        }
    }
    $counter
}

sub cmd_osf_propset {
    shift->_obj_propset('osf', @_);
}

sub cmd_user_add {
    my ($self, %params) = @_;

    ## Previously if the user didn't specify any parameter, this line populated the
    ## hash with undef values. Then, the call to _set_equals in _obj_add returned
    ## true, and we hit a SQL NOT NULL constraint at a deep layer. Now the syntax
    ## is checked beforehand so this won't happen anymore.
    my ($u, $p) = delete @params{qw/login password/};
    $u =~ s/^\s*//; $u =~ s/\s*$//;
    $u = lc $u unless $case_sensitive_login;
    my %core_params = ( login => $u, password => $self->_password_to_token($p) );

    $self->_obj_add('user', [qw/login password/], %core_params)->id;
}

sub cmd_user_del {
    shift->_obj_del('user', @_);
    # FIXME Should we delete VMs, overlay images and home disk files?
}

#sub cmd_user_propget {
#    shift->_obj_propget('user', @_);
#}

sub cmd_user_propset {
    shift->_obj_propset('user', @_);
}

sub cmd_vm_add {
    my ($self, %params) = @_;
    txn_do {
        if (exists $params{osf}) {
            my $key = $params{osf};
            my $rs = rs(OSF)->search({name => $key});
            die "$key: No such OSF" if ($rs->count() < 1);
            warn "overriding supplied param 'osf_id'\n" if defined $params{osf_id};
            $params{osf_id} = $rs->single->id;
            delete $params{osf};
        }
        if (exists $params{user}) {
            my $key = $params{user};
            my $rs = rs(User)->search({login => $key});
            die "$key: No such user" if ($rs->count() < 1);
            warn "overriding supplied param 'user_id'\n" if defined $params{user_id};
            $params{user_id} = $rs->single->id;
            delete $params{user};
        }
        $params{storage} = '';
        $params{di_tag} //= 'default';
        my $row;
        my $bulk = delete $params{bulk};
        if (defined $bulk) {
            for my $i (0..$bulk-1) {
                my %p = %params;
                $p{name} .= "-$i";
                $p{ip} = $self->_get_free_ip;
                $row = $self->_obj_add('vm', [qw/name user_id osf_id ip storage di_tag/],
                                       \%p);
                rs(VM_Runtime)->create({vm_id         => $row->id,
                                        vm_state      => 'stopped',
                                        user_state    => 'disconnected',
                                        blocked       => 'false'});
                rs(VM_Counter)->create({ vm_id  => $row->id });
            }
        }
        else {
            unless ($params{ip}) {
                $params{ip} = $self->_get_free_ip;
                INFO "assigned IP: $params{ip}";
            }

            $row = $self->_obj_add('vm', [qw/name user_id osf_id ip storage di_tag/],
                                  \%params);
            rs(VM_Runtime)->create({vm_id         => $row->id,
                                    vm_state      => 'stopped',
                                    user_state    => 'disconnected',
                                    blocked       => 'false'});
            rs(VM_Counter)->create({ vm_id  => $row->id });
        }
        $row->id
    };
}

sub cmd_vm_block {
    my ($self, @args) = @_;
    my $counter;
    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('vm');
        while (defined(my $vm = $rs->next)) {
            $vm->vm_runtime->block;
            $counter++;
        }
        # FIXME: report errors
    };
    ($@ ? 0 : $counter)
}

sub cmd_vm_block_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
        my $vmrt = rs(VM_Runtime)->find($id) //
            die "VM $id doesn't exist";
        $vmrt->block;
    };
}

sub cmd_vm_del {
    my ($self, @args) = @_;
    my $rs = $self->get_resultset('vm');
    # Checks if vm is running
    while (my $vm = $rs->next) {
        if ($vm->vm_runtime->vm_state eq 'stopped') {
            $vm->delete;
        }
    }
    # FIXME Should we delete the overlay image and home disk file?
}

sub cmd_vm_disconnect_user {
    my ($self, @args) = @_;
    my $counter;
    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('vm');
        while (defined(my $vm = $rs->next)) {
            $self->_disconnect_user($vm->vm_runtime);
            $counter++;
        }
        # FIXME: report errors
    };
    ($@ ? 0 : $counter)
}

sub cmd_vm_disconnect_user_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
        my $vmrt = rs(VM_Runtime)->find($id) //
            die "VM $id doesn't exist";
        $self->_disconnect_user($vmrt);
    };
}

# FIXME: this is completely unsafe and crazy!
# It allows to change database fields at will from the admin tool

sub cmd_vm_edit {
    my ($self, %args) = @_;
    my $counter;

    my (%expire, @clean_expire);
    for (qw(soft hard)) {
        if (defined(my $arg = delete $args{"expire-$_"})) {
            if (length $arg) {
                $expire{$_} = _parse_datetime($arg);
            }
            else {
                push @clean_expire, $_;
            }
        }
    }

    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('vm');
        my @vm_columns = $rs->result_source->columns;
        while (defined(my $vm = $rs->next)) {
            my (%vm_args, %vm_runtime_args);
            foreach my $k (keys %args) {
                if (grep { $_ eq $k } @vm_columns) {
                    $vm_args{$k} = $args{$k};
                } else {
                    $vm_runtime_args{$k} = $args{$k};
                }
            }
            $vm->update (\%vm_args);

            my $vmrt = $vm->vm_runtime;
            $vmrt->update (\%vm_runtime_args);

            if (%expire) {
                if ($vmrt->vm_state ne 'stopped') {
                    my $di = $vm->di;
                    if (not defined $di or $di->id != $vmrt->current_di_id) {
                        $vmrt->update({ "vm_expiration_$_" => $expire{$_} })
                            for keys %expire;
                    }
                    else {
                        $vmrt->update({ "vm_expiration_$_" => undef })
                            for keys %expire;
                    }
                }
            }

            $vmrt->update({"vm_expiration_$_" => undef})
                for @clean_expire;

            $counter++;
        }
        # FIXME: report errors
    };

    ($@ ? 0 : $counter);
}

# sub cmd_vm_propget {
#    shift->_obj_propget('vm', @_);
# }

sub cmd_vm_propset {
    shift->_obj_propset('vm', @_);
}

sub cmd_vm_start {
    my ($self, @args) = @_;
    my $counter = 0;
    my %host;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
        for (1..5) {
            $counter++ if txn_eval {
                my $vmrt = $vm->vm_runtime;
                $vmrt->can_send_vm_cmd('start') or return;
                $self->_assign_host($vmrt);
                $vmrt->send_vm_start;
                $host{$vmrt->host_id}++;
                1;
            };
            $@ or last;
        }
        $@ and ERROR $@;
    }

    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    $counter;
}

sub cmd_vm_start_by_id {
    my ($self, @ids) = @_;
    scalar @ids or die "Missing parameter id";
    my %hosts = ();
    my %vms_with_error = ();
    foreach my $id (@ids) {
        for (1..5) {
            txn_eval {
                my $vmrt = rs(VM_Runtime)->find($id) //
                die "VM $id doesn't exist";
                $self->_assign_host($vmrt);
                $vmrt->send_vm_start;
                $hosts{$vmrt->host_id} = 1;
            };
            $@ or last;
        }
        if ($@) {
            $vms_with_error{$id} = $@;
            ERROR $@;
        }
    }
    for (keys %hosts) { 
        notify("qvd_cmd_for_vm_on_host$_");
    }
    return %vms_with_error;
}

sub cmd_vm_stop {
    my ($self, @args) = @_;
    my $counter = 0;
    my %host;
    my $rs = $self->get_resultset('vm');
    while (defined(my $vm = $rs->next)) {
        for (1..5) {
            $counter++ if txn_eval {
                my $vmrt = $vm->vm_runtime;
                if ($vmrt->can_send_vm_cmd('stop')) {
                    $vmrt->send_vm_stop;
                    $host{$vmrt->host_id}++;
                    return 1;
                }
                else {
                    no warnings 'uninitialized';
                    if ($vmrt->vm_state eq 'stopped' and
                        $vmrt->vm_cmd eq 'start') {
                        $vmrt->update({ vm_cmd => undef });
                        return 1;
                    }
                }
                0
            };
            $@ or last;
        }
        $@ and ERROR $@;
    }

    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    $counter;
}

sub cmd_vm_stop_by_id {
    my ($self, @ids) = @_;
    scalar @ids or die "Missing parameter id";
    my %hosts = ();
    my %vms_with_error = ();
    for my $id (@ids) {
        for (1..5) {
            txn_eval {
                my $vm = rs(VM_Runtime)->find($id) //
                die "VM $id doesn't exist";
                $vm->send_vm_stop;
                my $host_id = $vm->host_id;
                $hosts{$host_id} = 1;
            };
            $@ or last;
        }
        if ($@) {
            $vms_with_error{$id} = $@;
            ERROR $@;
        }
    }
    foreach (keys %hosts) {
        notify("qvd_cmd_for_vm_on_host$_");
    }
    return %vms_with_error;
}

sub cmd_vm_unblock {
    my ($self, @args) = @_;
    my $counter;
    txn_eval {
        $counter = 0;
        my $rs = $self->get_resultset('vm');
        while (defined(my $vm = $rs->next)) {
            $vm->vm_runtime->unblock;
            $counter++;
        }
        # FIXME: report errors
    };
    ($@ ? 0 : $counter);
}

sub cmd_vm_unblock_by_id {
    my ($self, $id) = @_;
    $id // die "Missing parameter id";
    txn_do {
        my $vmrt = rs(VM_Runtime)->find($id) //
            die "VM $id doesn't exist";
        $vmrt->unblock;
    };
}

1;

__END__

=head1 NAME

QVD::Admin - QVD Administration API

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::Admin;
    my $admin = QVD::Admin->new;
    my $id = $admin->cmd_osf_add(name => "Ubuntu 9.10 (x86)", 
                                 memory => 512,
                                 use_overlay => 1,
                                 disk_image => "/var/tmp/U910_x86.img");
    print "OSF added with id $id\n";

    $admin->set_filter(user=> 'qvd');
    my $count = $admin->cmd_vm_start();
    print "Started $count virtual machines.\n";

=head1 DESCRIPTION

This module implements the QVD Administration API.

=head2 API

=over

=item set_filter(%conditions)

Add conditions to the current filter. The filter is applied to all subsequent
operations. The keys that can be used depend on the object in question. 

=item reset_filter()

Removes all conditions from the filter.

=item get_resultset($object)

Return the DBIx::Class result set for the given object type. The valid object
types are listed in the "objects" member hash. They are host, vm, uesr, config,
and osf.

=item cmd_host_add(%parameters)

Add a host. The required parameters are name and address. 

Returns the id of the new host. 

=item cmd_vm_add(%parameters)

Add a virtual machine. The required parameters are name, user, osf, and ip.
OSF and user can be specified by name (login) or by id (osf_id, user_id). The
optional parameter is storage.

Returns the id of the new virtual machine. 

=item cmd_user_add(%parameters)

Adds a user. The required parameters are login and password.

Returns the id of the new user.

=item cmd_osf_add(%parameters)

Adds an operating system image. The required parameters are name and
disk_image. The value of disk_image should be the path of a disk image file.
The image file is copied to the read only storage area.  The optional
parameters are memory (megabytes), user_storage_size (megabytes), and
use_overlay (y/n).

=item cmd_host_del()

Deletes all hosts that match the current filter.

=item cmd_user_del()

Deletes all users that match the current filter.

=item cmd_vm_del()

Deletes all virtual machines that match the current filter.

=item cmd_osf_del()

Deletes all OSFs that match the current filter. Only OSFs that have no virtual
machines assigned are deleted. Returns the number of OSFs that were deleted.

=item propset($object, %properties)

Set the given properties on all $objects (hosts, vms, users) that are matched
by the current filter.

The parameter $object must be either "host", "vm", or "user".

=item cmd_host_propset(%properties)

Wrapper for propset('host', %properties).

=item cmd_vm_propset(%properties)

Wrapper for propset('vm', %properties).

=item cmd_user_propset(%properties)

Wrapper for propset('user', %properties).

=item propget($object, @keys)

Returns the properties with given keys for the $objects that are matched by the
current filter. 

The parameter $object must be either "host", "vm", or "user".

The return value is a reference to a list of the DBIx::Class::Row objects that
represent the individual property entries.

=item cmd_host_propget(@keys)

Wrappper for propget('host', @keys).

=item cmd_vm_propget(@keys)

Wrappper for propget('vm', @keys).

=item cmd_user_propget(@keys)

Wrappper for propget('user', @keys).

=item propdel($object, @keys)

Deletes the properties with the given keys for the $objects that are matched by
the current filter.

The parameter $object must be either "host", "vm", or "user".

Returns whatever the DBIx::Class::Resultset->delete call returns.

=item cmd_config_set(%configs)

Sets configuration keys to values.

=item cmd_config_get(@keys)

Returns the configuration table entries with the given keys.

The return value is a reference to a list of the DBIx::Class::Row objects that
represent the individual configuration entries.

=item cmd_vm_start_by_id($id)

Assigns the virtual machine with id $id to a host and starts it.

Throws an exception using "die" if it wasn't possible to start the vm.

=item cmd_vm_start()

Assigns the virtual machines matched by the current filter to hosts and starts
them. Any errors that ocurred are ignored. 

Returns the number of virtual machines that were succesfully started.

=item cmd_vm_stop_by_id($id)

Schedules the stopping of the virtua machine with the given id.

Throws an exception using "die" if it wasn't possible to stop the vm.

=item cmd_vm_stop()

Schedules the stopping of the virtual machines matched by the current filter.
Any errors that ocurred are ignored. 

Returns the number of virtual machines that were succesfully scheduled to stop.

=item cmd_vm_disconnect_user()

Disconnects the users connected to the virtual machines matched by the current
filter.

Returns the number of users that were disconnected.

=item cmd_config_ssl(cert => 'certificate', key => 'privatekey', crl => 'crl')

Sets the SSL certificate to 'certificate' and the private key to 'privatekey'.
Returns 1 on success.

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
