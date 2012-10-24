package QVD::AdminCLI;

use warnings;
use strict;

use QVD::Config;
use QVD::Admin;
use Text::Table;
use DateTime;

my %syntax_check_cbs = (
    host => {
        add => sub {
            my ($errors, $args) = @_;

            $$errors++, warn "Syntax error: parameter 'name' is mandatory\n",    unless exists $args->{'name'};
            $$errors++, warn "Syntax error: parameter 'address' is mandatory\n", unless exists $args->{'address'};
            delete @$args{qw/name address/};
        },
    },
    config => {
        ssl => sub {
            my ($errors, $args) = @_;

            $$errors++, warn "Syntax error: parameter 'key' is mandatory\n",  unless exists $args->{'key'};
            $$errors++, warn "Syntax error: parameter 'cert' is mandatory\n", unless exists $args->{'cert'};
            delete @$args{qw/key cert ca crl/};
        },
    },
    osf => {
        add => sub {
            my ($errors, $args) = @_;
            $$errors++, warn "Syntax error: parameter 'name' is mandatory\n", unless exists $args->{'name'};
            delete @$args{qw/name memory use_overlay user_storage_size/};
        },
    },
    di => {
       add => sub {
            my ($errors, $args) = @_;
            $$errors++, warn "Syntax error: parameter 'osf_id' is mandatory\n",  unless exists $args->{'osf_id'};
            $$errors++, warn "Syntax error: parameter 'path' is mandatory\n", unless exists $args->{'path'};
            delete @$args{qw/osf_id path/};
        },
        tag => sub {
            my ($errors, $args) = @_;
            $$errors++, warn "Syntax error: parameter 'di_id' is mandatory\n",  unless exists $args->{'di_id'};
            $$errors++, warn "Syntax error: parameter 'tag' is mandatory\n",  unless exists $args->{'tag'};
            delete @$args{qw/di_id tag/};
        },
        untag => sub {
            my ($errors, $args) = @_;
            $$errors++, warn "Syntax error: parameter 'di_id' is mandatory\n",  unless exists $args->{'di_id'};
            $$errors++, warn "Syntax error: parameter 'tag' is mandatory\n",  unless exists $args->{'tag'};
            delete @$args{qw/di_id tag/};
        },
    },
    user => {
        add => sub {
            my ($errors, $args) = @_;

            $$errors++, warn "Syntax error: parameter 'login' is mandatory\n",    unless exists $args->{'login'};
            $$errors++, warn "Syntax error: parameter 'password' is mandatory\n", unless exists $args->{'password'};
            delete @$args{qw/login password/};
        },
        passwd => sub {
            my ($errors, $args) = @_;

            $$errors++, warn "Syntax error: parameter 'user' is mandatory\n", unless exists $args->{'user'};
            ## se peta: 'Undefined subroutine &QVD::AdminCLI::rs called'
            #$$errors++, warn "Error: user '$args->{'user'}' not found\n"      unless rs ('User')->find ({ login => $args->{'user'} });
            delete @$args{qw/user/};
        },
    },
    vm => {
        add => sub {
            my ($errors, $args) = @_;
            $$errors++, warn "Syntax error: either parameter 'osf_id' or 'osf' is mandatory\n",  if !exists $args->{'osf_id'} and !exists $args->{'osf'};
            $$errors++, warn "Syntax error: either parameter 'user_id' or 'user' is mandatory\n", if !exists $args->{'user_id'} and !exists $args->{'user'};
            $$errors++, warn "Syntax error: parameters 'osf_id' and 'osf' are mutually exclusive\n",  if exists $args->{'osf_id'} and exists $args->{'osf'};
            $$errors++, warn "Syntax error: parameters 'user_id' and 'user' are mutually exclusive\n", if exists $args->{'user_id'} and exists $args->{'user'};
            $$errors++, warn "Syntax error: parameter 'name' is mandatory\n", unless exists $args->{'name'};
            delete @$args{qw/osf_id osf user_id user name ip di_tag/};
        },
    },
);

sub new {
    my ($class, $quiet) = @_;
    my $admin = QVD::Admin->new;
    my $self = {
        admin => $admin,
        quiet => $quiet,
    };
    bless $self, $class;
}

sub _split_on_equals {
    # FIXME: actually, improve me!
    map { my @a = split /=/, $_, 2; $a[0] => $a[1] } @_;
}

sub set_filter {
    my ($self, $filter_string) = @_;
    my @filter_array = split /,/, $filter_string; 
    my %conditions = _split_on_equals(@filter_array);
    $self->{admin}->set_filter(%conditions);
}

sub get_resultset {
    shift->{admin}->get_resultset(@_);
}

sub dispatch_command {
    my ($self, $object, $command, $help, @args) = @_;
    $self->die_and_help ("Valid command expected") unless defined $object;
    $self->die_and_help ("$object: Valid command expected", $object) unless defined $command;
    my $method = $self->can($help ? "help_${object}_${command}" : "cmd_${object}_${command}");
    if (defined $method) {
        $help or $self->_syntax_check ($object, $command, @args);
        $self->{admin}{current_object} = $object;
        $self->$method(@args);
    } else {
        $self->die_and_help ("$object: '$command' not implemented", $object);
    }
}

