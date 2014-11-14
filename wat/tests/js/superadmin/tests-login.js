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
    
        test("Login with " + login, function() {   
            this.clock.restore();

            // Number of Assertions we Expect     
            expect( 4 );

            Wat.Router.app_router.trigger('route:defaultRoute');        

            equal(Wat.CurrentView.qvdObj, "login", "Login screen is loaded before auth");

            Wat.C.tryLogin(login, password);

            Wat.Router.app_router.trigger('route:defaultRoute');        

            equal(Wat.CurrentView.qvdObj, "home", "Home access granted after auth");

            equal($.cookie('qvdWatSid'), Wat.C.sid, "Session ID stored in cookies");
            equal($.cookie('qvdWatLogin'), Wat.C.login, "User stored in cookies");
        });
}