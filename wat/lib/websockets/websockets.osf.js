Wat.WS.changeWebsocketOsf = function (id, field, data) {
    switch (field) {
        case 'number_of_dis':
        case 'number_of_vms':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data); 
            break;
    }
}