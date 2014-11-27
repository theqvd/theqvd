Wat.WS.changeWebsocketUser = function (id, field, data) {
    switch (field) {
        case 'number_of_vms_connected':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data);  
            
            if (data == 0) {
                $('.js-button-disconnect-all-vms').hide(); 
            }
            else {
                $('.js-button-disconnect-all-vms').show(); 
            }
            break;
        case 'number_of_vms':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data); 
            break;
    }
}