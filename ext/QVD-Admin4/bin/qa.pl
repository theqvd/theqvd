#!/usr/lib/perl 
use strict;
use warnings;
use lib::glob '/home/benjamin/qvdadmin4/ext/*/lib/';
use Mojo::UserAgent;
use Getopt::Long;
use Text::Table;
use QVD::Config::Core;

my $host = core_cfg('database.host');
my $user = core_cfg('database.user');
my $password = core_cfg('database.password');
my $database = core_cfg('database.name');

#### GET OPTIONS FROM COMMAND LINE

my $table = "";
my $action = "";
my $order_dir = "-desc";
my %filters = ();
my %arguments = ();
my %pagination = ();
my @order_by = ();
my @fields = ();

GetOptions( "table=s"      => \$table,
            "action=s"     => \$action,
            "filters=s"    => \%filters,
	    "order_dir=s"   => \$order_dir,
            "arguments=s"  => \%arguments,
	    "pagination=s" => \%pagination,
	    "order_by=s"   => \@order_by,
	    "fields=s"     => \@fields );

#### BUILD AND SEND THE QUERY

my $url = "http://192.168.56.102:8080";
my $ua = Mojo::UserAgent->new;

my $res = $ua->post($url => json => { host       => $host,
				      user       => $user,
				      password   => $password,
				      database   => $database,
				      
				      table      => $table,
		                      action     => $action,
				      order_dir  => $order_dir,
				      pagination => \%pagination,
				      order_by   => \@order_by,
				      fields     => \@fields,
                                      filters    => \%filters,
                                      arguments  => { relations => { tags => [qw(id tag)] }}} )->res;


#### OUTPUT MODEL FOR Text::Table

my @model = ( 
{ is_sep => 1,
  title  => '|',
  body   => '|' },

{ title   => "Key",
  align   => 'left',
  align_title => 'center',
  align_title_lines => 'center' },

{ is_sep => 1,
  title  => '|',
  body   => '|' },

{ title   => "Value",
  align   => 'left',
  align_title => 'center',
  align_title_lines => 'center' },

{ is_sep => 1,
  title  => '|',
  body   => '|' }

);

#### PARSE THE RESPONSE AND PRINT IT

print_rows_table();
	      
sub print_rows_table
{
    my $n = 0;
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    $message =~ s/ at .+$//;
    my $properties = $res->json("/rows/$n");

    while ($properties = $res->json("/rows/$n")) 
    {
	my $tb = Text::Table->new(@model);
	$tb->add("Status $status","$message");

	while (my ($k,$v) = each %$properties)
	{
	    $tb->add($k,$v);
	}

	$n++;
	print_table($tb);
    }
    
    print_status_table() unless $n;
}

sub print_status_table
{
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    $message =~ s/ at .+$//;

    my $tb = Text::Table->new(@model);
    $tb->add("Status $status","$message");
    print_table($tb);
}

sub print_table
{
    my $tb = shift;
    my $rule = $tb->rule(qw(- +));
    my @body = $tb->body;
    my $title = $tb->title;

    print "\n";
    print $rule;
    print $tb->title;
    print $rule;
    
    for my $row (@body)
    {
	print $row;
	print $rule;
    }
    print "\n";
}
