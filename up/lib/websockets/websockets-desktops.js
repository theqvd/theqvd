Up.WS.changeWebsocketDesktops = function (data) {
    var id = data.id;
    delete data.id;
    
    $.each(data, function (field, value) {
        switch (field) {
            case 'user_state':
                // Check if function exists to avoid fail when change section just before websocket push
                if (typeof Up.CurrentView.setDesktopState == 'function') {
                    Up.CurrentView.setDesktopState(id, value);
                }
                break;
        }
    });
}