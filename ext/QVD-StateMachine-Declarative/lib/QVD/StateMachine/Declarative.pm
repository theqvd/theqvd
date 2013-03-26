package QVD::StateMachine::Declarative;

sub _clean_eval { eval shift }

our $VERSION = '0.01';

use 5.010;

use strict;
use warnings;

use Carp;
BEGIN { our @CARP_NOT = qw(Class::StateMachine Class::StateMachine::Private) }
use Class::StateMachine;
use mro;

my $dump = exists $ENV{CLASS_STATEMACHINE_DECLARATIVE_DUMPFILE};
warn "dump: $dump\n";
my %dump;

END {
    if ($dump) {
        open my $fh, ">", $ENV{CLASS_STATEMACHINE_DECLARATIVE_DUMPFILE} or return;
        require Data::Dumper;
        print $fh, Data::Dumper->Dump(\%dump, [qw(*state_machines)]);
        close $fh;
    }
}

require parent;

sub import {
    shift;
    my $caller = caller;
    $dump{$caller} = [@_] if $dump;
    init_class($caller, @_);
}

my $usage = 'usage: use QVD::StateMachine::Declarative state => { enter => action, leave => action, transitions => { event => final_state, ...}, ignore => [ event, ...] }, state => { ... }, ...;';

sub _action {
    my $action = shift;
    given (ref $action) {
        when ('CODE') {
            return $action;
        }
        when ('') {
            if ($action =~ /^\w+(?:::\w)*$/) {
                return sub { shift->$action };
            }
            else {
                my ($pkg, $fn, $line) = caller(1);
                my $sub = _clean_eval <<SUB;
sub {
    package $pkg;
    my \$self = shift;
    # line $line $fn
    $action
}
SUB
                die $@ if $@;
                return $sub;
            }
        }
        default {
            croak "$action is not a valid action";
        }
    }
}

sub init_class {
     my ($class, %states) = @_;

     for my $state (keys %states) {
         my $decl = $states{$state};
         if (exists $decl->{jump}) {
             keys %$decl > 1 and croak "jump declaration can not be mixed with other keys";
             my $target_state = $decl->{jump};
             Class::StateMachine::install_method($class, 'enter_state', sub { shift->state($target_state) }, $state);
         }
         else {
             while (my ($type, $arg) = each %$decl) {
                 given ($type) {
                     when([qw(enter leave)]) {
                         Class::StateMachine::install_method($class, "${_}_state", _action($arg), $state);
                     }
                     when ('transitions') {
                         ref $arg eq 'HASH' or croak "$arg is not a hash reference, $usage";
                         while (my ($event, $final) = each %$arg) {
                             Class::StateMachine::install_method($class, $event,
                                                                 sub { shift->state($final) },
                                                                 $state);
                         }
                     }
                     when ('delay_once') {
                         ref $arg eq 'ARRAY' or croak "$arg is not and array reference, $usage";
                         for (@$arg) {
                             my $method = $_;
                             Class::StateMachine::install_method($class, $method,
                                                                 sub {
                                                                     my $self = shift;
                                                                     $self->_debug("method $method delayed once");
                                                                     $self->delay_once_until_next_state($method);
                                                                 },
                                                                 $state);
                         };
                     }
                     when ('delay') {
                         ref $arg eq 'ARRAY' or croak "$arg is not an array reference, $usage";
                         for (@$arg) {
                             my $method = $_;
                             Class::StateMachine::install_method($class, $method,
                                                                 sub {
                                                                     my $self = shift;
                                                                     $self->_debug("method $method delayed");
                                                                     $self->delay_until_next_state },
                                                                 $state);
                         }
                     }
                     when ('ignore') {
                         ref $arg eq 'ARRAY' or croak "$arg is not an array reference, $usage";
                         Class::StateMachine::install_method($class, $_, sub {}, $state)
                                 for @$arg;
                     }
                     default {
                         croak "invalid option '$type', $usage";
                     }
                 }
             }
         }
     }
}

1;
__END__

=head1 NAME

QVD::StateMachine::Declarative - Perl extension for blah blah blah

=head1 SYNOPSIS


  package Dog;

  use parent 'Class::StateMachine';

  use QVD::StateMachine::Declarative
      __any__  => { enter       => sub { say "entering state $_[0]" },
                    leave       => sub { say "leaving state $_[0" },
      happy    => { transitions => { on_knocked_down => 'injuried',
                                     on_kicked       => 'angry' } },
      injuried => { transitions => { on_sleep        => 'happy' } },
      angry    => { 'enter+'    => sub { shift->bark },
                    'leave+'    => sub { shift->bark },
                    transitions => { on_feed         => 'happy',
                                     on_knocked_down => 'injuried' },
                    ignore      => ['on_kicked'] };

  sub new {
    my $class = shift;
    my $self = {};
    # starting state is set here:
    Class::StateMachine::bless $self, $class, 'happy';
    $self;
  }

  # events (mehotds) that do not cause a state change:
  sub on_touched_head : OnState(happy) { shift->move_tail }
  sub on_touched_head : OnState(injuried) { shift->bark('') }
  sub on_touched_head : OnState(angry) { shift->bite }


  package main;

  my $dog = Dog->new;
  $dog->on_touched_head; # the dog moves his tail
  $dog->on_kicked;
  $dog->on_touched_head; # the dog bites you
  $dog->on_injuried;
  $dog->on_touched_head; # the dog barks
  $dog->on_sleep;
  $dog->on_touched_head; # the dog moves his tail


=head1 DESCRIPTION

QVD::StateMachine::Declarative is a L<Class::StateMachine> extension
that allows to define most of a state machine class declaratively.

=head1 SEE ALSO

L<Class::StateMachine>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador FandiE<ntilde>o <sfandino@yahoo.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
