Wat.WS.changeWebsocketVm = function (id, field, data) {
   switch (field) {
        case 'state':
            switch (data) {
                case 'running':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-play');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Running'));                                
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Running'));                                
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-start-vm fa-start').addClass('js-button-stop-vm fa-stop').attr('title', i18n.t('Stop')).removeClass('disabled');                                   
                    $('[data-wsupdate="ip"][data-id="' + id + '"]').removeClass('invisible');                             
                    break;
                case 'stopped':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-stop');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Stopped'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Stopped'));
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-stop-vm fa-stop').addClass('js-button-start-vm fa-start').attr('title', i18n.t('Start')).removeClass('disabled');                                       
                    $('[data-wsupdate="ip"][data-id="' + id + '"]').addClass('invisible');                           
                    break;
                default:
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', 'fa fa-spinner fa-spin');
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title',  data);
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(data);  
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').addClass('disabled');                                       
                    $('[data-wsupdate="ip"][data-id="' + id + '"]').removeClass('invisible');  
                    break;
            }
            break;
        case 'user_state':
            switch (data) {
                case 'connected':
                    $('[data-wsupdate="user_state"][data-id="' + id + '"]').show();
                    $('[data-wsupdate="user_state-text"][data-id="' + id + '"]').html(i18n.t('Connected')); 
                    break;
                case 'disconnected':
                    $('[data-wsupdate="user_state"][data-id="' + id + '"]').hide();
                    $('[data-wsupdate="user_state-text"][data-id="' + id + '"]').html(i18n.t('Disconnected')); 
                    break;
            }
            break;
        case 'ssh_port':
        case 'vnc_port':
        case 'serial_port':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data); 
            break;
        case 'host_id':
            $('[data-wsupdate="host"][data-id="' + id + '"] a').attr('href', '#/host/' + data); 
            break;
        case 'host':
            $('[data-wsupdate="host"][data-id="' + id + '"] a').html(data); 
            break;
    }
}