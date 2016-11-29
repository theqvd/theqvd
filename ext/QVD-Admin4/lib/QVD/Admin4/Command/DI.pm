package QVD::Admin4::Command::DI;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;

sub usage_text { 

"======================================================================================================
                                             DI COMMAND USAGE
======================================================================================================

== CREATING A NEW DI

  di new <ARGUMENTS>
  
  For example: 
  di disk_image=/path/to/disk/image, osf=myosf (Creates a DI with disk_image 'mydi', address '10.3.15.1') 

== GETTING DIs

  di get
  di <FILTERS> get
  di <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  di get (retrieves default fields of all DIs)
  di disk_image=mydi get (retrieves default fields of all DIs with disk_image 'mydi')
  di disk_image=mydi get disk_image, id (retrieves 'disk_image', 'id' of DIs with disk_image 'mydi') 

  Ordering:

  di ... order <ORDER CRITERIA>
  di ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  di get order disk_image (Ordering by 'disk_image' in default ascendent order)
  di get order asc disk_image, id (Ordering by 'disk_image' and 'id' in ascendent order)
  di get order desc disk_image, id (Ordering by 'disk_image' and 'id' in descendent order)

== UPDATING DIs

  di set <ARGUMENTS>
  di <FILTERS> set <ARGUMENTS>

  For example: 
  di disk_image=mydi set disk_image=yourdi (Sets new values for disk_image in DI with disk_image mydi)

  Adding custom properties:

  di <FILTERS> set property key=value  
  di <FILTERS> set property key=value, key=value, ...  

  For example: 
  di set property mykey=myvalue (Sets property mykey in all DIs)
  di disk_image=mydi set property mykey=myvalue, yourkey=yourvalue (Sets properties mykey and yourkey in DI with disk_image mydi)

  Deleting custom properties:

  di <FILTERS> del property key
  di <FILTERS> del property key, key, ...

  For example: 
  di del property mykey (Deletes property mykey in all DIs)
  di disk_image=mydi del property mykey, yourkey (Deletes properties mykey and yourkey in DI with disk_image mydi)

  Adding tags:

  di <FILTERS> tag tag1  
  di <FILTERS> tag tag1, tag2, ...  

  For example: 
  di disk_image=mydi tag default, head, mytag

  Deleting tags:

  di <FILTERS> untag tag1
  di <FILTERS> untag tag1, tag2, ...

  For example: 
  di disk_image=mydi untag mytag, yourtag

  Blocking/Unblocking DIs

  di <FILTERS> block
  di <FILTERS> unblock

  For example: 
  di block (Blocks all DIs)
  di disk_image=mydi block (Blocks DI with disk_image mydi)

== REMOVING DIs
  
  di del
  di <FILTERS> del

  For example: 
  di del (Removes all DIs) 
  di disk_image=mydi del (Removes DI with disk_image mydi)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;

    unshift @args, 'di';
    my $parsing = $self->parse_string(@args);

    if ($parsing->command eq 'get')
    {
        $self->_get($parsing);
    }
    elsif ($parsing->command eq 'create')
    {
        my $res = $self->ask_api_staging(
            $self->get_app->cache->get('api_staging_path'),
            $self->make_api_query($parsing)
        );
        $self->print_table($res,$parsing);
    }
    elsif ($parsing->command eq 'can')
    {
        $self->_can($parsing);
    }
    else
    {
        $self->_cmd($parsing);
    }
}


1;


