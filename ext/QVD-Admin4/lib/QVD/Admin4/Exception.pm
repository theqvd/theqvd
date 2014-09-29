package QVD::Admin4::Exception;
use Moo;
with 'Throwable';

has 'code', is => 'ro', isa => sub { die "Invalid type for attribute code" if ref(+shift); }, required => 1;
has 'failures', is => 'ro', isa => sub { die "Invalid type for attribute failures" 
					     unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'message', is => 'ro', isa => sub { die "Invalid type for attribute message" if ref(+shift); };

sub BUILD
{
    my $self = shift;
    print $self->message if $self->message; 
}

1;
