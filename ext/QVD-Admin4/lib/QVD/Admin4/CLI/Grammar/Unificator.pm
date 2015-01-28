package QVD::Admin4::CLI::Grammar::Unificator;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Grammar::Substitution;

my $VAR = qr/^#[^#]+$/;

sub unify
{
    my ($self,%args) = @_;

    my $source = $args{source_structure};
    my $target = $args{target_structure};

    my $s_subst = $args{source_substitution};
    my $t_subst = $args{target_substitution};
    while (my ($key,$a_v) = each %$a_str)
    {
	my $i_v = $i_str->{$key} // next;
	my $a_value = $a_subs->subst($a_v);
	my $i_value = $i_subs->subst($i_v);
	if ($self->is_var($a_value) 
	    { $self->substitution->_set($a_value,$i_value); next;}
	return 0 if $i_value ne $a_value;
    }


    $self->substitution($target->substitution);

    return $self->substitution;
}

sub substitution
{
    my ($self, $old_substitution) = @_;
    $self->{substitution} //= QVD::Admin4::CLI::Grammar::Substitution->new();
    
    if ($old_substitution)
    {
	$self->{substitution}->_set($_,$old_substitution->_get($_))
	    for $old_substitution->_list;
    }
    $self->{substitution};
}

sub is_var 
{
    my ($self,$k) = @_;
    $k =~ /$VAR/ ? return 1 : return 0;
}
1;
