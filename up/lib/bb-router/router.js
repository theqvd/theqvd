Up.Router = Backbone.Router.extend({    
    routes: {
        "logout": "logout",

        "virtualdesktops": "desktops",
        
        "settings": "settings",
        "clients": "clients",
        "info": "info",
        "help": "help",
        
        "documentation": "documentation",
        "documentation/search/:token": "documentationSearch",
        "documentation/:guide": "documentationGuide",
        "documentation/:guide/:section": "documentationGuide",
        
        "profile": "profile",
        
        "*actions": "defaultRoute" // Backbone will try match the route above first
    },
    
    initialize: function () {
        var that = this;
        
        // ------- List sections ------- //
        that.on('route:desktops', function (searchHash) {
            that.performRoute('vm', Up.Views.VMListView);
        });        
        
        // ------- Settings sections ------- //
        
        that.on('route:settings', function (searchHash) {
            that.performRoute('settings', Up.Views.SettingsView);
        });       
        
        // ------- Downloads sections ------- //
        
        that.on('route:clients', function (searchHash) {
            that.performRoute('clients', Up.Views.DownloadsView);
        });       
        
        // ------- Info sections ------- //
        
        that.on('route:info', function (searchHash) {
            that.performRoute('info', Up.Views.InfoView);
        });        

        // ------- Help sections ------- //
        
        that.on('route:help', function (searchHash) {
            that.performRoute('help', Up.Views.HelpView);
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

                that.performRoute('', Up.Views.LoginView);
            }, that);
        });          
        that.on('route:profile', function (actions) {
            that.performRoute('profile', Up.Views.ProfileView);
        });

        // ------- Default load ------- //
        that.on('route:defaultRoute', function (actions) {
            that.performRoute('vm', Up.Views.VMListView);
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
            /*Up.I.renderMain();
            view = Up.Views.LoginView;*/
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