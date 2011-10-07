#!perl

use warnings;
use strict;
use Test::More tests => 28;

my $admin;
my $dir = '/var/lib/qvd/storage/staging';
my ($img1, $img2) = qw/img1 img2/;

sub osf_list {
    my %ret;
    eval {
        my $rs = $admin->get_resultset ('osf');
        while (my $osf = $rs->next) {
            my @row = map { $osf->$_ // '-' } qw(id name memory user_storage_size);
            $ret{ $row[0] } = {
                name              => $row[1],
                memory            => $row[2],
                user_storage_size => $row[3],
            };
        }
    };
    $@ and die "osf_list: $@\n";
    return %ret;
}

sub di_list {
    #my @args = @_;
    my %ret;
    eval {
        my $rs = $admin->get_resultset ('di');
        while (my $di = $rs->next) {
            my @row = ((map { $di->$_ // '-' } qw(id osf_id version path)), join ', ', $di->tag_list);
            $ret{ $row[0] } = {
                osf_id  => $row[1],
                version => $row[2],
                path    => $row[3],
                tags    => $row[4],
            };
        }
    };
    $@ and die "di_list: $@\n";
    return %ret;
}

BEGIN { use_ok ('QVD::Admin'); }
$admin = new_ok 'QVD::Admin';

if (osf_list or di_list) { die "this test expects an empty database to start with\n"; }

foreach my $img ($img1, $img2) {
    open my $fd, '>', "$dir/$img" or die "Creating fake disk image '$dir/$img': $!";
    close $fd;
}

my %osf_list;
my %di_list;
my $today = sprintf '%d-%02d-%02d', map { $_->[0]+1900, $_->[1]+1, $_->[2] } [ (localtime)[5, 4, 3] ];
my @tags;

diag 'create OSF 1';
my $osf_name = sprintf 'test1_osf_%d', int rand 10000;
my $osf1_id = $admin->cmd_osf_add (name => $osf_name);
%osf_list = osf_list;
ok 1 == keys %osf_list, 'One OSF present';

diag 'create DI 1';
my $di1_id = $admin->cmd_di_add (osf_id => $osf1_id, path => "$dir/$img1");
%di_list = di_list;
ok 1 == keys %di_list, 'One DI present';
is $di_list{$di1_id}{'version'}, "$today-000", 'check DI version';
@tags = split /, /, $di_list{$di1_id}{'tags'};
ok +(grep { $_ eq 'head' } @tags), 'Check DI head tag is present';
ok +(grep { $_ eq 'default' } @tags), 'Check DI default tag is present';

diag 'create DI 2';
my $di2_id = $admin->cmd_di_add (osf_id => $osf1_id, path => "$dir/$img2");
%di_list = di_list;
ok 2 == keys %di_list, 'Two DIs present';
is $di_list{$di2_id}{'version'}, "$today-001", 'check DI version';
@tags = split /, /, $di_list{$di1_id}{'tags'}; ok +(grep { $_ eq 'default' } @tags), 'Check DI default tag stays at previous DI';
@tags = split /, /, $di_list{$di2_id}{'tags'}; ok +(grep { $_ eq 'head' } @tags), 'Check DI head tag has moved to new DI';

diag 'create OSF 2';
$osf_name = sprintf 'test2_osf_%d', int rand 10000;
my $osf2_id = $admin->cmd_osf_add (name => $osf_name);
%osf_list = osf_list;
ok 2 == keys %osf_list, 'Two OSFs present';

diag 'create DI 3 in OSF 2';
my $di3_id = $admin->cmd_di_add (osf_id => $osf2_id, path => "$dir/$img1");
%di_list = di_list;
ok 3 == keys %di_list, 'Three DIs present';
is $di_list{$di3_id}{'version'}, "$today-000", 'check DI version';
@tags = split /, /, $di_list{$di3_id}{'tags'};
ok +(grep { $_ eq 'default' } @tags), 'Check DI default tag is present';
ok +(grep { $_ eq 'head' } @tags), 'Check DI head tag is present';

diag 'tag DI 2 as default';
$admin->cmd_di_tag (di_id => $di2_id, tag => 'default');
%di_list = di_list;
@tags = split /, /, $di_list{$di1_id}{'tags'}; ok +(!grep { $_ eq 'default' } @tags), 'Check DI default tag has moved (1/3)';
@tags = split /, /, $di_list{$di2_id}{'tags'}; ok +(grep { $_ eq 'default' } @tags), 'Check DI default tag has moved (2/3)';
@tags = split /, /, $di_list{$di3_id}{'tags'}; ok +(grep { $_ eq 'default' } @tags), 'Check DI default tag in other OSF is unchanged (3/3)';

diag 'tag DIs 2 and 3 as footag';
$admin->cmd_di_tag (di_id => $di2_id, tag => 'footag');
$admin->cmd_di_tag (di_id => $di3_id, tag => 'footag');
%di_list = di_list;
@tags = split /, /, $di_list{$di1_id}{'tags'}; ok +(!grep { $_ eq 'footag' } @tags), 'Check DI footag tag is not in first DI';
@tags = split /, /, $di_list{$di2_id}{'tags'}; ok +(grep { $_ eq 'footag' } @tags), 'Check DI footag tag is in second DI';
@tags = split /, /, $di_list{$di3_id}{'tags'}; ok +(grep { $_ eq 'footag' } @tags), 'Check DI footag tag is in third DI';

diag 'untag footag from DI 2';
$admin->cmd_di_untag (di_id => $di2_id, tag => 'footag');
%di_list = di_list;
@tags = split /, /, $di_list{$di1_id}{'tags'}; ok +(!grep { $_ eq 'footag' } @tags), 'Check DI footag tag is not in first DI';
@tags = split /, /, $di_list{$di2_id}{'tags'}; ok +(!grep { $_ eq 'footag' } @tags), 'Check DI footag tag is not in second DI';
@tags = split /, /, $di_list{$di3_id}{'tags'}; ok +(grep { $_ eq 'footag' } @tags), 'Check DI footag tag is still in third DI';

diag 'cleanup';
$admin->set_filter (id => $di3_id); $admin->cmd_di_del;
$admin->reset_filter;
%di_list = di_list;
ok 2 == keys %di_list, 'Two DIs left';

## could be done without a filter too
$admin->set_filter (id => $osf1_id); $admin->cmd_osf_del;
$admin->reset_filter;
%osf_list = osf_list;
ok 1 == keys %osf_list, 'One OSF left';
$admin->set_filter (id => $osf2_id); $admin->cmd_osf_del;
$admin->reset_filter;
%osf_list = osf_list;
ok 0 == keys %osf_list, 'No OSFs left after testing';

unlink "$dir/$img1", "$dir/$img2", (glob "$dir/../images/*-$img1"), (glob "$dir/../images/*-$img2");
