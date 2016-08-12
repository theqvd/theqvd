Wat.WS.changeWebsocketVm = function (id, field, data, viewType) {
    switch (field) {
        case 'state':
            if (viewType == 'details' && Wat.CurrentView.model) {
                // Add this effect when data will be received only when change
                $('.js-body-state').hide();
                $('[data-wsupdate="state-' + data + '"][data-id="' + id + '"]').show();
            }
           
            $('[data-wsupdate="ip"][data-id="' + id + '"]').addClass('invisible');   

            switch (viewType) {
                case 'list':
                    $('.js-name .vm-state-' + id).remove();
                    
                    var hiddenState = document.createElement("INPUT");
                    $(hiddenState).attr('type', 'hidden');
                    $(hiddenState).attr('class', 'vm-state-' + id);
                    $(hiddenState).val(data);
                    $('tr.row-' + id + '>td.js-name').append(hiddenState);

                    break;
                case 'details':
                    $('.js-vm-execution-table').attr('data-state', data);
                    break;
            }

            switch (data) {
                case 'running':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', CLASS_ICON_STATUS_RUNNING);
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Running'));                                
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Running')).removeClass('faa-flash animated');                                
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-start-vm ' + CLASS_ICON_STATUS_RUNNING + ' invisible').addClass('js-button-stop-vm ' + CLASS_ICON_STATUS_STOPPED).attr('title', i18n.t('Stop')).find('span').html(i18n.t('Stop'));                                   
                    $('[data-wsupdate="ip"][data-id="' + id + '"]').removeClass('invisible');   
                    $('.remote-administration-buttons a').removeClass('disabled');   
                    break;
                case 'stopped':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', CLASS_ICON_STATUS_STOPPED);
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Stopped'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Stopped')).removeClass('faa-flash animated');
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-stop-vm ' + CLASS_ICON_STATUS_STOPPED + ' invisible').addClass('js-button-start-vm ' + CLASS_ICON_STATUS_RUNNING).attr('title', i18n.t('Start')).find('span').html(i18n.t('Start')); 
                    if (Wat.CurrentView.restarting) {
                        Wat.CurrentView.restarting = false;
                        Wat.CurrentView.startVM();
                    }
                    break;
                case 'starting':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', CLASS_ICON_STATUS_STARTING);
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Starting'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Starting')).addClass('faa-flash animated');  
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-start-vm ' + CLASS_ICON_STATUS_RUNNING + ' invisible').addClass('js-button-stop-vm ' + CLASS_ICON_STATUS_STOPPED).attr('title', i18n.t('Stop')).find('span').html(i18n.t('Stop')); 
                    break;
                case 'stopping':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', CLASS_ICON_STATUS_STOPPING);
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Stopping'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Stopping')).addClass('faa-flash animated');  
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-start-vm ' + CLASS_ICON_STATUS_RUNNING + ' invisible').addClass('js-button-stop-vm ' + CLASS_ICON_STATUS_STOPPED).attr('title', i18n.t('Stop')).find('span').html(i18n.t('Stop'));    
                    
                    $('.remote-administration-buttons a').addClass('disabled');
                    
                    $('[data-wsupdate="state-running"]').hide();
                    $('.js-execution-params-button-row').show();
                    $('.js-execution-params').hide();
                    
                    // When virtual machine is stopping, hide warning of mismatch DI if is visible
                    $('[data-wsupdate="di_warning_icon"][data-id="' + id + '"]').hide(); 
                    break;
                case 'zombie':
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('class', CLASS_ICON_STATUS_ZOMBIE);
                    $('[data-wsupdate="state"][data-id="' + id + '"]').attr('title', i18n.t('Zombie'));
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(i18n.t('Zombie')).removeClass('faa-flash animated');
                    $('[data-wsupdate="state-button"][data-id="' + id + '"]').removeClass('js-button-stop-vm ' + CLASS_ICON_STATUS_STOPPED + ' js-button-start-vm ' + CLASS_ICON_STATUS_RUNNING).addClass('invisible');
                    $('[data-wsupdate="state-running"]').hide();
                    break;
            }
            break;
        case 'user_state':
            switch (data) {
                case 'connected':
                    $('[data-wsupdate="user_state"][data-id="' + id + '"]').show();
                    $('[data-wsupdate="user_state-text"][data-id="' + id + '"]').html(i18n.t('Connected')); 
                    $('[data-wsupdate="user_state-button"]').show(); 
                    break;
                case 'disconnected':
                    $('[data-wsupdate="user_state"][data-id="' + id + '"]').hide();
                    $('[data-wsupdate="user_state-text"][data-id="' + id + '"]').html(i18n.t('Disconnected')); 
                    $('[data-wsupdate="user_state-button"]').hide(); 
                    break;
            }
            break;
        case 'ssh_port':
        case 'vnc_port':
        case 'serial_port':
            $('[data-wsupdate="' + field + '"][data-id="' + id + '"]').html(data == 0 ? '-' : data); 
            break;
        case 'host_id':
            $('[data-wsupdate="host"][data-id="' + id + '"] a').attr('href', '#/host/' + data); 
            break;
        case 'host_name':
            if ($('[data-wsupdate="host"][data-id="' + id + '"] a').length > 0) {
                var hostNameContainer = $('[data-wsupdate="host"][data-id="' + id + '"] a');
            }
            else {
                var hostNameContainer = $('[data-wsupdate="host"][data-id="' + id + '"]');
            }
            hostNameContainer.html(data); 
            break;
        case 'di_version_in_use':
            $('[data-wsupdate="di_version"][data-id="' + id + '"]').html(data);
            break;
        case 'di_id_in_use':
            $('[data-wsupdate="di"][data-id="' + id + '"] a').attr('href', '#/di/' + data); 
            break;
        case 'di_name_in_use':
            if ($('[data-wsupdate="di"][data-id="' + id + '"] a').length > 0) {
                var diNameContainer = $('[data-wsupdate="di"][data-id="' + id + '"] a');
            }
            else {
                var diNameContainer = $('[data-wsupdate="di"][data-id="' + id + '"]');
            }
            diNameContainer.html(data); 
            break;
        case 'ip_in_use':
            $('[data-wsupdate="ip"][data-id="' + id + '"]').html(data); 
            break;
        case 'expiration_soft':
        case 'expiration_hard':   
            switch (viewType) {
                case 'list':
                    // Expiration ICON on info column
                    if ($('[data-wsupdate="expiration-icon"]').length > 0) {
                        // Update expiration data on iconattributes
                        $('[data-wsupdate="expiration-icon"][data-id="' + id + '"]').attr('data-' + field, data);
                        
                        var newExpiration = {
                            expiration_soft: $('[data-wsupdate="expiration-icon"][data-id="' + id + '"]').attr('data-expiration_soft'),
                            expiration_hard: $('[data-wsupdate="expiration-icon"][data-id="' + id + '"]').attr('data-expiration_hard')
                        }
                    
                        if (newExpiration.expiration_soft || newExpiration.expiration_hard) {
                            $('[data-wsupdate="expiration-icon"][data-id="' + id + '"]').show();
                        }
                        else {
                            $('[data-wsupdate="expiration-icon"][data-id="' + id + '"]').hide();
                        }
                    }
                    
                    // Expiration CELL on expiration columns
                    if ($('[data-wsupdate="' + field + '-cell"]').length > 0) {
                        var oldExpiration = $('[data-wsupdate="' + field + '-cell"][data-id="' + id + '"]').attr('data-' + field);
                        var newExpiration = data;
                        
                        // Update expiration data on cells attributes
                        $('[data-wsupdate="' + field + '-cell"][data-id="' + id + '"]').attr('data-' + field, newExpiration);
                        
                        if (data) {                
                            var expChanged = false;
                            if (typeof oldExpiration == "undefined" || oldExpiration != newExpiration) {
                                expChanged = true;
                            }

                            if (expChanged) {
                                var model = Wat.CurrentView.collection.where({id: id})[0];
                                var remainingTime = Wat.U.processRemainingTime(model.get('time_until_' + field));
                                
                                var template = _.template(
                                    Wat.TPL.vmListExpiration, {
                                        remainingTime: remainingTime,
                                        expiration: Wat.U.jsonDateToString(model.get(field)),
                                        time_until_expiration_raw: Wat.U.base64.encodeObj(model.get('time_until_' + field)),
                                    }
                                );

                                $('[data-wsupdate="' + field + '-cell"][data-id="' + id + '"]').html(template);
                            }
                        }
                        else {
                            $('[data-wsupdate="' + field + '-cell"][data-id="' + id + '"]').html('');
                        }
                    }
                    break;
                case 'details':
                    // Expiration row on details view
                    if (Wat.C.checkACL('vm.see.expiration')) {
                        var model = Wat.CurrentView.model;

                        var remainingTime = Wat.U.processRemainingTime(model.get('time_until_' + field));
                        
                        // Update expiration data on row attributes
                        $('[data-wsupdate="' + field + '-row"][data-id="' + id + '"]').attr('data-' + field, data);

                        var template = _.template(
                            Wat.TPL.vmDetailsExpiration, {
                                expiration_soft: Wat.U.jsonDateToString(model.get('expiration_soft')),
                                expiration_hard: Wat.U.jsonDateToString(model.get('expiration_hard')),
                                remainingTimeSoft: Wat.U.processRemainingTime(model.get('time_until_expiration_soft')),
                                remainingTimeHard: Wat.U.processRemainingTime(model.get('time_until_expiration_hard')),
                                time_until_expiration_soft_raw: Wat.U.base64.encodeObj(model.get('time_until_expiration_soft')),
                                time_until_expiration_hard_raw: Wat.U.base64.encodeObj(model.get('time_until_expiration_hard')),
                            }
                        );

                        $('.bb-vm-details-expiration').html(template);
                        Wat.T.translate();
                    }
                    break;
            }
            break;
    }
}