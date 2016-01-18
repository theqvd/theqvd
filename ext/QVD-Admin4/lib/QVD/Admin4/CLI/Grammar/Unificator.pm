package QVD::Admin4::CLI::Grammar::Unificator;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Grammar::Substitution;
use Data::Dumper;

# Variables are strings that starts with #
my $VAR = qr/^#[^#]+$/;

sub unify
{
    my ($self,%args) = @_;

    my $source = $args{source_structure};
    my $target = $args{target_structure};

    my $s_subst = $args{source_substitution};
    my $t_subst = $args{target_substitution};

    $self->set_substitution($t_subst); # Creates the new substitution that 
	# will be retrieved by the method in case the unification is successful
	my $flag = 0;

    while (my ($key,$t_value) = each %$target)
    {
	my $s_value = $source->{$key} // next;

	my $real_t_value = $t_subst->subst($t_value);
	my $real_s_value = $s_subst->subst($s_value);

	next if $self->is_var($real_s_value);

	if ($self->is_var($real_t_value)) 
		{
			$self->substitution->_set($real_t_value,$real_s_value);
			next;
		}

		if ($real_t_value ne $real_s_value) {
			$flag = 1;
			last;
		}
    }

    $flag ? return 0 : return $self->substitution;
}

sub set_substitution
{
    my ($self, $old_substitution) = @_;
    $self->{substitution} = QVD::Admin4::CLI::Grammar::Substitution->new();
    
    if ($old_substitution)
    {
	$self->{substitution}->_set($_,$old_substitution->_get($_))
	    for $old_substitution->_list;
    }
    $self->{substitution};
}


sub substitution
{
    my $self = shift;
    $self->set_substitution 
	unless $self->{substitution}; 
    $self->{substitution};
}

sub is_var 
{
    my ($self,$k) = @_;
    $k =~ /$VAR/ ? return 1 : return 0;
}
1;
