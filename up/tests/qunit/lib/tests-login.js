function loginTest (login, password, tenant, callback) {
    module( "Login tests", {
        setup: function() {
            Wat.L.logOut();
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test

        }
    });
    
        asyncTest("Login with " + login, function() {   
            this.clock.restore();
            
            // Number of Assertions we Expect     
            expect( 3 );
            
            // Sometimes router is not ready at this point. Wait for it
            var waitingRouter = setInterval(function(){ 
                if (Wat.Router.watRouter != undefined) {
                    Wat.L.afterLogin = function () {
                        if (Wat.Router.watRouter == undefined) {
                            callback();
                            return;
                        }
                        Wat.Router.watRouter.trigger('route:defaultRoute');        

                        equal(Wat.CurrentView.qvdObj, "home", "Home access granted after auth");

                        equal($.cookie('sid'), Wat.C.sid, "Session ID stored in cookies");
                        
                        start();
                        callback();
                    }

                    afterGetApiInfo = function (ret) {  
                        if (ret.retrievedData.status == STATUS_SUCCESS) {
                            Wat.C.multitenant = ret.retrievedData.multitenant || true;
                        }

                        Wat.L.tryLogin(login, password, tenant);
                    };
                        

                    Wat.Router.watRouter.trigger('route:defaultRoute');    
            
                    equal(Wat.CurrentView.qvdObj, "login", "Login screen is loaded before auth");
                    
                    Wat.A.apiInfo(afterGetApiInfo, {});
                    clearInterval(waitingRouter);
                }
            }, 300);
            
        });
}