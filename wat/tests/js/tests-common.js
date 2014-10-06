// XML Output in jUnit style for jenkins integration
QUnit.jUnitReport = function(data) {
    console.log(data.xml);
};

module( "Backbone tests", {
    setup: function() {
        // prepare something for all following tests
    },
    teardown: function() {
        // clean up after each test
    }
});
    test("Models instantiation", function() {
        // Instantiate Local Contact Backbone Model Object
        WatTests.models = {
            acl: new Wat.Models.ACL(),
            admin: new Wat.Models.Admin(),
            di: new Wat.Models.DI(),
            host: new Wat.Models.Host(),
            osf: new Wat.Models.OSF(),
            role: new Wat.Models.Role(),
            tenant: new Wat.Models.Tenant(),
            user: new Wat.Models.User(),
            vm: new Wat.Models.VM()
        }

        // Number of Assertions we Expect
        expect( Object.keys(WatTests.models).length );

        // Default Attribute Value Assertions
        $.each(WatTests.models, function (modelName, model) {
            equal( model.actionPrefix, modelName, "Model " + modelName + " is initialized");
        });
    });  

    test("Collections instantiation", function() {
        // Instantiate Local Contact Backbone Collection Object
        WatTests.collections = {
            acl: new Wat.Collections.ACLs(),
            admin: new Wat.Collections.Admins(),
            di: new Wat.Collections.DIs(),
            host: new Wat.Collections.Hosts(),
            osf: new Wat.Collections.OSFs(),
            role: new Wat.Collections.Roles(),
            tenant: new Wat.Collections.Tenants(),
            user: new Wat.Collections.Users(),
            vm: new Wat.Collections.VMs()
        }

        // Number of Assertions we Expect
        expect( Object.keys(WatTests.collections).length );

        // Default Attribute Value Assertions
        $.each(WatTests.collections, function (collectionName, collection) {
            equal( collection.actionPrefix, collectionName, "Collection " + collectionName + "s is initialized");
        });
    });  

module( "Login tests", {
    setup: function() {
        // prepare something for all following tests
        Wat.C.logOut();
    },
    teardown: function() {
        // clean up after each test
        Wat.C.logOut();
    }
});
    test("Login with superadmin", function() {   
        this.clock.restore();

        // Number of Assertions we Expect     
        expect( 4 );
        
        Wat.Router.app_router.trigger('route:defaultRoute');        
        
        equal(Wat.CurrentView.qvdObj, "login", "Login screen is loaded before auth");

        Wat.C.tryLogin("superadmin", "superadmin");
        
        Wat.Router.app_router.trigger('route:defaultRoute');        

        equal(Wat.CurrentView.qvdObj, "home", "Home access granted after auth");
        
        equal($.cookie('qvdWatLoggedInUser'), "superadmin", "User stored in cookies");
        equal($.cookie('qvdWatLoggedInPassword'), "superadmin", "Password stored in cookies");
    });

module( "View tests", {
    setup: function() {
        // prepare something for all following tests
        this.server = sinon.fakeServer.create();
        
        // Fake Login
        Wat.C.logOut();
        Wat.C.logIn('superadmin', 'superadmin');
    },
    teardown: function() {
        // clean up after each test
        this.server.restore();
        Wat.C.logOut();
    }
});

    var standardViews = [
        'User',
        'VM',
        'OSF',
        'DI',
        'Host'
    ];

    $.each(standardViews, function (i, view) {
        test("Load " + view + " list view", function() {
            // Number of Assertions we Expect     
            expect( 1 );

            Wat.Router.app_router.trigger('route:list' + view);        

            equal(Wat.CurrentView.qvdObj, view.toLowerCase(), view + " view rendered");
            
            WatTests.listViews[view.toLowerCase()] = _.extend({}, Wat.CurrentView);
        });
    });