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
        "vm/:id/spy": "spyVM",
        
        "users": "listUser",
        "users/:searchHash": "listUser",
        "user/:id": "detailsUser",
        
        "views": "viewCustomize",
        "myviews": "myviews",

        "tenants": "listTenant",
        "tenants/:searchHash": "listTenant",
        "tenant/:id": "detailsTenant",
        
        "properties": "property",
        
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
    
    initialize: function () {
        var that = this;
        
        // ------- List sections ------- //
        that.on('route:listVM', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }
            that.performRoute('vms', Wat.Views.VMListView, params);
        });        

        that.on('route:listUser', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('users', Wat.Views.UserListView, params);
        });       

        that.on('route:listHost', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('hosts', Wat.Views.HostListView, params);
        });      

        that.on('route:listOSF', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('osfs', Wat.Views.OSFListView, params);
        });    

        that.on('route:listDI', function (searchHash) {
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('dis', Wat.Views.DIListView, params);
        });



        // ------- Details sections ------- //
        that.on('route:detailsUser', function (id) {
            that.performRoute('users', Wat.Views.UserDetailsView, {"id": id});
        });

        that.on('route:detailsVM', function (id) {
            that.performRoute('vms', Wat.Views.VMDetailsView, {"id": id});
        });
        
        that.on('route:spyVM', function (id) {
            that.performRoute('vms', Wat.Views.VMSpyView, {"id": id});
        });

        that.on('route:detailsHost', function (id) {
            that.performRoute('hosts', Wat.Views.HostDetailsView, {"id": id});
        });

        that.on('route:detailsOSF', function (id) {
            that.performRoute('osfs', Wat.Views.OSFDetailsView, {"id": id});
        });

        that.on('route:detailsDI', function (id) {
            that.performRoute('dis', Wat.Views.DIDetailsView, {"id": id});
        });



        // ------- Configuration sections ------- //
        that.on('route:viewCustomize', function () {
            that.performRoute('views', Wat.Views.SetupCustomizeView);
        });   

        that.on('route:setupConfig', function (token) {
            var params = {};
            if (token) {
                params.currentTokensPrefix = token;
            }
            that.performRoute('config', Wat.Views.ConfigQvdView, params);
        });  

        that.on('route:watConfig', function () {
            that.performRoute('watconfig', Wat.Views.ConfigWatView);
        });  


        that.on('route:listTenant', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('tenants', Wat.Views.TenantListView, params);
        });  

        that.on('route:detailsTenant', function (id) {
            that.performRoute('tenants', Wat.Views.TenantDetailsView, {"id": id});
        });

        that.on('route:property', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('properties', Wat.Views.PropertyView, params);
        });

        that.on('route:listAdmin', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('administrators', Wat.Views.AdminListView, params);
        });

        that.on('route:detailsAdmin', function (id) {
            that.performRoute('administrators', Wat.Views.AdminDetailsView, {"id": id});
        });   


        that.on('route:listRole', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('roles', Wat.Views.RoleListView, params);
        });  

        that.on('route:detailsRole', function (id) {
            that.performRoute('roles', Wat.Views.RoleDetailsView, {"id": id});
        });    


        that.on('route:listLog', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Wat.U.base64.decodeObj(searchHash);
            }

            that.performRoute('logs', Wat.Views.LogListView, params);
        });    

        that.on('route:detailsLog', function (id) {
            that.performRoute('logs', Wat.Views.LogDetailsView, {"id": id});
        });    


        // ------- Help sections ------- //
        that.on('route:about', function (actions) {
            that.performRoute('about', Wat.Views.AboutView);
        });
        that.on('route:documentation', function (actions) {
            that.performRoute('documentation', Wat.Views.DocView);
        });
        that.on('route:documentationGuide', function (guide, section) {
            that.performRoute('documentation', Wat.Views.DocView, {
                "guide": guide,
                "section": section
            });
        });
        that.on('route:documentationSearch', function (searchKey) {
            that.performRoute('documentation', Wat.Views.DocView, {
                "searchKey": searchKey
            });
        });



         // ------- Current administrator ------- //
        that.on('route:logout', function (actions) {
            Wat.A.apiLogOut(function (that) {
                Wat.L.logOut();
                Wat.C.configureVisibility();
                Wat.I.renderMain();

                that.performRoute();
            }, that);
        });          
        that.on('route:profile', function (actions) {
            that.performRoute('profile', Wat.Views.ProfileView);
        });             
        that.on('route:myviews', function (actions) {
            that.performRoute('myviews', Wat.Views.MyViewsView);
        });       


        // ------- Default load ------- //
        that.on('route:defaultRoute', function (actions) {
            that.performRoute('', Wat.Views.HomeView);
        });

        // Start Backbone history
        Backbone.history.start();   

        Wat.C.routerHistoryStarted = true;
    },
    
    performRoute: function (menuOpt, view, params) {
        // Hide filter notes when route anywhere            
        $('.js-filter-notes').hide();
        
        params = params || {};
        if (!Wat.L.isLogged()) {
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
            clearInterval(Wat.CurrentView.executionAnimationInterval);
        }
        
        Wat.CurrentView = new view(params);
    }
});