#!/usr/bin/perl

use strict;
use warnings;
use HTML::DOM;
use Test::More tests => 50;
use Test::WWW::Mechanize::Catalyst 'QVD::Admin::Web';

open my $fd, '>', '/var/lib/qvd/storage/staging/qqimage' or die "open: $!"; close $fd;

my $mech = Test::WWW::Mechanize::Catalyst->new;

## login page
{
    $mech->get_ok ('http://localhost/');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->content_contains ('User name', 'Login page');
    $mech->content_contains ('Password', 'Login page');
}

## submit login credentials
{
    $mech->submit_form_ok ({
        fields      => {
            log    => 'hue',
            pwd    => 'hue',
        }
    }, 'Submit login form');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->content_contains ('users', 'Main page contains "users"');
    $mech->content_contains ('virtual machines', 'Main page contains "VMs"');
    $mech->content_contains ('sessions', 'Main page contains "sessions"');
    $mech->content_contains ('nodes', 'Main page contains "nodes"');
    $mech->content_contains ('images', 'Main page contains "images"');
}

## go to OSFs, create new, check that it exists
my $osf_id;
{
    $mech->follow_link_ok ({ text => 'OS flavours' }, 'Go to OSFs');

    my $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $table_contents = $dom_tree->getElementById ('props')->tBodies->[0]->innerHTML;
    $dom_tree->close;
    $table_contents =~ s/\s*//;
    is length $table_contents, 0, 'OSFs table is empty';

    $mech->follow_link_ok ({ text => 'New' }, 'Go to new OSF');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->submit_form_ok ({
        fields => {
            add_name_label => 'osf foo',
        },
    }, 'New OSF form');

    $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $mem = $dom_tree->getElementById ('props')->rows->[1]->cells->[4]->innerHTML;
    is $mem, '256', 'OSF created with default values (only testing memory size)';

    ## grab osf_id for later use
    $osf_id = $dom_tree->getElementById ('props')->rows->[1]->cells->[1]->as_text;
    like $osf_id, qr/^\d+$/, 'OSF id is numeric';

    $dom_tree->close;
}

## try to create a new OSF with invalid data
{
    $mech->follow_link_ok ({ text => 'New' }, 'Go to new OSF');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->submit_form_ok ({
        fields => {
            name              => 'kkita',
            memory            => 'osf foo',
            user_storage_size => 'osf foo',
        },
    }, 'New OSF form');

    like $mech->content, qr/DBI Exception: DBD::Pg::st execute failed: ERROR:  invalid input syntax for integer: "osf foo"/, 'Error on invalid OSF creation';
}

## go to DIs, create new, check that it exists
my $di_id;
{
    $mech->follow_link_ok ({ text => 'Disk images' }, 'Go to DIs');

    my $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $table_contents = $dom_tree->getElementById ('props')->tBodies->[0]->innerHTML;
    $dom_tree->close;
    like $table_contents, qr/^\s*$/, 'Disk images table is empty';

    $mech->follow_link_ok ({ text => 'New' }, 'Go to new DI');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->submit_form_ok ({
        fields => {
            add_osf_id_field     => 'osf foo',
            add_disk_image_field => 'qqimage',
        },
    }, 'New DI form');
    is $mech->ct, 'text/html', 'Is text/html';

    ## grab di_id for later use
    $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $img = $dom_tree->getElementById ('props')->rows->[1]->cells->[3]->innerHTML;
    if ($img =~ /^(\d+)-qqimage/) {
        $di_id = $1;
        pass 'DI created';
    } else {
        fail 'DI created';
    }
    $dom_tree->close;
}

## try to create a new DI with invalid data
{
    $mech->follow_link_ok ({ text => 'New' }, 'Go to new DI');
    is $mech->ct, 'text/html', 'Is text/html';
    $mech->submit_form_ok ({
        fields => {
            osf_id     => 'non existent',
            disk_image => 'non existent',
        },
    }, 'New DI form');
    is $mech->ct, 'text/html', 'Is text/html';
    like $mech->content, qr{Unable to copy /var/lib/qvd/storage/staging/non existent .*: No such file or directory}, 'Error on invalid DI creation';
}

## delete non existing DI, expect error
{
    $mech->follow_link_ok ({ text => 'Disk images' }, 'Go to DIs');

    ## need to set form action attribute, since it's set via javascript IRL
    my $html = $mech->content;
    $html =~ s{method="post" name="propos" id="propos"}{method="post" action="http://localhost/di/del" name="propos" id="propos">}s;
    $mech->update_html ($html);

    $mech->submit_form_ok ({ form_name => 'propos', fields => { selected => 2**24-1 }}, 'Delete non existing DI');
    is $mech->ct, 'text/html', 'Is text/html';
    like $mech->content, qr{DI not found}, 'Error on invalid DI deletion';
}

## delete DI, check that it disappeared
{
    $mech->follow_link_ok ({ text => 'Disk images' }, 'Go to DIs');

    ## need to set form action attribute, since it's set via javascript IRL
    my $html = $mech->content;
    $html =~ s{method="post" name="propos" id="propos"}{method="post" action="http://localhost/di/del" name="propos" id="propos">}s;
    $mech->update_html ($html);

    $mech->submit_form_ok ({ form_name => 'propos', fields => { selected => $di_id }}, 'Delete DI');
    is $mech->ct, 'text/html', 'Is text/html';
    my $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $table_contents = $dom_tree->getElementById ('props')->tBodies->[0]->innerHTML;
    $dom_tree->close;
    like $table_contents, qr/^\s*$/, 'Disk images table is empty after removing DI';
}

## delete non existing OSF, expect error
{
    $mech->follow_link_ok ({ text => 'OS flavours' }, 'Go to OSFs');

    ## need to set form action attribute, since it's set via javascript IRL
    my $html = $mech->content;
    $html =~ s{method="post" name="propos" id="propos"}{method="post" action="http://localhost/osf/del" name="propos" id="propos">}s;
    $mech->update_html ($html);

    $mech->submit_form_ok ({ form_name => 'propos', fields => { selected => 2**24-1 }}, 'Delete non existing OSF');
    is $mech->ct, 'text/html', 'Is text/html';
    like $mech->content, qr{OSF not found}, 'Error on invalid OSF deletion';
}

## delete OSF, check that it disappeared
{
    $mech->follow_link_ok ({ text => 'OS flavours' }, 'Go to OSFs');

    ## need to set form action attribute, since it's set via javascript IRL
    my $html = $mech->content;
    $html =~ s{method="post" name="propos" id="propos"}{method="post" action="http://localhost/osf/del" name="propos" id="propos">}s;
    $mech->update_html ($html);

    $mech->submit_form_ok ({ form_name => 'propos', fields => { selected => $osf_id }}, 'Delete OSF');
    is $mech->ct, 'text/html', 'Is text/html';
    my $dom_tree = HTML::DOM->new; $dom_tree->write ($mech->content);
    my $table_contents = $dom_tree->getElementById ('props')->tBodies->[0]->innerHTML;
    $dom_tree->close;
    like $table_contents, qr/^\s*$/, 'OSF table is empty after removing OSF';
}

unlink '/var/lib/qvd/storage/staging/qqimage', glob '/var/lib/qvd/storage/images/*-qqimage';
