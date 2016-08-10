Up.WS.changeWebsocketDesktops = function (data) {
    var id = data.id;
    delete data.id;
    
    $.each(data, function (field, value) {
        switch (field) {
            case 'user_state':
                Up.CurrentView.setDesktopState(id, value);
                break;
        }
    });
}