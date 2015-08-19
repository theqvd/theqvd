"use strict";

(function (win, doc, $) {
    // Extend jQuery with pseudo selector :blank
    (function($) {
        $.extend($.expr[":"], {
            // http://docs.jquery.com/Plugins/Validation/blank
            blank: function(a) {
                return !$.trim(a.value);
            },
        });
    })(jQuery);
    
	$(doc).ready(function() {
        // Init API address variables
        Wat.C.initApiAddress();
        
        // Setup jQuery ajax to store all requests in a requests queue
        $.ajaxSetup({
            beforeSend: function(jqXHR) {
                Wat.C.requests.push(jqXHR);
            },
            complete: function(jqXHR) {
                var index = $.inArray(jqXHR, Wat.C.requests);
                if (index > -1) {
                    Wat.C.requests.splice(index, 1);
                }
            }
        });
        
        Wat.C.afterLogin = function () {
            // Load translation file
            Wat.T.initTranslate();

            // Interface onfiguration
            Wat.I.renderMain();

            //Wat.I.bindCornerMenuEvents();
            Wat.I.tooltipConfiguration();

            // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
            Wat.B.bindCommonEvents();

            if (Wat.C.isLogged()) {
                Wat.I.setCustomizationFields();
            }
            
            if (!Wat.C.routerHistoryStarted) {
                // Instantiate the router
                Wat.Router.app_router = new Wat.Router;

                // ------- List sections ------- //
                Wat.Router.app_router.on('route:listVM', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    Wat.Router.app_router.performRoute('vms', Wat.Views.VMListView, params);
                });        

                Wat.Router.app_router.on('route:listUser', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    
                    Wat.Router.app_router.performRoute('users', Wat.Views.UserListView, params);
                });       

                Wat.Router.app_router.on('route:listHost', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }

                    Wat.Router.app_router.performRoute('hosts', Wat.Views.HostListView, params);
                });      

                Wat.Router.app_router.on('route:listOSF', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }

                    Wat.Router.app_router.performRoute('osfs', Wat.Views.OSFListView, params);
                });    

                Wat.Router.app_router.on('route:listDI', function (searchHash) {
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }

                    Wat.Router.app_router.performRoute('dis', Wat.Views.DIListView, params);
                });



                // ------- Details sections ------- //
                Wat.Router.app_router.on('route:detailsUser', function (id) {
                    Wat.Router.app_router.performRoute('users', Wat.Views.UserDetailsView, {"id": id});
                });

                Wat.Router.app_router.on('route:detailsVM', function (id) {
                    Wat.Router.app_router.performRoute('vms', Wat.Views.VMDetailsView, {"id": id});
                });

                Wat.Router.app_router.on('route:detailsHost', function (id) {
                    Wat.Router.app_router.performRoute('hosts', Wat.Views.HostDetailsView, {"id": id});
                });

                Wat.Router.app_router.on('route:detailsOSF', function (id) {
                    Wat.Router.app_router.performRoute('osfs', Wat.Views.OSFDetailsView, {"id": id});
                });

                Wat.Router.app_router.on('route:detailsDI', function (id) {
                    Wat.Router.app_router.performRoute('dis', Wat.Views.DIDetailsView, {"id": id});
                });



                // ------- Configuration sections ------- //
                Wat.Router.app_router.on('route:viewCustomize', function () {
                    Wat.Router.app_router.performRoute('views', Wat.Views.SetupCustomizeView);
                });   
                
                Wat.Router.app_router.on('route:setupConfig', function (token) {
                    var params = {};
                    if (token) {
                        params.currentTokensPrefix = token;
                    }
                    Wat.Router.app_router.performRoute('config', Wat.Views.ConfigQvdView, params);
                });  
                
                Wat.Router.app_router.on('route:watConfig', function () {
                    Wat.Router.app_router.performRoute('watconfig', Wat.Views.ConfigWatView);
                });  
                
                
                Wat.Router.app_router.on('route:listTenant', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    
                    Wat.Router.app_router.performRoute('tenants', Wat.Views.TenantListView, params);
                });  
                
                Wat.Router.app_router.on('route:detailsTenant', function (id) {
                    Wat.Router.app_router.performRoute('tenants', Wat.Views.TenantDetailsView, {"id": id});
                });
                
                Wat.Router.app_router.on('route:property', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    
                    Wat.Router.app_router.performRoute('properties', Wat.Views.PropertyView, params);
                });
                
                Wat.Router.app_router.on('route:listAdmin', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    
                    Wat.Router.app_router.performRoute('administrators', Wat.Views.AdminListView, params);
                });
                
                Wat.Router.app_router.on('route:detailsAdmin', function (id) {
                    Wat.Router.app_router.performRoute('administrators', Wat.Views.AdminDetailsView, {"id": id});
                });   
                
                
                Wat.Router.app_router.on('route:listRole', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                
                    Wat.Router.app_router.performRoute('roles', Wat.Views.RoleListView, params);
                });  
                
                Wat.Router.app_router.on('route:detailsRole', function (id) {
                    Wat.Router.app_router.performRoute('roles', Wat.Views.RoleDetailsView, {"id": id});
                });    
                
                
                Wat.Router.app_router.on('route:listLog', function (searchHash) {   
                    var params = {};
                    if (searchHash !== null) {
                        params = Wat.U.base64.decodeObj(searchHash);
                    }
                    
                    Wat.Router.app_router.performRoute('logs', Wat.Views.LogListView, params);
                });    
                
                Wat.Router.app_router.on('route:detailsLog', function (id) {
                    Wat.Router.app_router.performRoute('logs', Wat.Views.LogDetailsView, {"id": id});
                });    


                // ------- Help sections ------- //
                Wat.Router.app_router.on('route:about', function (actions) {
                    Wat.Router.app_router.performRoute('about', Wat.Views.AboutView);
                });
                Wat.Router.app_router.on('route:documentation', function (actions) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView);
                });
                Wat.Router.app_router.on('route:documentationGuide', function (guide, section) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView, {
                        "guide": guide,
                        "section": section
                    });
                });
                Wat.Router.app_router.on('route:documentationSearch', function (searchKey) {
                    Wat.Router.app_router.performRoute('documentation', Wat.Views.DocView, {
                        "searchKey": searchKey
                    });
                });



                 // ------- Current administrator ------- //
                Wat.Router.app_router.on('route:logout', function (actions) {
                    Wat.C.logOut();

                    Wat.C.configureVisibility();
                    Wat.I.renderMain();

                    Wat.Router.app_router.performRoute();
                });          
                Wat.Router.app_router.on('route:profile', function (actions) {
                    Wat.Router.app_router.performRoute('profile', Wat.Views.ProfileView);
                });             
                Wat.Router.app_router.on('route:myviews', function (actions) {
                    Wat.Router.app_router.performRoute('myviews', Wat.Views.MyViewsView);
                });       


                // ------- Default load ------- //
                Wat.Router.app_router.on('route:defaultRoute', function (actions) {
                    Wat.Router.app_router.performRoute('', Wat.Views.HomeView);
                });

                // Start Backbone history
                Backbone.history.start();   
                
                Wat.C.routerHistoryStarted = true;
            }
        
        };
                
        var continueStart = function () {
            // Remember login from cookies
            Wat.C.rememberLogin();
        };
        
        var templates = {
            main: {
                name: 'main'
            },
            menu: {
                name: 'menu'
            },
            editorCommon: {
                name: 'editor/common'
            },
            relatedDoc: {
                name: 'doc/related-links'
            },
            viewCustomize: {
                name: 'view/customize'
            },
            viewFormCustomize: {
                name: 'view/customize-form'
            }
        }

        Wat.A.getTemplates(templates, continueStart);
	});
})(window, document, jQuery)
