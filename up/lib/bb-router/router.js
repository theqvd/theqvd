Up.Router = Backbone.Router.extend({    
    routes: {
        "logout": "logout",

        "vms": "listVM",
        "vms/:searchHash": "listVM",
        "vm/:id": "detailsVM",
        
        "users": "listUser",
        "users/:searchHash": "listUser",
        "user/:id": "detailsUser",
        
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
                params = Up.U.base64.decodeObj(searchHash);
            }
            that.performRoute('vms', Up.Views.VMListView, params);
        });        

        that.on('route:listUser', function (searchHash) {   
            var params = {};
            if (searchHash !== null) {
                params = Up.U.base64.decodeObj(searchHash);
            }

            that.performRoute('users', Up.Views.UserListView, params);
        });


        // ------- Details sections ------- //
        that.on('route:detailsUser', function (id) {
            that.performRoute('users', Up.Views.UserDetailsView, {"id": id});
        });

        that.on('route:detailsVM', function (id) {
            that.performRoute('vms', Up.Views.VMDetailsView, {"id": id});
        });

        // ------- Help sections ------- //
        that.on('route:about', function (actions) {
            that.performRoute('about', Up.Views.AboutView);
        });
        that.on('route:documentation', function (actions) {
            that.performRoute('documentation', Up.Views.DocView);
        });
        that.on('route:documentationGuide', function (guide, section) {
            that.performRoute('documentation', Up.Views.DocView, {
                "guide": guide,
                "section": section
            });
        });
        that.on('route:documentationSearch', function (searchKey) {
            that.performRoute('documentation', Up.Views.DocView, {
                "searchKey": searchKey
            });
        });


         // ------- Current administrator ------- //
        that.on('route:logout', function (actions) {
            Up.A.apiLogOut(function (that) {
                Up.L.logOut();
                Up.C.configureVisibility();
                Up.I.renderMain();

                that.performRoute();
            }, that);
        });          
        that.on('route:profile', function (actions) {
            that.performRoute('profile', Up.Views.ProfileView);
        });

        // ------- Default load ------- //
        that.on('route:defaultRoute', function (actions) {
            that.performRoute('', Up.Views.VMListView);
        });

        // Start Backbone history
        Backbone.history.start();   

        Up.C.routerHistoryStarted = true;
    },
    
    performRoute: function (menuOpt, view, params) {
        // Hide filter notes when route anywhere            
        $('.js-filter-notes').hide();
        
        params = params || {};
        if (!Up.L.isLogged()) {
            Up.I.renderMain();
            view = Up.Views.LoginView;
        }

        Up.I.showLoading();
        Up.I.setMenuOpt(menuOpt);
        
        if (!$.isEmptyObject(Up.CurrentView)) {
            Up.CurrentView.undelegateEvents();
            Up.WS.closeAllWebsockets();
        }
        
		// Abort pending requests
        if (Up.C.abortOldRequests) {
            Up.C.abortRequests();
            clearInterval(Up.CurrentView.executionAnimationInterval);
        }
        
        Up.CurrentView = new view(params);
    }
});