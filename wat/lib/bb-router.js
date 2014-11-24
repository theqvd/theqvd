Wat.Router = Backbone.Router.extend({
    routes: {
        "logout": "logout",
        "dis": "listDI",
        "dis/:field/:value": "listDI",
        "osfs": "listOSF",
        "hosts": "listHost",
        "vms": "listVM",
        "vms/:field/:value": "listVM",
        "vm/:id": "detailsVM",
        "di/:id": "detailsDI",
        "osf/:id": "detailsOSF",
        "host/:id": "detailsHost",
        "users": "listUser",
        "user/:id": "detailsUser",
        "views": "setupCustomize",
        "tenants": "listTenant",
        "admins": "listAdmin",
        "admin/:id": "detailsAdmin",
        "roles": "listRole",
        "role/:id": "detailsRole",
        "config": "setupConfig",
        "about": "about",
        "profile": "profile",
        "myviews": "myviews",
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
        }
        
        Wat.CurrentView = new view(params);
    }
});