Wat.I.M = {
    // Messages
    showMessage: function (msg, response) {
        // Process message to set expanded message if proceeds
        msg = this.processMessage (msg, response);
        
        this.clearMessageTimeout();
        
        if (msg.expandedMessage) {
            var expandIcon = '<i class="fa fa-plus-square-o expand-message js-expand-message"></i>';
            var expandedMessage = '<article class="expandedMessage">' + msg.expandedMessage + '</article>';
        }
        else {
            var expandIcon = '';
            var expandedMessage = '';
        }
        
        var summaryMessage = '<summary>' + $.i18n.t(msg.message) + '</summary>';
        
        $('.message').html(expandIcon + summaryMessage + expandedMessage);
        
        Wat.T.translate();

        $('.message-container').hide().slideDown(500);
        $('.message-container').removeClass('success error info warning');
        $('.message-container').addClass(msg.messageType);
        
        // Success and info messages will be hidden automatically
        if (msg.messageType != 'error' && msg.messageType != 'warning') {
            this.messageTimeout = setTimeout(function() { 
                Wat.I.M.closeMessage();
            },3000);
        }
    },
    
    
    closeMessage: function () {
        this.clearMessageTimeout();
        $('.js-message-container').slideUp(500);
    },
    
    setMessageTimeout: function () {
        this.clearMessageTimeout();
        this.messageTimeout = setTimeout(function() { 
            $('.message-close').trigger('click');
        },3000);
    },
    
    clearMessageTimeout: function () {
        if (this.messageTimeout) {
            clearInterval(this.messageTimeout);
        }
    },
    
    processMessage: function (msg, response) {
        if (!response) {
            return msg;
        }
        
        if (!msg.message) {
            msg.message = response.message;
        }
        
        switch (msg.messageType) {
            case 'error':
                msg.expandedMessage = msg.expandedMessage || '';
                
                if (response.message != msg.message && response.message) {
                    msg.expandedMessage += '<strong data-i18n="' + response.message + '">' + response.message + '</strong> <br/><br/>';
                }
            
                if (response.failures && !$.isEmptyObject(response.failures)) {
                    msg.expandedMessage += this.getTextFromFailures(response.failures) + '<br/>';
                }
                break;
        }
        
        return msg;
    },
    
    getTextFromFailures: function (failures) {
        // Group failures by text
        var failuresByText = {};
        $.each(failures, function(id, text) {
            failuresByText[text.message] = failuresByText[text.message] || [];
            failuresByText[text.message].push(id);
        });
        
        // Get class from the icon of the selected item from menu to use it in list
        var elementClass = $('.menu-option--selected').find('i').attr('class');
        
        var failuresList = '<ul>';
        $.each(failuresByText, function(text, ids) {
            failuresList += '<li>';
            failuresList += '<i class="fa fa-angle-double-right strong" data-i18n="' + text + '">' + text + '</i>';
            failuresList += '<ul>';
            $.each(ids, function(iId, id) {
                if ($('.list')) {
                    var elementName = $('.list').find('tr.row-' + id).find('.js-name .text').html();
                    if (!elementName) {
                        elementName = '(ID: ' + id + ')';
                    }
                    
                    failuresList += '<li class="' + elementClass + '">' + elementName + '</li>';
                }
                else {
                    failuresList += '<li class="' + elementClass + '">' + id + '</li>';
                }
            });
            failuresList += '</ul>';
            failuresList += '</li>';
        });
        
        failuresList += '</ul>';
        
        return failuresList;
    },
}