package QVD::Admin4::CLI::Command::VM;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;
use Benchmark;
use Data::Dumper;

sub usage_text { "Wrong syntax my friend!\n" }

sub run 
{
    my ($self, $opts, @args) = @_;

    my $start = Benchmark->new;

    my $parsing = parse_string($self,'vm',@args);

    my $query = 
    { action => action($parsing->obj1->qvd_object,$parsing->command),
      filters => $parsing->obj1->filters, order_by => $parsing->order, 
      arguments => $parsing->arguments, fields => $parsing->fields};

    if ($parsing->filter_by_related_obj)
    {
	my $related_query = 
	{ action => action($parsing->obj1->obj2->qvd_object,'ids'),
	  filters => $parsing->obj1->obj2->filters };

	my $related_res = ask_api($self,$related_query);
	my $ids = $related_res->json('/rows');
	$query->{filters}->{related_qvd_object('vm',$parsing->obj1->obj2->qvd_object)} = $ids;
    }

    my $res = ask_api($self,$query);
    my @fields = @{$parsing->fields} ? @{$parsing->fields} : default_fields('vm');

    @fields = qw(id) unless $parsing->command eq 'get';

    my $end = Benchmark->new;
    my $time = timestr(timediff($end,$start));
    print_table($res, 'vm', $time, @fields);
}

1;

