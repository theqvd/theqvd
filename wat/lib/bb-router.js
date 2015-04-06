Wat.Router = Backbone.Router.extend({
    routes: {
        "logout": "logout",
        "dis": "listDI",
        "dis/:field/:value": "listDI",
        "osfs": "listOSF",
        "hosts": "listHost",
        "hosts/:field/:value": "listHost",
        "vms": "listVM",
        "vms/:field/:value": "listVM",
        "vm/:id": "detailsVM",
        "di/:id": "detailsDI",
        "osf/:id": "detailsOSF",
        "host/:id": "detailsHost",
        "users": "listUser",
        "users/:field/:value": "listUser",
        "user/:id": "detailsUser",
        "views": "setupCustomize",
        "tenants": "listTenant",
        "tenant/:id": "detailsTenant",
        "administrators": "listAdmin",
        "administrator/:id": "detailsAdmin",
        "roles": "listRole",
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
        "myviews": "myviews",
        "log": "listLog",
        "log/:field/:value": "listLog",
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
        
		// Abort current requests
        Wat.C.abortRequests();
        
        Wat.CurrentView = new view(params);
    }
});