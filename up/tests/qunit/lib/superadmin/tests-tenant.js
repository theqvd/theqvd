function tenantTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Tenant CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.tenant).length * 2; // Create & Update verifications.
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            Up.Router.upRouter.trigger('route:listTenant');

            Up.CurrentView.model = new Up.Models.Tenant();

            //////////////////////////////////////////////////////////////////
            // Create Tenant
            //////////////////////////////////////////////////////////////////
            Up.CurrentView.createModel(WatTests.values.tenant, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "Tenant created succesfully (" + JSON.stringify(WatTests.values.tenant) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.tenant.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // After create, get list of users matching by the created name
                //////////////////////////////////////////////////////////////////
                WatTests.models.tenant = new Up.Models.Tenant({
                    id: WatTests.values.tenant.id
                });            

                WatTests.models.tenant.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.tenant, function (fieldName) {
                            var valRetrieved = WatTests.models.tenant.attributes[fieldName];

                            if (WatTests.values.tenant[fieldName] != undefined) {
                                equal(valRetrieved, WatTests.values.tenant[fieldName], "Tenant field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.tenant.attributes[fieldName], undefined, "Tenant field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Perform changes in testing tenant values
                        performUpdation(WatTests.values.tenant, WatTests.updateValues.tenant);

                        //////////////////////////////////////////////////////////////////
                        // After get list of tenants, update it
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.tenant, {'id': WatTests.values.tenant.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Tenant updated succesfully (" + JSON.stringify(WatTests.updateValues.tenant) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of tenants matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.tenant.fetch({   
                                complete: function (e) {
                                    WatTests.values.tenant.id = WatTests.models.tenant.attributes['id'];
                                    $.each (WatTests.fakeValues.tenant, function (fieldName) {
                                        var valRetrieved = WatTests.models.tenant.attributes[fieldName];

                                        if (WatTests.values.tenant[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.tenant[fieldName], "Tenant field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notEqual(WatTests.models.tenant.attributes[fieldName], undefined, "Tenant field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });


                                    //////////////////////////////////////////////////////////////////
                                    // After match the updated user, delete it
                                    //////////////////////////////////////////////////////////////////
                                    Up.CurrentView.deleteModel({'id': WatTests.values.tenant.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Tenant deleted succesfully (ID: " + JSON.stringify(WatTests.values.tenant.id) + ")");

                                        // Unblock task runner
                                        start();
                                    }, Up.CurrentView.model);
                                }
                            });
                        }, Up.CurrentView.model);
                    }
                });
            });
        });
}