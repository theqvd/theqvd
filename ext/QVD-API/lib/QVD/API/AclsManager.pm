package QVD::API::AclsManager;
use strict;
use warnings;
use Moo;
has 'domain', is => 'ro', isa => sub {die "Invalid type for attribute domain" if ref(+shift);};
has 'action', is => 'ro', isa => sub {die "Invalid type for attribute action" if ref(+shift);};
has 'subaction', is => 'ro', isa => sub {die "Invalid type for attribute action" if ref(+shift);};
has 'object', is => 'ro', isa => sub {die "Invalid type for attribute subaction" if ref(+shift);};

my @DOMAINS = qw(vm host osf di user administrator config role tenant views);
my @ACTIONS = qw(see update delete create filter customize manage);
my @SUBACTIONS = qw(see-details see-list update-massive delete-massive filter-desktop filter-mobile);

sub parse
{
    my ($self,$acl) = @_;
    my ($domain,$action,$object) = split '.', $acl;

    return 0 unless ($domain && $action);
    return 0 unless $self->available_domain($domain);
    return 0 unless $self->available_action($action);

    my ($main_action,$sub_action) = 
	$action =~ /^([^-]+)-([^-]+)$/; 

    $self->{domain} = $domain;
    $self->{action} = $main_action // $action;
    $self->{subaction} = $action if defined ;
    $self->{object} = $object if defined $object;
    return 1;
}

sub generate
{
    my ($self,%params) = @_;

    $self->{domain} = $params{domain} if defined $params{domain};
    $self->{action} = $params{action} if defined $params{action};
    $self->{subaction} = $params{subaction} if defined $params{subaction};
    $self->{object} = $params{object} if defined $params{object};

    return 0 unless (defined $self->domain && 
		     defined $self->action);

    my $acl = $self->domain . "." . $self->action;
    $acl .= ".".$self->object if defined $self->object;
    $acl;
}


sub available_action
{
    my ($self,$action) = @_;
    $_ eq $action && return 1 for @ACTIONS;
    return 0;
}

sub available_domain
{
    my ($self,$domain) = @_;
    $_ eq $domain && return 1 for @DOMAINS;
    return 0;
}

1;
