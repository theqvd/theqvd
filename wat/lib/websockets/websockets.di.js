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
                    $('[data-id="' + id + '"] .js-progressbar-times--elapsed').show();
                    break;
            }
            
            // Change row styles
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--new');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--generating');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--uploading');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--upload_stalled');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--verifying');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--fail');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--ready');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--published');
            $('[data-id="' + id + '"].js-di-row-state').removeClass('di-row-state--retired');
            
            $('[data-id="' + id + '"].js-di-row-state').addClass('di-row-state--' + data);
            
            // Status label
            
            var statusStr = '';
            
            switch(data) {
                case 'new':
                case 'generating':
                    statusStr = 'Generating';
                    break;
                case 'uploading':
                    statusStr = 'Uploading';
                    break;
            }
            
            if (statusStr) {
                $('[data-id="' + id + '"] .js-progress-label--state').html($.i18n.t(statusStr) + ': ');
            }
            
            // Icons for autopublish and expiration time
            
            $('[data-id="' + id + '"] .js-auto-publish-icon').show();
            $('[data-id="' + id + '"] .js-expiration-icon').show();
            
            switch(data) {
                case 'published':
                case 'ready':
                    $('[data-id="' + id + '"] .js-auto-publish-icon').hide();
                    $('[data-id="' + id + '"] .js-expiration-icon').hide();
                    break;
            }
            
            break;
    }
}