function hostTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Host CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions = 3; // Create, Read and Update verifications

            expect(assertions);

            Wat.Router.app_router.trigger('route:listHost');

            Wat.CurrentView.model = new Wat.Models.Host();

            //////////////////////////////////////////////////////////////////
            // Create Host
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.host, function (e) { 
                equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "Host cannot be created due ACLs restriction (" + JSON.stringify(WatTests.values.host) + ")");

                if(e.retrievedData.status == STATUS_FORBIDDEN_ACTION) {
                    // As the creation is forbidden, we store existing host ID
                    WatTests.values.host.id = tenantHostId;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // Try to get list of hosts matching by the existing ID
                //////////////////////////////////////////////////////////////////
                WatTests.models.host = new Wat.Models.Host({
                    id: WatTests.values.host.id
                });            
                                
                WatTests.models.host.fetch({      
                    complete: function (e) {
                        var status = JSON.parse(e.responseText).status;
                        equal(status, STATUS_FORBIDDEN_ACTION, "Host cannot be retrieved due ACLs restriction");

                        // Perform changes in testing host values
                        performUpdation(WatTests.values.host, WatTests.updateValues.host);

                        //////////////////////////////////////////////////////////////////
                        // Try to update host
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.host, {'id': WatTests.values.host.id}, function (e) { 
                            equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "Host cannot be updated due ACLs restriction (" + JSON.stringify(WatTests.updateValues.host) + ")");

                            start();
                        }, WatTests.models.host);
                    }
                });
            });
        });
}