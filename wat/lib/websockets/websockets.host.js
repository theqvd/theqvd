Wat.WS.changeWebsocketHost = function (id, field, data) {
    switch (field) {
        case 'state':               
            $('[data-wsupdate="state"][data-id="' + id + '"]').removeAttr('data-i18n');
            switch (data) {
                case 'running':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-play');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Running'));                                
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Running'));                                                                
                    break;
                case 'starting':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-spinner fa-spin');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Starting'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Starting'));
                    break;
                case 'stopping':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-spinner fa-spin');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Stopping'));                                
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Stopping'));                                                                
                    break;
                case 'stopped':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-stop');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Stopped'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Stopped'));
                    break;
                default:
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-spinner fa-spin');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title',  data);
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(data);  
                    break;
            }
            break;
        case 'number_of_vms_connected':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data);  
            break;
    }
}