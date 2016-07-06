package QVD::Session;
use strict;
use warnings FATAL => 'all';

use Session::Token;

sub new {
    my $class = shift;
    my %args  = @_;

    my $dbi   = delete $args{dbi} or die "dbi handler required";
    my $table = delete $args{schema} // "Session";
    my $delta = delete $args{delta} // 3600;

    $dbi->resultset($table) or die "Schema $table cannot be found";

    my $self = {
        _schema => $table,
        _dbi => $dbi,
        _sid => undef,
        _delta => $delta,
        _data => {}
    };

    bless $self, $class;

    return $self;
}

sub create {
    my $self = shift;
    my %args = @_;
    
    $args{sid} = $self->_generate_sid() unless defined($args{sid});
    $args{expires} = time + $self->{_delta};

    $self->{_sid} = $args{sid};
    
    $self->_resultset->create(\%args);
    
    return $self->{_sid};
}

sub load {
    my $self = shift;
    my $sid = shift;
    
    my $obj = $self->_resultset->find($sid);
    if (defined($obj)){
        $self->{_sid} = $sid;
        $self->{_data} = {};
        $self->{_data}->{expires} = $obj->expires;
        return $self;
    } else {
        return undef;
    }
}

sub data {
    my $self = shift;
    my $field = shift;
    my $value = shift;
    
    if (defined($value)){
        $self->_resultset->update({ $field => $value });
        $self->{_data}->{$field} = $value;
    } else {
        $self->{_data}->{$field} //= $self->_resultset->find($self->{_sid})->$field;
    }
    
    return $self->{_data}->{$field};
}

sub sid {
    my $self = shift;
    return $self->{_sid};
}

sub clear {
    my $self = shift;
    my $sid = $self->{_sid};
    
    $self->_resultset->find($sid)->delete();
    $self->{_data} = {};
    
    return $sid;
}

sub is_expired {
    my $self = shift;

    $self->{_data}->{expires} //= $self->_resultset->find($self->{_sid})->expires;
    return time > $self->{_data}->{expires}
}

sub expire {
    my $self = shift;

    $self->_resultset->find($self->{_sid})->update({ expires => 0 });
    $self->{_data}->{expires} = 0;
    
    return $self;
}

sub extend_expiration {
    my $self = shift;
    my $delta = shift // $self->{_delta};
    my $expire_date = time + $delta;

    $self->_resultset->find($self->{_sid})->update({ expires => $expire_date });
    $self->{_data}->{expires} = $expire_date;

    return $expire_date;
}

sub _resultset {
    my $self = shift;
    return $self->{_dbi}->resultset($self->{_schema});
}

sub _generate_sid {
    my $self = shift;
    return Session::Token->new(entropy => 128)->get;
}

1;

=encoding utf8

=head1 NAME

QVD::Session - Class to manage sessions with DBIx::Class

=head1 SYNOPSIS

  use QVD::Session;
  
  my $session = QVD::Session->new(dbi => $dbi, schema => 'Session', delta => 3600);
  $session->create;
  my $sid = $session->sid;
  
  $session->data('field', 'value'); # 'field' must be defined in the database
  print $session->data('field'); # Prints 'value'
  
  $session->load($sid);
  $session->extend_expiration(60); # In seconds
  
  $session->expire;
  $session->clear if $session->is_expired;

=head1 FUNCTIONS

QVD::Session implements the following methods

=head2 new

  my $session = QVD::Session->new(dbi => $dbi);
  my $session = QVD::Session->new(dbi => $dbi, schema => 'Session');
  my $session = QVD::Session->new(dbi => $dbi, schema => 'Session', delta => 3600);

Creates a new session object. Schema used is by default 'Session' and delta time for a session to expire is 3600 seconds
by default.

=head2 create

  $session->create;

Registers a new session in the database.

=head2 load

  $session->load;

Load a new session from the database.

=head2 data

  $session->data('field', 'value'); # 'field' must be defined in the database
  print $session->data('field'); # Prints 'value'
  
Sets or gets database fields for a session. These fields must be defined in the dbix::class schema.

=head2 sid

  $session-sid;
  
Gets the sid generated for the session.

=head2 is_expired

Checks if the session is expired.

=head2 expire

The session is marked as expired.

=head2 extend_expiration

  $session->extend_expiration(60); # In seconds

Extends the expiration time of a session.

=cut
