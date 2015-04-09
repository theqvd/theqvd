package QVD::DB::Result::VM;
use base qw/DBIx::Class/;

use strict;
use warnings;
use QVD::Admin4::VMExpiration;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vms');
__PACKAGE__->add_columns( 
			  id      => { data_type         => 'integer',
				       is_auto_increment => 1 },
			  name    => { data_type         => 'varchar(64)' },
			  user_id => { data_type         => 'integer' },
			  osf_id  => { data_type         => 'integer' },
                          di_tag  => { data_type         => 'varchar(128)' },
			  ip      => { data_type         => 'varchar(15)',
				       is_nullable       => 1 },
			  storage => { data_type         => 'varchar(4096)',
				       is_nullable       => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(['ip']);

__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id', { cascade_delete => 0 });
__PACKAGE__->belongs_to(osf  => 'QVD::DB::Result::OSF',  'osf_id',  { cascade_delete => 0 });

__PACKAGE__->has_one (vm_runtime => 'QVD::DB::Result::VM_Runtime',  'vm_id');
__PACKAGE__->has_one (counters   => 'QVD::DB::Result::VM_Counter',  'vm_id');
__PACKAGE__->has_many(properties => 'QVD::DB::Result::VM_Property', \&custom_join_condition, 
		      {join_type => 'LEFT', order_by => {'-asc' => 'key'}});
__PACKAGE__->belongs_to(di => 'QVD::DB::Result::DI',
			sub {
  			  my $args = shift;
 			  my $in = <<EOIN;
 SELECT dis.id from dis, di_tags
  WHERE di_tags.di_id = dis.id
    AND di_tags.tag = $args->{self_alias}.di_tag
EOIN
  			  return { "$args->{foreign_alias}.osf_id" => {-ident => "$args->{self_alias}.osf_id"},
				   "$args->{foreign_alias}.id" => { -in => \$in } };

			});

######### Log info

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});


sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'vm' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='vm' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

sub start_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='vm' and action='vm_start' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

###################


sub combined_properties {
    my $vm = shift;

    my $current_di = $vm->vm_runtime->current_di;

    map { $_->key, $_->value } ( $vm->osf->properties,
                                 ($current_di ? $current_di->properties : ()),
				 $vm->user->properties,
				 $vm->properties );
}

sub host_name 
{
    my $self = shift;
    $self->vm_runtime->host->name;
}

sub di_id
{
    my $self = shift;
    $self->di->id;
}

sub di_version
{
    my $self = shift;
    $self->di->version;
}

sub di_name
{
    my $self = shift;
    $self->di->path;
}

sub creation_date
{
    my $self = shift;
    return undef;
}

sub creation_admin
{
    my $self = shift;
    return undef;
}


sub custom_join_condition
{ 
    my $args = shift; 
    my $key = $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION};

    { "$args->{foreign_alias}.vm_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.key"     => ($key ? { '=' => $key } : { -ident => "$args->{foreign_alias}.key"}) };
}

sub tenant_id
{
    my $self = shift;
    $self->user->tenant_id;
}

sub tenant_name
{
    my $self = shift;
    $self->user->tenant->name;
}

sub tenant
{
    my $self = shift;
    $self->user->tenant;
}


sub get_properties_key_value
{
    my $self = shift;

    ( properties => { map {  $_->key => $_->value  } $self->properties->all });
} 

sub vm_mac
{
    my $self = shift;
    my $ip = $self->ip // return;
    my (undef, @hex) = map sprintf('%02x', $_), split /\./, $ip;
    use QVD::Config;
    my $mac_prefix = cfg('vm.network.mac.prefix');
    join(':', $mac_prefix, @hex);

}

sub remaining_time_until_expiration_hard
{
    my $self = shift;
    my $exp = QVD::Admin4::VMExpiration->new(vm => $self);
    return $exp->time_until_expiration_hard;
}

sub remaining_time_until_expiration_soft
{
    my $self = shift;
    my $exp = QVD::Admin4::VMExpiration->new(vm => $self);
    return $exp->time_until_expiration_soft;
}

1;
