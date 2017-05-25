Up.Router = Backbone.Router.extend({    
    routes: {
        "logout": "logout",

        "desktops": "desktops",
        "desktops/:id/connect/:token": "connectDesktop",
        
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
        that.on('route:desktops', function () {
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.desktops);
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('desktops', Up.Views.DesktopsView);
        });
        
        that.on('route:connectDesktop', function (id, token) {
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.desktops);
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('', Up.Views.DesktopConnectView, {id: id, token: token});
        });
        
        // ------- Settings sections ------- //
        
        that.on('route:settings', function () {
            Up.Views.SettingsView.prototype = $.extend({}, Up.Views.SettingsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('settings', Up.Views.SettingsView);
        });       
        
        // ------- Downloads sections ------- //
        
        that.on('route:downloads', function () {
            that.performRoute('downloads', Up.Views.DownloadsView);
        });       
        
        // ------- Info sections ------- //
        
        that.on('route:info', function () {
            that.performRoute('info', Up.Views.InfoView);
        });        

        // ------- Help sections ------- //
        
        that.on('route:help', function () {
            that.performRoute('help', Up.Views.HelpView);
        });        
        
        
        that.on('route:documentation', function () {
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
        that.on('route:logout', function () {
            Up.A.apiLogOut(function (that) {
                Up.L.logOut();
                Up.C.configureVisibility();
                Up.I.renderMain();

                that.performRoute('', Up.Views.LoginView);
            }, that);
        });          
        that.on('route:profile', function () {
            that.performRoute('profile', Up.Views.ProfileView);
        });

        // ------- Default load ------- //
        that.on('route:defaultRoute', function () {
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.desktops);
            Up.Views.DesktopsView.prototype = $.extend({}, Up.Views.DesktopsView.prototype, Up.CRUD.workspaces);
            
            that.performRoute('desktops', Up.Views.DesktopsView);
        });

        // Start Backbone history
        Backbone.history.start();   

        Up.C.routerHistoryStarted = true;
    },
    
    performRoute: function (menuOpt, view, params) {
        // Hide filter notes when route anywhere            
        $('.js-filter-notes').hide();
        
        params = params || {};

        Up.I.showLoading();
        
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
        
        if (Up.I.isMobile()) {
            var currentNav = Backbone.history.getFragment() || 'desktops';
            params['currentNav'] = currentNav;
        }
        
        Up.CurrentView = new view(params);
    }
});