function loginTest (login, password, tenant, callback) {
    module( "Login tests", {
        setup: function() {
            Up.L.logOut();
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
                if (Up.Router.watRouter != undefined) {
                    Up.L.afterLogin = function () {
                        if (Up.Router.watRouter == undefined) {
                            callback();
                            return;
                        }
                        Up.Router.watRouter.trigger('route:defaultRoute');        

                        equal(Up.CurrentView.qvdObj, "home", "Home access granted after auth");

                        equal($.cookie('sid'), Up.C.sid, "Session ID stored in cookies");
                        
                        start();
                        callback();
                    }

                    afterGetApiInfo = function (ret) {  
                        if (ret.retrievedData.status == STATUS_SUCCESS) {
                            Up.C.multitenant = ret.retrievedData.multitenant || true;
                        }

                        Up.L.tryLogin(login, password, tenant);
                    };
                        

                    Up.Router.watRouter.trigger('route:defaultRoute');    
            
                    equal(Up.CurrentView.qvdObj, "login", "Login screen is loaded before auth");
                    
                    Up.A.apiInfo(afterGetApiInfo, {});
                    clearInterval(waitingRouter);
                }
            }, 300);
            
        });
}