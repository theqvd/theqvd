function diTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
            
            // Truman will not receive tenant info
            delete WatTests.fakeValues.di.tenant_name;
            delete WatTests.fakeValues.di.tenant_id;
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Disk images CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += 2; //  Read and Update verifications
            assertions += Object.keys(WatTests.fakeValues.di).length; // Read verifications

            expect(assertions);

            Wat.Router.watRouter.trigger('route:listDI');

            Wat.CurrentView.model = new Wat.Models.DI();

            //////////////////////////////////////////////////////////////////
            // Create DI
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.di, function (e) { 
                equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "DI cannot be created due ACLs restriction (" + JSON.stringify(WatTests.values.di) + ")");

                if(e.retrievedData.status == STATUS_FORBIDDEN_ACTION) {
                    // As the creation is forbidden, we store existing di ID
                    WatTests.values.di.id = tenantDIId;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // Try to get list of dis matching by the existing ID
                //////////////////////////////////////////////////////////////////
                WatTests.models.di = new Wat.Models.DI({
                    id: WatTests.values.di.id
                });            
                                
                WatTests.models.di.fetch({      
                    complete: function (e) {
                        //var status = JSON.parse(e.responseText).status;
                        //equal(status, STATUS_FORBIDDEN_ACTION, "Disk Image cannot be retrieved due ACLs restriction");
                        
                        $.each (WatTests.fakeValues.di, function (fieldName) {
                            var valRetrieved = WatTests.models.di.attributes[fieldName];
                            // Truman cannot see properties of any qvd Object
                            if (fieldName == 'properties') {
                                equal(WatTests.models.di.attributes[fieldName], undefined, "DI field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.di.attributes[fieldName], undefined, "DI field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Perform changes in testing di values
                        performUpdation(WatTests.values.di, WatTests.updateValues.di);

                        //////////////////////////////////////////////////////////////////
                        // Try to update di
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.di, {'id': WatTests.values.di.id}, function (e) { 
                            equal(e.retrievedData.status, STATUS_FORBIDDEN_ARGUMENT, "Disk Image cannot be updated due ACLs restriction (" + JSON.stringify(WatTests.updateValues.di) + ")");

                            start();
                        }, Wat.CurrentView.model);
                    }
                });
            });
        });
}