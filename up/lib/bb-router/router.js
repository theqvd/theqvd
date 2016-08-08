Up.Router = Backbone.Router.extend({    
    routes: {
        "logout": "logout",

        "desktops": "desktops",
        
        "settings": "settings",
        "downloads": "downloads",
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
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.desktops);
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('vm', Up.Views.DesktopsView);
        });        
        
        // ------- Settings sections ------- //
        
        that.on('route:settings', function (searchHash) {
            Up.Views.SettingsView.prototype = $.extend({}, Up.Views.SettingsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('settings', Up.Views.SettingsView);
        });       
        
        // ------- Downloads sections ------- //
        
        that.on('route:downloads', function (searchHash) {
            that.performRoute('downloads', Up.Views.DownloadsView);
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
            that.performRoute('vm', Up.Views.DesktopsView);
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
            Up.I.L.clearSpies();
        }
        
		// Abort pending requests
        if (Up.C.abortOldRequests) {
            Up.C.abortRequests();
            clearInterval(Up.CurrentView.executionAnimationInterval);
        }
        
        Up.CurrentView = new view(params);
    }
});