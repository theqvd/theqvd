package QVD::Admin4::REST::Request::Administrator;
use strict;
use warnings;
use Moose;
use QVD::Config;
extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    push @{$self->modifiers->{join}}, qw(tenant);
    $self->json->{filters}->{password} = 
	$self->_password_to_token($self->json->{filters}->{password})
	if defined $self->json->{filters}->{password};

    $self->json->{arguments}->{password} = 
	$self->_password_to_token($self->json->{arguments}->{password})
	if defined $self->json->{arguments}->{password};

    $self->json->{filters}->{name} = 
	$self->normalize_login($self->json->{filters}->{name})
	if defined $self->json->{filters}->{name};

    $self->json->{arguments}->{name} = 
	$self->normalize_login($self->json->{arguments}->{name})
	if defined $self->json->{arguments}->{name};

    $self->_check;
    $self->_map;
}

sub _password_to_token 
{
    my ($self, $password) = @_;
    require Digest::SHA;
    Digest::SHA::sha256_base64(cfg('l7r.auth.plugin.default.salt') . $password);
}

sub normalize_login
{
    my ($self,$login) = @_;
    $login =~ s/^\s*//; $login =~ s/\s*$//;
    $login = lc($login)  
	unless cfg('model.user.login.case-sensitive');
    $login;
}


1;

__DATA__

id = me.id
name = me.name
password = me.password
tenant = me.tenant_id
tenant_name = tenant.name
