Up.I.Mobile = {
    loadSection: function (section) {
        if (!Up.I.isMobile() || !Up.L.isLogged()) {
            return;
        }
        
        // If there are open dialogs, close latest
        if (Up.CurrentView.dialogs.length) {
            Up.I.closeDialog(Up.CurrentView.dialogs.slice(-1)[0]);
            return;
        }
        
        switch (section) {
            case 'menu':
                $('.js-menu-lat').removeClass('menu-lat--hidden');
                $('.menu-option').removeClass('menu-option--current menu-option-current');
                Up.I.renderHeader();
                
                window.location.hash = '#'
                if (history.pushState) {
                    history.pushState(null, null, "");
                }
                break;
            default:
                $('.js-menu-lat').addClass('menu-lat--hidden');
                Up.I.renderHeaderSection(section);

                if (Up.CurrentView.loadSectionCallback && Up.CurrentView.loadSectionCallback[section]) {
                    Up.CurrentView.loadSectionCallback[section](Up.CurrentView);
                }
        }
    },
    
    afterOpenDialog: function () {
        if (!Up.I.isMobile()) {
            return;
        }
        
        var actionString = $(".ui-dialog-titlebar").html();
        
        $('.js-section-sub-title').html(actionString);
        
        $('.js-dialog-container').on('dialogclose', function(event) {
             $('.js-section-sub-title').html('');
        });
    }
}