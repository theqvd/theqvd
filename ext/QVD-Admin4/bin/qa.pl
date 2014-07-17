#!/usr/lib/perl 
use strict;
use warnings;
use lib::glob '/home/benjamin/qvdadmin4/ext/*/lib/';
use Mojo::UserAgent;
use Getopt::Long;
use Text::Table;
use QVD::Config::Core;

#### GET OPTIONS FROM COMMAND LINE

my $table = "";
my $action = "";
my %filters = ();
my %arguments = ();
my $host = core_cfg('database.host');
my $user = core_cfg('database.user');
my $password = core_cfg('database.password');
my $database = core_cfg('database.name');

GetOptions( "table=s"    => \$table,
            "action=s"   => \$action,
            "filters=s"   => \%filters,
            "argument=s" => \%arguments,
	    "host=s"     => \$host,
	    "user=s"     => \$user,
	    "password=s" => \$password,
	    "database=s" => \$database);

#### BUILD AND SEND THE QUERY

my $url = "http://192.168.56.102:8080";
my $ua = Mojo::UserAgent->new;
my $res = $ua->post($url => json => { host => $host,
				      user => $user,
				      password => $password,
				      database => $database,
				      table     => $table,
		                      action    => $action,
                                      filters    => \%filters,
                                      arguments => \%arguments})->res;


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
