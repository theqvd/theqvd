function adminTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
            WatTests.values.administrator.tenant_id = 0;
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Admin CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.administrator).length * 2; // Create & Update verifications.
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            Up.Router.upRouter.trigger('route:listAdmin');

            Up.CurrentView.model = new Up.Models.Admin();
            delete WatTests.values.administrator.id;

            //////////////////////////////////////////////////////////////////
            // Create Admin
            //////////////////////////////////////////////////////////////////
            Up.CurrentView.createModel(WatTests.values.administrator, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "Admin created succesfully (" + JSON.stringify(WatTests.values.administrator) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.administrator.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // After create, get list of users matching by the created name
                //////////////////////////////////////////////////////////////////
                WatTests.models.admin = new Up.Models.Admin({
                    id: WatTests.values.administrator.id
                });            

                WatTests.models.admin.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.administrator, function (fieldName) {
                            var valRetrieved = WatTests.models.admin.attributes[fieldName];

                            if (WatTests.values.administrator[fieldName] != undefined) {
                                equal(valRetrieved, WatTests.values.administrator[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.admin.attributes[fieldName], undefined, "Admin field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Perform changes in testing admin values
                        performUpdation(WatTests.values.administrator, WatTests.updateValues.administrator);
                        
                        // When set a role, only use the Id, but when retrieve the admin details, name is returned too
                        // Set the name  manually to check this returned value
                        WatTests.values.administrator.roles = roleShort;
                        
                        //////////////////////////////////////////////////////////////////
                        // After get list of admins, update it
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.administrator, {'id': WatTests.values.administrator.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Admin updated succesfully (" + JSON.stringify(WatTests.updateValues.administrator) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of admins matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.admin.fetch({   
                                complete: function (e) {
                                    WatTests.values.administrator.id = WatTests.models.admin.attributes['id'];
                                    $.each (WatTests.fakeValues.administrator, function (fieldName) {
                                        var valRetrieved = WatTests.models.admin.attributes[fieldName];

                                        if (WatTests.values.administrator[fieldName] != undefined) {
                                            if ((typeof valRetrieved) == 'object') {
                                                deepEqual(valRetrieved, WatTests.values.administrator[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                            }
                                            else {
                                                equal(valRetrieved, WatTests.values.administrator[fieldName], "Admin field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                            }
                                        }
                                        else {
                                            notEqual(WatTests.models.admin.attributes[fieldName], undefined, "Admin field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });


                                    //////////////////////////////////////////////////////////////////
                                    // After match the updated user, delete it
                                    //////////////////////////////////////////////////////////////////
                                    Up.CurrentView.deleteModel({'id': WatTests.values.administrator.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Admin deleted succesfully (ID: " + JSON.stringify(WatTests.values.administrator.id) + ")");

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