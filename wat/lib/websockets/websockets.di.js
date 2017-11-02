Wat.WS.changeWebsocketDi = function (id, field, data, row) {
    switch (field) {
        case 'percentage':
            var view = Wat.U.getViewFromQvdObj('di');
            var progressBar = $('.progressbar[data-id="' + id + '"]');
            var percentage = parseFloat(row.percentage * 100).toFixed(2);
            
            $(progressBar).attr('data-percent', percentage);
            $(progressBar).attr('data-remaining', Wat.U.getRemainingTime(row.elapsed_time, percentage));
            $(progressBar).attr('data-elapsed', row.elapsed_time);
            break;
        case 'state':
            // Show proper icon
            $('[data-id="' + id + '"] .js-progress-icon').hide();
            $('[data-id="' + id + '"] .js-progress-icon--' + data).show();
            
            // Show/Hide progress bar
            $('[data-id="' + id + '"] .js-progressbar').hide();
            $('[data-id="' + id + '"] .js-progressbar-times').hide();
            
            switch (data) {
                case 'generating':
                    $('[data-id="' + id + '"] .js-progressbar').show();
                    $('[data-id="' + id + '"] .js-progressbar-times--remaining').show();
                    $('[data-id="' + id + '"] .js-progressbar-times--elapsed').show();
                    break;
                case 'uploading':
                    $('[data-id="' + id + '"] .js-progressbar').show();
                    break;
            }
            
            // Change row styles
            $.each(Wat.I.detailsFields.di.general.fieldList.state.options, function (key, values) {
                $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--' + key);
            });
            
            $('[data-id="' + id + '"].js-di-row-state').addClass('di-row-state--' + data);
            
            
            var statusStr = $.i18n.t(Wat.I.detailsFields.di.general.fieldList.state.options[data].text);
            
            // Status label
            switch(data) {
                case 'generating':
                case 'uploading':
                    $('[data-id="' + id + '"] .js-progress-label--state').html($.i18n.t(statusStr) + ': ');
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').hide();
                    break;
                default:
                    $('[data-wsupdate="state-text"][data-id="' + id + '"]').show();
            }
            
            if (row['status_message']) {
                statusStr += ': ' + row['status_message'];
            }
            
            $('[data-id="' + id + '"] .js-progress-icon--' + data).attr('title', statusStr);
            $('[data-wsupdate="state-text"][data-id="' + id + '"]').html(statusStr);
            
            // Icons for autopublish and expiration time
            
            $('[data-id="' + id + '"] .js-auto-publish-icon').show();
            $('[data-id="' + id + '"] .js-expiration-icon').show();
            
            switch(data) {
                case 'published':
                    $('[data-id="' + id + '"] .js-expiration-icon').hide();
                case 'ready':
                    $('[data-id="' + id + '"] .js-auto-publish-icon').hide();
                    break;
            }
            
            // Icons for default and tags
            $('[data-id="' + id + '"] .js-head-icon').hide();
            $('[data-id="' + id + '"] .js-default-icon').hide();
            $('[data-id="' + id + '"] .js-tags-icon').hide();
            $('[data-id="' + id + '"] .js-future-tags-icon').show();
            
            // For details view
            $('[data-field-code="head"]').hide();
            $('.js-future-tags-note').show();
            
            switch(data) {
                case 'published':
                    if ($('[data-id="' + id + '"] .js-head-icon').length) {
                        $('[data-osf-id="' + row['osf_id'] + '"] .js-head-icon').hide();
                        $('[data-id="' + id + '"] .js-head-icon').show();
                    }
                    if ($('[data-id="' + id + '"] .js-default-icon').length) {
                        $('[data-osf-id="' + row['osf_id'] + '"] .js-default-icon').hide();
                        $('[data-id="' + id + '"] .js-default-icon').show();
                    }
                    $('[data-id="' + id + '"] .js-tags-icon').show();
                    $('[data-id="' + id + '"] .js-future-tags-icon').hide();
                    
                    // For details view
                    $('[data-field-code="head"]').show();
                    $('.js-future-tags-note').hide();
                    break;
            }
            break;
    }
}