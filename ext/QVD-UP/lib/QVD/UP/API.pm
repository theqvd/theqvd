package QVD::UP::API;
use strict;

use Exporter 'import';
our @EXPORT = qw(get_workspace get_workspaces create_workspace);

use QVD::DB::Simple qw(rs);

# TODO: Add functions to manage Desktops from main API module

# Functions to manage Workspaces

sub get_workspace {
    my ($user_id, $ws_id) = @_;
    
    my $user = rs('User')->find($user_id);
    my $workspace = $user->workspaces->find($ws_id);
    
    return $workspace;
}

sub get_workspaces {
    my ($user_id) = @_;
    
    my $user = rs('User')->find($user_id);
    my $workspaces =  [ $user->workspaces->search({}, { order_by => { -asc => 'id' } })->all ];
    
    return $workspaces;
}

sub create_workspace {
    my ($user_id, $ws_name, $ws_is_active, $ws_settings, $ws_is_fixed) = @_;
    
    my $args = {};
    $args->{name} = $ws_name;
    $args->{active} = $ws_is_active;
    $args->{fixed} = $ws_is_fixed // 0;
    
    my $active_workspaces = rs('Workspace')->search({user_id => $user_id, active => 1});
    if ($args->{active}) {
        $active_workspaces->update({active => 0});
    } elsif (scalar($active_workspaces->all()) == 0) {
        $args->{active} = 1;
    }
    
    my $workspace = rs('Workspace')->create({
        user_id => $user_id,
        %$args
    });
    # DBIx::Class do not assign default values in creation and have to be fetched
    $workspace->discard_changes;
    
    for my $param (keys %{$ws_settings}) {
        my $setting = rs( 'Workspace_Setting' )->create( {
            workspace_id => $workspace->id,
            parameter    => $param,
            value        => $ws_settings->{$param}->{value},
        } );
        for my $item (@{$ws_settings->{$param}->{list} // [ ]}) {
            rs( 'Workspace_Setting_Collection' )->create( {
                setting_id => $setting->id,
                item_value => $item
            } );
        }
    }
    
    return $workspace;
}

# TODO: Extract functions to delete and update Workspaces from API main

1;