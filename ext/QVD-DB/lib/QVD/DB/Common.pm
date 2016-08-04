package QVD::DB::Common;
use strict;
use warnings FATAL => 'all';

use Exporter 'import';
our @EXPORT = qw();
our @EXPORT_OK = qw(ENUMERATES INITIAL_VALUES);

# Enumarate types
sub ENUMERATES {
    return {
        administrator_and_tenant_views_setups_device_type_enum =>
        [ qw(mobile desktop) ],
        administrator_and_tenant_views_setups_qvd_object_enum  =>
        [ qw(user vm log host osf di role administrator tenant) ],
        administrator_and_tenant_views_setups_view_type_enum   =>
        [ qw(filter list_column) ],
        log_qvd_object_enum                                    =>
        [ qw(user vm log host osf di role administrator tenant acl config tenant_view admin_view) ],
        log_type_of_action_enum                                =>
        [ qw(create create_or_update delete see update exec login) ],
        language_enum                                          =>
        [ qw(es en auto default) ],
        user_portal_parameters_enum                            =>
        [ qw(connection audio printers fullscreen share_folders share_usb) ],
    };
}

# Initial single values
sub INITIAL_VALUES {
    return {
        VM_State   => [ qw(stopped starting running stopping zombie debugging ) ],
        VM_Cmd     => [ qw(start stop busy) ],
        User_State => [ qw(disconnected connecting connected) ],
        User_Cmd   => [ qw(abort) ],
        Host_State => [ qw(stopped starting running stopping lost) ],
        Host_Cmd   => [ qw(stop) ],
    };
};

1;