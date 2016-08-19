Up.I.Mobile = {
    loadSection: function (section) {
        if (!Up.I.isMobile() || !Up.L.isLogged()) {
            return;
        }
        
        // If there are open dialogs, close latest
        if (Up.CurrentView.dialogs.length) {
            Up.I.closeDialog(Up.CurrentView.dialogs.slice(-1)[0]);
        }
        
        switch (section) {
            case 'menu':
                $('.js-menu-lat').css('visibility', 'visible').slideToggle();
                break;
            default:
                $('.js-menu-lat').css('visibility', 'visible').slideUp();
                Up.I.renderHeaderMobile(section);
        }
    },
    
    afterOpenDialog: function () {
        if (!Up.I.isMobile()) {
            return;
        }
        
        var actionString = $(".ui-dialog-titlebar").html();
        
        $('.js-section-sub-title').html(actionString);
        
        $('.js-dialog-container').on('dialogclose', function(event) {
            // Restore subtitle
            $('.js-section-sub-title').html(Up.CurrentView.backSubtitle || '');
        });
    }
}