sub _syntax_check {
    my $self = shift;
    my $obj  = shift;
    my $cmd  = shift;
    my %args = _split_on_equals(@_);
    $self->{errors} = 0;

    if (exists $syntax_check_cbs{$obj}{$cmd}) {
        $syntax_check_cbs{$obj}{$cmd}->(\$self->{errors}, \%args);
    }

    ## choke on not-yet-handled arguments, except for the following
    ## - '* edit'
    ## - 'vm ssh ' 
    ## - '* propdel', '* propget', '* propset'
    ## - 'config *'   (but not 'config ssl', which has been already handled)
    if (%args and
        $cmd ne 'edit' and
        not ($obj eq 'vm' and $cmd eq 'ssh') and
        $cmd !~ /^prop(?:del|get|set)$/ and
        ($obj ne 'config' or $cmd eq 'ssl')) {

        $self->{errors}++;
        warn sprintf "Syntax error: too many arguments: '%s'\n", join q{', '}, sort keys %args;
    }

    if ($self->{errors}) {
        warn "$self->{errors} error".($self->{errors} > 1 ? 's' : '')." encountered\n";

        if (my $help_cb = $self->can("help_${obj}_${cmd}")) {
            print "\n";
            $help_cb->();
        }
        exit 1;
    }
}

sub _format_timespan {
    my $seconds = shift;
    my $secs = $seconds % 60;
    my $mins = ($seconds /= 60) % 60;
    my $hours = ($seconds /= 60);
    return sprintf "%02d:%02d:%02d", $hours, $mins, $secs;
}

sub _print_header {
    my @titles = @_;
    print join("\t", @titles)."\n";
    print join("\t", map { s/./-/g; $_ } @titles)."\n";
}

sub _print_table {
    my ($self, $header, $body) = @_;
    
    my $tb = Text::Table->new(@$header);
    $tb->load(@$body);
    
    print $tb->title unless $self->{quiet};
    print $tb->rule( '-', '+') unless $self->{quiet};
    print $tb->body;
}

sub _die {
    my ($self, $msg) = @_;
    $msg //= $@;
    chomp $msg;
    print STDERR "Error: $msg\n" unless $self->{quiet};
    exit 1;
}

sub die_and_help {
    my ($self, $message, $obj) = @_;
    $message = "Unknown error" unless defined($message);
    my @funcs = do {
        no strict;
        grep exists &{"QVD::AdminCLI::$_"}, keys %{"QVD::AdminCLI::"};
    };
    
    @funcs = grep {s/^cmd_([a-z]+)_(\w+)/$1 $2/} @funcs;
    @funcs = grep {m/^${obj}/} @funcs if defined $obj and exists $self->{admin}{objects}{$obj};
    my $footer = '';
    for (grep { /^di (?:add|del)$/ } @funcs) {
        $footer = "(*) Needs root privileges\n\n";
        $_ .= ' (*)';
    }
    
    print $message.", available subcommands:\n   ";
    print join "\n   ", sort @funcs;
    print "\n\n$footer";
    
    exit 1;
}

sub _print {
    my ($self, @msg) =(@_);
    print @msg, "\n" unless $self->{quiet};
}

sub _obj_del {
    my ($self, $obj) = @_;

    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete all ${obj}s? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }

    my $count = $self->get_resultset($obj)->count();
    $self->_print("Deleting ".$count." ${obj}(s)");
}

sub _obj_propget {
    my ($self, $display_cb, @args) = @_;
    eval {
        my $props = $self->{admin}->propget(@args);
        print map { &$display_cb($_)."\t".$_->key.'='.$_->value."\n" } @$props;
    };

    if ($@) {
        #$self->_print("Wrong syntax, check the command help.\n");
        $self->_die;
    }
}

