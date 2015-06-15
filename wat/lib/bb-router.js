Wat.Router = Backbone.Router.extend({
    routes: {
        "logout": "logout",
        
        "dis": "listDI",
        "dis/:searchHash": "listDI",
        "di/:id": "detailsDI",

        "osfs": "listOSF",
        "osfs/:searchHash": "listOSF",
        "osf/:id": "detailsOSF",

        "hosts": "listHost",
        "hosts/:searchHash": "listHost",
        "host/:id": "detailsHost",

        "vms": "listVM",
        "vms/:searchHash": "listVM",
        "vm/:id": "detailsVM",
        
        "users": "listUser",
        "users/:searchHash": "listUser",
        "user/:id": "detailsUser",
        
        "views": "viewCustomize",
        "myviews": "myviews",

        "tenants": "listTenant",
        "tenants/:searchHash": "listTenant",
        "tenant/:id": "detailsTenant",
        
        "administrators": "listAdmin",
        "administrators/:searchHash": "listAdmin",
        "administrator/:id": "detailsAdmin",
        
        "roles": "listRole",
        "roles/:searchHash": "listRole",
        "role/:id": "detailsRole",
        
        "config": "setupConfig",
        "config/:token": "setupConfig",
        
        "watconfig": "watConfig",
        
        "about": "about",
        
        "documentation": "documentation",
        "documentation/search/:token": "documentationSearch",
        "documentation/:guide": "documentationGuide",
        "documentation/:guide/:section": "documentationGuide",
        
        "profile": "profile",
        
        "logs": "listLog",
        "logs/:searchHash": "listLog",
        "log/:id": "detailsLog",
        
        "*actions": "defaultRoute" // Backbone will try match the route above first
    },
    
    performRoute: function (menuOpt, view, params) {
        // Hide filter notes when route anywhere            
        $('.js-filter-notes').hide();
        
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