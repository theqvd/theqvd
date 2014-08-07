package QVD::Admin4::Exception;
use Moose;
with 'Throwable';

has 'code', is => 'ro', isa => 'Int', required => 1;
has 'failures', is => 'ro', isa => 'HashRef', default => sub { {}; };

1;