sub _config_pairs {
    my $self = shift;
    my %pairs;

    my $configs;
    eval {
        $configs = $self->{admin}->cmd_config_get(@_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
    my @to_ret = @_ ? @_ : grep { $_ !~ /^internal\./ } cfg_keys;
    foreach my $k (@to_ret) {
        if (my $c = (grep { $_->key eq $k } @$configs)[0]) {
            $pairs{ $c->key } = $c->value;
        } else {
            my $val;
            eval { $val = cfg ($k); 1; } and $pairs{$k} = $val;
        }
    }

    return %pairs;
}

sub cmd_config_del {
    my $self = shift;
    my $ci = 0;
    if (scalar @_ eq 0) {
        print "Are you sure you want to delete all configuration variables? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    } 
    eval {
        $ci = $self->{admin}->cmd_config_del(@_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
    $self->_print("$ci config entries deleted.\n");
}

sub help_config_del {
    print <<EOT
host del: Deletes config properties.
usage: condif del [key...]
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_config_get {
    my $self = shift;
    my %pairs = $self->_config_pairs (@_);
    printf "%s=%s\n", $_, $pairs{$_} for sort keys %pairs;
}

sub help_config_get {
    print <<EOT
config get: Gets config property.
usage: config get [key...]
      
  Example:
  config get vm_ssh_port base_storage_path
EOT
}

sub cmd_config_set {
    my $self = shift;
    my %args = _split_on_equals(@_);
    eval {
        $self->{admin}->cmd_config_set(%args);
    };
    if ($@ || (scalar keys %args == 0)) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_config_set {
    print <<EOT
config set: Sets config property.
usage: config set [key=value ...]
      
  Example:
  config set vm_ssh_port=2022 base_storage_path=/var/run/qvd/storage
EOT
}

sub cmd_config_ssl {
    my $self = shift;
    my %args = _split_on_equals(@_);
    my $key_file = delete $args{key};
    my $cert_file = delete $args{cert};
    my $crl_file = delete $args{crl};
    my $ca_file = delete $args{ca};

    # FIXME: Is using File::Slurp the best way?
    use File::Slurp; 
    my $cert = eval { read_file($cert_file) }
        or $self->_die ("$cert_file: Unable to read cert file: $^E\n");
    my $key = eval { read_file($key_file)   }
        or $self->_die ("$key_file: Unable to read key file: $^E\n");
    my $crl;
    if (defined $crl_file) {
        $crl = eval { read_file($crl_file) }
            or $self->_die ("$crl_file: Unable to read crl file: $^E\n");
    }
    my $ca;
    if (defined $ca_file) {
        $ca = eval { read_file($ca_file) }
            or $self->_die ("$ca_file: Unable to read ca file: $^E\n");
    }

    eval {
        $self->{admin}->cmd_config_ssl(key => $key, cert => $cert, crl => $crl, ca => $ca);
    };
    if ($@) {
        $self->_die;
    } else {
        $self->_print("SSL certificate, private key, ca and crl set.\n");
    }
}

sub help_config_ssl {
    print <<EOT
config ssl: Sets the SSL certificate and private key
usage: config ssl key=mykey.pem cert=mycert.pem [ca=ca.pem] [crl=crl.pem]

    Sets the SSL certificate to the one read from the file mycert.pem, and the
    private key to the one read from mykey.pem.

    Example: config ssl key=certs/server-key.pem cert=certs/server-cert.pem

    If you want to use client certificates, you can also set a CRL
    file to blacklist invalid ones. Note that If you are using a
    custom CA for signing your client certificates you must also add
    it to /etc/ssl/certs in all the QVD nodes.

EOT
}

sub cmd_host_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    eval {
        my $id = $self->{admin}->cmd_host_add(%args);
        $self->_print("Host added with id ".$id);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_host_add {
    print <<EOT
host add: Adds hosts.
usage: host add name=value address=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_host_block {
    my $self = shift;
    
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to block all hosts? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        $self->{admin}->cmd_host_block();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }      
}

sub help_host_block {
    print <<EOT
host block: Excludes the matched hosts from the production environment.
usage: host block
       
Valid options:
    -f [--filter] FILTER : block only host matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_host_del {
    my $self = shift;
    eval {
        $self->_obj_del('host', @_);
        $self->{admin}->cmd_host_del();
    };
    if ($@) {
        #$self->_print("Wrong syntax or host assigned to virtual machines, check the command help:\n");
        $self->_die;
    }
}

sub help_host_del {
    print <<EOT
host del: Deletes hosts.
usage: host del
       
Valid options:
    -f [--filter] FILTER : deletes hosts matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_host_list {
    my ($self) = @_;

    my $rs = $self->get_resultset('host');
    my @header = ("Id", "Name", "Address ","HKD", "Usable RAM", "Usable CPU", "VMs assigned", "Blocked", "State");
    my @body;

    eval {
        while (my $host = $rs->next) {
            my $mins;
            my $hkd_ts = defined $host->runtime ? $host->runtime->ok_ts : undef;

            if (!defined $hkd_ts) {
                $mins = '-';
            } elsif ($hkd_ts =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})\.(\d+)/) {
                $hkd_ts = DateTime->new (
                    year => $1, month => $2, day => $3,
                    hour => $4, minute => $5, second => $6,
                    nanosecond => 1000 * $7
                )->epoch;
                $mins = _format_timespan(time - $hkd_ts);
            } elsif ($hkd_ts =~ /^\d+$/) {
                $mins = _format_timespan(time - $hkd_ts);
            } else {
                warn 'bad hkd ts format';
                $mins = '-';
            }

            my @row = ($host->id, $host->name, $host->address, $mins,
                       $host->runtime->usable_ram, $host->runtime->usable_cpu,
                       $host->vms->count, $host->runtime->blocked, $host->runtime->state);
            push(@body, \@row);
        }
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
    
    $self->_print_table(\@header, \@body);
}

sub help_host_list {
    print <<EOT
host list: list the hosts registered on the platform
usage: host list
    
  Lists consists of Id, Name, Address, HKD and VMs assigned, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only hosts matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    name
    address
EOT
}

sub cmd_host_propdel {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete the prop in all hosts? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }
    eval {
        $self->{admin}->propdel('host', @_);        
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_host_propdel {
    print <<EOT
vm propdel: Deletes host properties.
usage: host propdel [key...]

    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
        host propdel priority -f address=198.168.1.??
      
Valid options:
    -f [--filter] FILTER : Delete properties of hosts matched by FILTER
EOT
}

sub cmd_host_propget {
    shift->_obj_propget(sub { $_->host->name }, 'host', @_);
}

sub help_host_propget {
    print <<EOT
host propget: Gets host property.
usage: host propget [key...]
      
  Example:
  host propget usage priority
      
Valid options:
    -f [--filter] FILTER : gets host property only from hosts matched by FILTER
EOT
}

sub cmd_host_propset {
    my $self = shift;
    my $ci = 0;
    eval {
        $ci = $self->{admin}->cmd_host_propset(_split_on_equals @_);
    };
    if (($ci == -1) || $@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print("propset in $ci hosts.\n");
    }
}

sub help_host_propset {
    print <<EOT
host propset: Sets host property.
usage: host propset [key=value...]
      
  Example:
  host propset weight=50kg maxtemp=56º
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub cmd_host_unblock {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to unblock all hosts? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        $self->{admin}->cmd_host_unblock();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }    
}

sub help_host_unblock {
    print <<EOT
host unblock: Includes the matched hosts from the production environment.
usage: host unblock
       
Valid options:
    -f [--filter] FILTER : unblock only host matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_host_counters {
    my ($self) = @_;

    my $rs = $self->get_resultset('host');
    my @header = ("Id", "Name", "HTTP Requests ","Auth attempts", "Auth OK", "NX attempts", "NX OK", "Short sessions");
    my @body;

    eval {
        while (my $host = $rs->next) {

            my @row = (
                $host->id, $host->name,
                $host->counters->http_requests,
                $host->counters->auth_attempts, $host->counters->auth_ok,
                $host->counters->nx_attempts, $host->counters->nx_ok,
                $host->counters->short_sessions,
            );
            push(@body, \@row);
        }
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
    
    $self->_print_table(\@header, \@body);
}

sub help_host_counters {
    print <<EOT
host counters: list hosts' counters
usage: host counters
    
  Lists consists of Id, Name and all the counters for every host, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list counters only for hosts matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    name
    address
    (all of them refer to the host)
EOT
}

sub cmd_osf_add {
    my $self = shift;
    eval {
        my %args = _split_on_equals(@_);
        my $id = $self->{admin}->cmd_osf_add(%args);
        $self->_print("OSF added with id ".$id);        
    };
    
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_osf_add {
    print <<EOT
osf add: Adds operating systems flavours.
usage: osf add name=string [memory=size] [use_overlay=boolean]
                [user_storage_size=size]

    The disk_image is copied to the read-only storage area.
    The default values for the optional parameters are:
        memory=256 
        use_overlay=y
        user_storage_size=undef (no user storage)

Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_osf_del {
    my $self = shift;
    eval {
        $self->_obj_del('osf', @_);
        my $count = $self->{admin}->cmd_osf_del();
        $self->_print("$count OSFs deleted.");
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_osf_del {
    print <<EOT
osf del: Deletes operating systems images.
usage: osf del
       
Valid options:
    -f [--filter] FILTER : deletes operating systems images matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_osf_list {
    my ($self) = @_;
    my $rs = $self->get_resultset('osf');
    my @header = qw(Id Name RAM Overlay UserHD);
    my @body;
    eval {
        while (my $osf = $rs->next) {
            my @row = map { defined($_) ? $_ : '-' } map { $osf->$_ } qw(id name memory use_overlay user_storage_size);
            ## translate use_overlay from (0,1) to (no,yes)
            $row[-2] = { 0 => 'no', 1 => 'yes' }->{$row[-2]};
            push(@body, \@row);
        }
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print_table(\@header, \@body);
    }
}

sub help_osf_list {
    print <<EOT;
osf list: lists the installed Operating System Flavours (OSF)
usage: osf list

  Lists consists of Id, Name, RAM size, Home partition size and image
  file name separated by tabs.

Valid options:
    -f [--filter] FILTER : list only OSFs matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    name
    memory
    use_overlay
    user_storage_size
EOT
}

sub cmd_osf_propdel {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete the prop in all OSFs? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    } 
    eval {
        $self->{admin}->propdel('osf', @_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_osf_propdel {
    print <<EOT
vm propdel: Deletes OSF properties
usage: osf propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
        osf propdel has_opera -f has_opera=true
      
Valid options:
    -f [--filter] FILTER : Delete properties of OSFs matched by FILTER
EOT
}

sub cmd_osf_propget {
    shift->_obj_propget(sub { $_->osf->name }, 'osf', @_);
}

sub help_osf_propget {
    print <<EOT
osf propget: Gets OSF property.
usage: osf propget [key...]
      
  Example:
  osf propget has_opera
      
Valid options:
    -f [--filter] FILTER : gets OSF property only from OSFs matched by FILTER
EOT
}

sub cmd_osf_propset {
    my $self = shift;
    my $ci = 0;
    eval {
        $ci = $self->{admin}->cmd_osf_propset(_split_on_equals @_);
    };
    if (($ci == -1) || $@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print("propset in $ci OSFs.\n");
    }    
}

sub help_osf_propset {
    print <<EOT
osf propset: Sets OSF property.
usage: osf propset [key=value...]
      
  Example:
  osf propset has_opera=true
      
Valid options:
    -f [--filter] FILTER : sets OSF property to OSFs matched by FILTER
EOT
}

sub cmd_di_add {
    my $self = shift;
    eval {
        my %args = _split_on_equals(@_);
        my $id = $self->{admin}->cmd_di_add(%args);
        $self->_print("DI added with id ".$id);
    };
    $@ and $self->_die
}

sub help_di_add {
    print <<EOT
di add: Adds disk images.
usage: di add path=string osf_id=id [version=text]

    The disk image file is copied to the read-only storage area.

Valid options:
    -q [--quiet]         : don't print the command message
EOT

}

sub cmd_di_del {
    my $self = shift;
    eval {
        $self->_obj_del('di', @_);
        my $count = $self->{admin}->cmd_di_del();
        $self->_print("$count DIs deleted.");
    };
    $@ and $self->_die;
}

sub help_di_del {
    print <<EOT
di del: Deletes operating systems images.
usage: di del
       
Valid options:
    -f [--filter] FILTER : deletes di images matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_di_list {
    my ($self) = @_;
    eval {
        my @body;
        my $rs = $self->get_resultset('di');
        while (my $di = $rs->next) {
            push @body, [(map { $di->$_ // '-' } qw(id osf_id version path)), join(', ', $di->tag_list)];
        }
        $self->_print_table([qw(Id OSF Version Path Tags)],
                            \@body);
    };
    $@ and $self->_die;
}

sub help_di_list {
    print <<EOT;
di list: lists the Disk Images (DI)
usage: di list

Valid options:
    -f [--filter] FILTER : list only DIs matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    osf_id
    path
    version
EOT
}

sub cmd_di_tag {
    my ($self, @args) = @_;
    eval {
        my %args = _split_on_equals(@_);
        my $id = $self->{admin}->cmd_di_tag(%args);
        $self->_print("DI tagged");
    };
    $@ and $self->_die;
}

sub help_di_tag {
    print <<EOT;
di tag: tags a Disk Image (DI)
usage: di tag di_id=id tag=symbol
EOT
}

sub cmd_di_untag {
    my ($self, @args) = @_;
    eval {
        my %args = _split_on_equals(@_);
        $self->{admin}->cmd_di_untag(%args);
    };
    $@ and $self->_die;
}

sub help_di_untag {
    print <<EOT;
di untag: untags a Disk Image (DI)
usage: di untag di_id=id tag=symbol
EOT
}

sub cmd_di_propdel {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete the prop in all DIs? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    } 
    eval {
        $self->{admin}->propdel('di', @_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_di_propdel {
    print <<EOT
vm propdel: Deletes DI properties
usage: di propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
        di propdel linux30_test -f linux30_test=true
      
Valid options:
    -f [--filter] FILTER : Delete properties of DIs matched by FILTER
EOT
}

sub cmd_di_propget {
    shift->_obj_propget(sub { $_->di->path }, 'di', @_);
}

sub help_di_propget {
    print <<EOT
di propget: Gets DI property.
usage: di propget [key...]
      
  Example:
  di propget linux30_test
      
Valid options:
    -f [--filter] FILTER : gets DI property only from DIs matched by FILTER
EOT
}

sub cmd_di_propset {
    my $self = shift;
    my $ci = 0;
    eval {
        $ci = $self->{admin}->cmd_di_propset(_split_on_equals @_);
    };
    if (($ci == -1) || $@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print("propset in $ci DIs.\n");
    }    
}

sub help_di_propset {
    print <<EOT
di propset: Sets DI property.
usage: di propset [key=value...]
      
  Example:
  di propset linux30_test=true
      
Valid options:
    -f [--filter] FILTER : sets DI property to DIs matched by FILTER
EOT
}

sub cmd_user_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    eval {
        my $id = $self->{admin}->cmd_user_add(%args);
        $self->_print( "User added with id ".$id);
    };
    if ($@) {
        #$self->_print("Wrong syntax or user already exists, check the command help:\n");
        $self->_die;
    }
}

sub help_user_add {
    print <<EOT
user add: Adds users.
usage: user add login=value password=value
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_user_del {
    my $self = shift;
    eval {
        $self->_obj_del('user', @_);
        $self->{admin}->cmd_user_del();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_user_del {
    print <<EOT
user del: Deletes users.
usage: user del
       
Valid options:
    -f [--filter] FILTER : deletes users matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_user_list {
    my $self = shift;
    eval {
        my @body;
        my $rs = $self->get_resultset('user');
        while (my $user = $rs->next) {
            push @body, [$user->id, $user->login];
        }
        $self->_print_table([qw(Id Login)], \@body);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_user_list {
    print <<EOT
user list: list the registered users
usage: user list
    
    Lists consists of the users' id, login, department, telephone and email
    separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only user matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    login
EOT
}

# FIXME use a real password prompt library
sub _read_password {
    my ($self, $for_user) = @_;
    # FIXME: use Term::ReadKey module for setting tty input mode and for reading lines!
    system 'stty -echo';

    print "New password for $for_user: ";
    my $password1 = <STDIN>;
    print "\n";
    chomp $password1;

    print "Again: ";
    my $password2 = <STDIN>;
    print "\n";
    chomp $password2;

    system 'stty echo';

    if ($password1 ne $password2) {
        warn "Entered passwords don't match\n";
        return;
    }
    $password1
}
END { system 'stty echo'; }

sub cmd_user_passwd {
    my ($self, $user) = @_;
    my %args = _split_on_equals(@_);

    eval {
        my $passwd = $self->_read_password($args{'user'});
        return unless defined $passwd;
        $self->{admin}->set_password($args{'user'}, $passwd);
    };
    if ($@) {
        #$self->_print("Wrong syntax or user does not exist, check the command help:\n");
        $self->_die;
    }
}

sub help_user_passwd {
    print <<EOT
user passwd: Sets the password of a user
usage: user passwd user=username

    Prompts the user for the new password for the user with login "username"
    and sets it.

    Example: user passwd user=qvd
EOT
}

sub cmd_user_propdel {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete the prop in all users? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    } 
    eval {
        $self->{admin}->propdel('user', @_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_user_propdel {
    print <<EOT
vm propdel: Deletes user properties
usage: user propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
        user propdel timezone -f login=M*,department=sales
      
Valid options:
    -f [--filter] FILTER : Delete properties of users matched by FILTER
EOT
}

sub cmd_user_propget {
    shift->_obj_propget(sub { $_->user->login }, 'user', @_);
}

sub help_user_propget {
    print <<EOT
user propget: Gets user property.
usage: user propget [key...]
      
  Example:
  user propget genre timezone
      
Valid options:
    -f [--filter] FILTER : gets user property only from users matched by FILTER
EOT
}

sub cmd_user_propset {
    my $self = shift;
    my $ci = 0;
    eval {
        $ci = $self->{admin}->cmd_user_propset(_split_on_equals @_);
    };
    if (($ci == -1) || $@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print("propset in $ci users.\n");
    }    
}

sub help_user_propset {
    print <<EOT
user propset: Sets user property.
usage: user propset [key=value...]
      
  Example:
  user propset genre=male timezone=+1
      
Valid options:
    -f [--filter] FILTER : sets user property to users matched by FILTER
EOT
}

sub cmd_vm_add {
    my $self = shift;
    my %args = _split_on_equals(@_);
    eval {
        my $id = $self->{admin}->cmd_vm_add(%args);
        $self->_print( "VM added with id ".$id);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }  
}

sub help_vm_add {
    print <<EOT
vm add: Adds virtual machines.
usage: vm add name=value (user=value | user_id=value) (osf=value | osf_id=value) [ip=value] [di_tag=value]
       
Valid options:
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_block {
    my $self = shift;
    
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to block all machines? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        $self->{admin}->cmd_vm_block();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }      
}

sub help_vm_block {
    print <<EOT
vm block: Excludes the matched virtual machines from the production environment.
usage: vm block
       
Valid options:
    -f [--filter] FILTER : block only vm matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_console {
    my ($self, @args) = @_;
    eval {
        my $vm_runtime = $self->_get_single_vm_runtime;
        my $hv = cfg('vm.hypervisor');
        if ('lxc' eq $hv) {
            my $container_name = sprintf 'qvd-%d', $vm_runtime->vm_id;
            @args = qw/-t 1/ unless @args;
            exec 'lxc-console', '-n', $container_name, @args
                or die "Unable to exec lxc-console: $^E";
        } elsif ('kvm' eq $hv) {
            my $serial_port = $vm_runtime->vm_serial_port;
            die 'Console access is disabled' unless defined $serial_port;
            exec telnet => $vm_runtime->host->address, $serial_port, @args
                or die "Unable to exec telnet: $^E";
        } else {
            die "Unknown hypervisor '$hv'";
        }
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_vm_console {
    print <<EOT
vm console: Connects to the virtual machine console
usage: vm console

  Example:
  vm console -f id=42

Valid options:
    -f [--filter] FILTER : connect to the virtual machine matched by FILTER
EOT
}

sub cmd_vm_del {
    my $self = shift;
    eval {
        $self->_obj_del('vm', @_);
        $self->{admin}->cmd_vm_del();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }  
}

sub help_vm_del {
    print <<EOT
vm del: Deletes virtual machines.
usage: vm del
       
Valid options:
    -f [--filter] FILTER : deletes virtual machines matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_disconnect_user {
    my ($self) = @_;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to disconnect all users? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        my $count = $self->{admin}->cmd_vm_disconnect_user();
        $self->_print("Disconnected ".$count." users.");
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }  
}

sub help_vm_disconnect_user {
    print <<EOT
vm disconnect_user: Disconnects user.
usage: vm disconnect_user
      
Valid options:
    -f [--filter] FILTER : disconnects users on VMs matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_edit {
    my ($self, @args) = @_;

    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to edit all machines? [y/N] ";
        my $answer = <STDIN>;
        exit 0 if $answer !~ /^y/i;
    }   

    eval {
        my %args = _split_on_equals (@args);
        my $count = $self->{admin}->cmd_vm_edit (%args);
        $self->_print("Edited ".$count." VMs.");
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_vm_edit {
    print <<EOT
vm edit: change virtual machine settings
usage: vm edit di_tag=<t>

di_tag: Use the disk image with tag "t". Change takes effect on VM start.

Valid options:
    -f [--filter] FILTER : edits virtual machines matched by FILTER
    -q [--quiet]         : don't print messages
EOT
}

sub cmd_vm_list {
    my ($self) = @_;
    
    my $rs = $self->get_resultset('vm');
    
    my @header = ("Id","Name","User","Ip","OSF", "DI_Tag", "DI", "Host","State","UserState","Blocked");
    my @body;
        
    eval { 
        while (my $vm = $rs->next) {
            my $vmr = $vm->vm_runtime;
            my @row = map { $_ // '-' } (
                $vm->id,
                $vm->name,
                $vm->user->login,
                $vm->ip,
                $vm->osf->name,
                $vm->di_tag,
                (defined $vm->di ? $vm->di->version : undef),
                (defined $vmr->host ? $vmr->host->name : undef),
                $vmr->vm_state,
                $vmr->user_state,
                $vmr->blocked,
            );
            push(@body, \@row);
        }
    };  
    
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print_table(\@header, \@body);
    }
}

sub help_vm_list {
    print <<EOT
vm list: Returns a list with the virtual machines.
usage: vm list
    
  Lists consists of Id, Name, State and Host, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list only vms matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    name
    user_id
    user
    ip
    osf_id
    osf
    memory
    use_overlay
    user_storage_size
    di_tag
    host
    host_id
    state
    user_state
    vm_pid
    blocked
EOT
}

sub cmd_vm_propdel {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to delete the prop in all virtual machines? [y/N] ";
        my $answer = <STDIN>;
         exit 0 unless $answer =~ /^y/i;
    }
    eval {
        $self->{admin}->propdel('vm', @_);
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_vm_propdel {
    print <<EOT
vm propdel: Deletes VM properties
usage: vm propdel [key...]
      
    Only the properties with the listed keys are deleted. If no keys are listed
    all properties are deleted.
    Example:
        vm propdel priority -f user=nobody
      
Valid options:
    -f [--filter] FILTER : sets VM properties of VMs matched by FILTER
EOT
}

sub cmd_vm_propget {
    shift->_obj_propget(sub { $_->vm->name }, 'vm', @_);
}

sub help_vm_propget {
    print <<EOT
vm propget: Lists vm properties
usage: vm propget [key...]
      
  Example:
  vm propget usage priority
      
Valid options:
    -f [--filter] FILTER : gets VM properties only from VMs matched by FILTER
EOT
}

sub cmd_vm_propset {
    my $self = shift;
    my $ci = 0;
    eval {
        $ci = $self->{admin}->cmd_vm_propset(_split_on_equals @_);
    };    

    if (($ci == -1) || $@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        $self->_print("propset in $ci virtual machines.\n");
    }       
    
}

sub help_vm_propset {
    print <<EOT
vm propset: Sets vm property.
usage: vm propset [key=value...]
      
  Example:
  vm propset usage=accounting priority=critical
      
Valid options:
    -f [--filter] FILTER : sets host property to hosts matched by FILTER
EOT
}

sub _get_single_vm_runtime {
    my $self = shift;
    my $rs = $self->get_resultset('vm');
    if ($rs->count > 1) {
        die 'Filter matches more than one VM';
    }
    my $vm = $rs->single;
    die 'No matching VMs' unless defined $vm;
    $vm->vm_runtime
}

sub cmd_vm_ssh {
    my ($self, @args) = @_;
    eval {
        my $vm_runtime = $self->_get_single_vm_runtime;
        my $ssh_port = $vm_runtime->vm_ssh_port;
        die 'SSH access is disabled' unless defined $ssh_port;
        my @extra_opts;
        for (cfg_keys) {
            if (my ($key, $opt) = /^(admin\.ssh\.opt\.(.*))$/) {
                my $value = cfg($key);
                push @extra_opts, -o => "$opt=$value" if length $value;
            }
        }
        my @cmd = (ssh => ($vm_runtime->vm_address, -p => $ssh_port, @extra_opts, @args));
        exec @cmd or die "Unable to exec ssh: $^E";
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_vm_ssh {
    print <<EOT
vm ssh: Connects to the virtual machine SSH server.
usage: vm ssh

  Parameters after -- are passed to SSH.
  
  Example:
  vm ssh -f name=qvd-vm42 -- -l qvd -X -f xterm
       
Valid options:
    -f [--filter] FILTER : connect to the virtual machine matched by FILTER
EOT
}

sub cmd_vm_start {
    my ($self) = @_;
    
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to start all machines? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
     
    eval {
        my $count = $self->{admin}->cmd_vm_start();
        $self->_print("Started ".$count." VMs.");
    };   
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }
}

sub help_vm_start {
    print <<EOT
vm start: Starts virtual machine.
usage: vm start
      
Valid options:
    -f [--filter] FILTER : starts virtual machine matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_stop {
    my ($self) = @_;
    
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to stop all machines? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        my $count = $self->{admin}->cmd_vm_stop();
        $self->_print("Stopped ".$count." VMs.");
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }    
}

sub help_vm_stop {
    print <<EOT
vm stop: Stops virtual machine.
usage: vm stop
      
Valid options:
    -f [--filter] FILTER : stops virtual machine matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_unblock {
    my $self = shift;
    if (scalar %{$self->{admin}{filter}} eq 0) {
        print "Are you sure you want to unblock all machines? [y/N] ";
        my $answer = <STDIN>;
        exit 0 unless $answer =~ /^y/i;
    }   
    
    eval {
        $self->{admin}->cmd_vm_unblock();
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }    
}

sub help_vm_unblock {
    print <<EOT
vm unblock: Includes the matched virtual machines from the production environment.
usage: vm unblock
       
Valid options:
    -f [--filter] FILTER : unblock only vm matched by FILTER
    -q [--quiet]         : don't print the command message
EOT
}

sub cmd_vm_vnc {
    my ($self, @args) = @_;
    eval {
        my $vm_runtime = $self->_get_single_vm_runtime;
        my $vnc_port = $vm_runtime->vm_vnc_port;
        die 'VNC access is disabled' unless defined $vnc_port;
        # FIXME Make the vnc client configurable
        my @cmd = (vncviewer => ($vm_runtime->vm_address.'::'.$vnc_port, @args));
        exec @cmd or die "Unable to exec vncviewer: $^E";
    };
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    }    
}

sub help_vm_vnc {
    print <<EOT
vm ssh: Connects to the virtual machine VNC server.
usage: vm vnc

  To pass aditional parameters to vncviewer add them to the command line after --
  
  Example:
  vm vnc -- --depth 8
       
Valid options:
    -f [--filter] FILTER : connect to the virtual machine matched by FILTER
EOT
}

sub cmd_vm_counters {
    my ($self) = @_;
    
    my $rs = $self->get_resultset('vm');
    
    my @header = ("Id", "Name", "Run attempts", "Run OK");
    my @body;
        
    my ($vm_count, $vms_up, $vms_blocked) = (0, 0, 0);
    eval { 
        while (my $vm = $rs->next) {
            my $vmr = $vm->vm_runtime;
            my @row = map { $_ // '-' } (
                $vm->id,
                $vm->name,
                $vm->counters->run_attempts,
                $vm->counters->run_ok,
            );
            push(@body, \@row);

            $vm_count++;
            $vms_up++ if 'running' eq $vm->vm_runtime->vm_state;
            $vms_blocked++ if $vm->vm_runtime->blocked;
            #use Data::Dumper;       printf "%s:%s: %s\n", __FILE__, __LINE__, Data::Dumper->Dump (sub{\@_}->(\$vm->vm_runtime), ['vm']);
        }
    };
    
    if ($@) {
        #$self->_print("Wrong syntax, check the command help:\n");
        $self->_die;
    } else {
        my @header2 = ('Virtual machines', 'Running', 'Blocked');
        my @body2 = [ $vm_count, $vms_up, $vms_blocked ];
        $self->_print_table (\@header2, \@body2);

        print "\n";

        $self->_print_table(\@header, \@body);
    }
}

sub help_vm_counters {
    print <<EOT
vm counters: Returns counters for each virtual machine.
usage: vm counters
    
  Lists consists of Id, Name and all the counters for every vm, separated by tabs.
    
Valid options:
    -f [--filter] FILTER : list counters only for vms matched by FILTER
    -q [--quiet]         : don't print the header

Fields that can be used with -f:
    id
    name
    user_id
    user
    ip
    osf_id
    osf
    memory
    use_overlay
    user_storage_size
    di_tag
    host
    host_id
    state
    user_state
    vm_pid
    blocked
EOT
}

1;

__END__

=head1 NAME

QVD::AdminCLI - QVD CLI Administration Tool

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::Admin;
    my $admin = QVD::AdminCLI->new($quiet);
    $admin->set_filter('login=mua*');
    $admin->dispatch_command('user', 'del');

=head1 AUTHOR

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
