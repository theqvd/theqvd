Wat.Router = Backbone.Router.extend({
    routes: {
        "logout": "logout",

        "vms": "listVM",
        "vms/:searchHash": "listVM",
                
        "*actions": "defaultRoute" // Backbone will try match the route above first
    },
    
    performRoute: function (menuOpt, view, params) {
        // Hide filter notes when route anywhere            
        $('.js-filter-notes').hide();
        $('.bb-related-docs').html('');
        
        params = params || {};
        if (!Wat.C.isLogged()) {
            Wat.I.renderMain();
            view = Wat.Views.LoginView;
        }

        Wat.I.showLoading();
        Wat.I.setMenuOpt(menuOpt);
        
        if (!$.isEmptyObject(Wat.CurrentView)) {
            Wat.CurrentView.undelegateEvents();
            Wat.WS.closeAllWebsockets();
        }
        
		// Abort pending requests
        if (Wat.C.abortOldRequests) {
            Wat.C.abortRequests();
        }
        
        Wat.CurrentView = new view(params);
    }
});