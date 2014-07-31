"use strict";

var currentView = {};

(function (w, d, $) {
	$(d).ready(function() {
        var AppRouter = Backbone.Router.extend({
                routes: {
                    "vms": "listVM",
                    "vm/:id": "detailsVM",
                    "users": "listUser",
                    "user/:id": "detailsUser",
                    "*actions": "defaultRoute" // Backbone will try match the route above first
                }
        });
        
        // Instantiate the router
        var app_router = new AppRouter;

        
        
        // ------- List sections ------- //
        app_router.on('route:listVM', function (id) {
            // Note the variable in the route definition being passed in here
            showLoading();
            setMenuOpt('vms');
            if (!$.isEmptyObject(currentView )) {
                currentView.undelegateEvents();
            }
            currentView = new VMListView();
            translate();
        });        
        
        app_router.on('route:listUser', function (id) {
            showLoading();
            setMenuOpt('users');
            if (!$.isEmptyObject(currentView )) {
                currentView.undelegateEvents();
            }
            
            currentView = new UserListView();
            translate();
        });
        
        
        
        // ------- Details sections ------- //
        app_router.on('route:detailsUser', function (id) {
            showLoading();
            setMenuOpt('users');
            if (!$.isEmptyObject(currentView )) {
                currentView.undelegateEvents();
            }
            currentView = new UserDetailsView({"id": id});
            translate();
        });
        
        
        
        // ------- Default load ------- //
        app_router.on('route:defaultRoute', function (actions) {
            console.log( actions ); 
        });

        // Start Backbone history
        Backbone.history.start();
        
        $('.menu-option').click(function() {
            var id = $(this).attr('id');
            w.location = '#/' + id;
        });
        
        function setMenuOpt (opt) {
            $('.menu-option').removeClass('menu-option--selected');
            $('#' + opt).addClass('menu-option--selected');
        }
        
	});
})(window, document, jQuery)