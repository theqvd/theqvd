function loginTest () {
    module( "Login tests", {
        setup: function() {
            Wat.C.logOut();
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test

        }
    });
    
        asyncTest("Login with " + login, function() {   
            this.clock.restore();
            
            // Number of Assertions we Expect     
            expect( 4 );
            
            // Sometimes router is not ready at this point. Wait for it
            var waitingRouter = setInterval(function(){ 
                if (Wat.Router.app_router != undefined) {
                    Wat.C.afterLogin = function () {
                        if (Wat.Router.app_router == undefined) {
                            return;
                        }
                        Wat.Router.app_router.trigger('route:defaultRoute');        

                        equal(Wat.CurrentView.qvdObj, "home", "Home access granted after auth");

                        equal($.cookie('qvdWatSid'), Wat.C.sid, "Session ID stored in cookies");
                        equal($.cookie('qvdWatLogin'), Wat.C.login, "User stored in cookies");

                        start();
                        loggedTests();
                    }

                    afterGetApiInfo = function (ret) {  
                        if (ret.retrievedData.status == STATUS_SUCCESS) {
                            Wat.C.multitenant = ret.retrievedData.multitenant;
                        }

                        Wat.C.tryLogin(login, password, tenant);
                    };
                        

                    Wat.Router.app_router.trigger('route:defaultRoute');    
            
                    equal(Wat.CurrentView.qvdObj, "login", "Login screen is loaded before auth");
                    
                    Wat.A.apiInfo(afterGetApiInfo, {});
                    clearInterval(waitingRouter);
                }
            }, 1000);
            
        });
}