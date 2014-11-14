function backboneTest () {
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
}