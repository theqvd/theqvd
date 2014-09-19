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
        "setup/customize": "setupCustomize",
        "setup/tenants": "setupTenant",
        "setup/admins": "setupAdmin",
        "setup/admin/:id": "detailsAdmin",
        "setup/roles": "setupRole",
        "setup/role/:id": "detailsRole",
        "setup/config": "setupConfig",
        "help/about": "about",
        "*actions": "defaultRoute" // Backbone will try match the route above first
    },
    
    performRoute: function (menuOpt, view, params) {
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