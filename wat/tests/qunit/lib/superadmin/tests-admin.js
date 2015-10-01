function adminTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
            WatTests.values.admin.tenant_id = 0;
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Admin CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.admin).length * 2; // Create & Update verifications.
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            Wat.Router.watRouter.trigger('route:listAdmin');

            Wat.CurrentView.model = new Wat.Models.Admin();
            delete WatTests.values.admin.id;

            //////////////////////////////////////////////////////////////////
            // Create Admin
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.admin, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "Admin created succesfully (" + JSON.stringify(WatTests.values.admin) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.admin.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // After create, get list of users matching by the created name
                //////////////////////////////////////////////////////////////////
                WatTests.models.admin = new Wat.Models.Admin({
                    id: WatTests.values.admin.id
                });            

                WatTests.models.admin.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.admin, function (fieldName) {
                            var valRetrieved = WatTests.models.admin.attributes[fieldName];

                            if (WatTests.values.admin[fieldName] != undefined) {
                                equal(valRetrieved, WatTests.values.admin[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.admin.attributes[fieldName], undefined, "Admin field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Perform changes in testing admin values
                        performUpdation(WatTests.values.admin, WatTests.updateValues.admin);
                        
                        // When set a role, only use the Id, but when retrieve the admin details, name is returned too
                        // Set the name  manually to check this returned value
                        WatTests.values.admin.roles = roleShort;
                        
                        //////////////////////////////////////////////////////////////////
                        // After get list of admins, update it
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.admin, {'id': WatTests.values.admin.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Admin updated succesfully (" + JSON.stringify(WatTests.updateValues.admin) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of admins matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.admin.fetch({   
                                complete: function (e) {
                                    WatTests.values.admin.id = WatTests.models.admin.attributes['id'];
                                    $.each (WatTests.fakeValues.admin, function (fieldName) {
                                        var valRetrieved = WatTests.models.admin.attributes[fieldName];

                                        if (WatTests.values.admin[fieldName] != undefined) {
                                            if ((typeof valRetrieved) == 'object') {
                                                deepEqual(valRetrieved, WatTests.values.admin[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                            }
                                            else {
                                                equal(valRetrieved, WatTests.values.admin[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                            }
                                        }
                                        else {
                                            notEqual(WatTests.models.admin.attributes[fieldName], undefined, "Admin field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });


                                    //////////////////////////////////////////////////////////////////
                                    // After match the updated user, delete it
                                    //////////////////////////////////////////////////////////////////
                                    Wat.CurrentView.deleteModel({'id': WatTests.values.admin.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Admin deleted succesfully (ID: " + JSON.stringify(WatTests.values.admin.id) + ")");

                                        // Unblock task runner
                                        start();
                                    }, Wat.CurrentView.model);
                                }
                            });
                        }, Wat.CurrentView.model);
                    }
                });
            });
        });
}