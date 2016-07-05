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
                administrator: new Up.Models.Admin(),
                di: new Up.Models.DI(),
                host: new Up.Models.Host(),
                osf: new Up.Models.OSF(),
                log: new Up.Models.Log(),
                role: new Up.Models.Role(),
                tenant: new Up.Models.Tenant(),
                user: new Up.Models.User(),
                vm: new Up.Models.VM()
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
                administrator: new Up.Collections.Admins(),
                di: new Up.Collections.DIs(),
                host: new Up.Collections.Hosts(),
                osf: new Up.Collections.OSFs(),
                log: new Up.Collections.Logs(),
                role: new Up.Collections.Roles(),
                tenant: new Up.Collections.Tenants(),
                user: new Up.Collections.Users(),
                vm: new Up.Collections.VMs()
            }

            // Number of Assertions we Expect
            expect( Object.keys(WatTests.collections).length );

            // Default Attribute Value Assertions
            $.each(WatTests.collections, function (collectionName, collection) {
                equal( collection.actionPrefix, collectionName, "Collection " + collectionName + "s is initialized");
            });
        });
}