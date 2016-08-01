function roleTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Role CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.role).length * 3; // Create & Update verifications.
            assertions +=8; // Create, Update and Delete verifications

            expect(assertions);

            Up.Router.upRouter.trigger('route:listRole');

            Up.CurrentView.model = new Up.Models.Role();

            //////////////////////////////////////////////////////////////////
            // Create Role
            //////////////////////////////////////////////////////////////////
            Up.CurrentView.createModel(WatTests.values.role, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "Role created succesfully (" + JSON.stringify(WatTests.values.role) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.role.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // After create, get list of users matching by the created name
                //////////////////////////////////////////////////////////////////
                WatTests.models.role = new Up.Models.Role({
                    id: WatTests.values.role.id
                });            

                WatTests.models.role.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.role, function (fieldName) {
                            var valRetrieved = WatTests.models.role.attributes[fieldName];

                            if (fieldName == 'acls' && WatTests.values.role[fieldName] != undefined) {
                                deepEqual(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                            }
                            else if (WatTests.values.role[fieldName] != undefined) {
                                equal(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.role.attributes[fieldName], undefined, "Role field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Store acls update for the second update process
                        var aclsUpdate = WatTests.updateValues.role.__acls_changes__;
                        delete WatTests.updateValues.role.__acls_changes__;
                        
                        // Perform changes in testing role values
                        performUpdation(WatTests.values.role, WatTests.updateValues.role);
                        
                        // When inherit a role, only use the Id, but when retrieve the role details, name, fixed and internal attributes are returned too
                        // Set it manually to check these returned values
                        WatTests.values.role.roles = roleLong;

                        //////////////////////////////////////////////////////////////////
                        // After get list of roles, update it
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.role, {'id': WatTests.values.role.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Role updated succesfully (" + JSON.stringify(WatTests.updateValues.role) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of roles matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.role.fetch({   
                                complete: function (e) {
                                    WatTests.values.role.id = WatTests.models.role.attributes['id'];
                                    $.each (WatTests.fakeValues.role, function (fieldName) {
                                        var valRetrieved = WatTests.models.role.attributes[fieldName];
                                        
                                        if (fieldName == 'roles' && WatTests.values.role[fieldName] != undefined) {
                                            deepEqual(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                        }
                                        else if (WatTests.values.role[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notEqual(WatTests.models.role.attributes[fieldName], undefined, "Role field '" + fieldName + "' retrieved successfully (" + JSON.stringify(valRetrieved) + ")");
                                        }
                                    });

                                    delete WatTests.values.role.roles;
                                    delete WatTests.updateValues.role.__roles_changes__;
                                    WatTests.updateValues.role.__acls_changes__ = aclsUpdate;
                                    
                                    // Perform changes in testing role values
                                    performUpdation(WatTests.values.role, WatTests.updateValues.role);

                                    //////////////////////////////////////////////////////////////////
                                    // After get list of roles, update it
                                    //////////////////////////////////////////////////////////////////
                                    Up.CurrentView.updateModel(WatTests.updateValues.role, {'id': WatTests.values.role.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Role updated succesfully (" + JSON.stringify(WatTests.updateValues.role) + ")");

                                        //////////////////////////////////////////////////////////////////
                                        // After update, get role details matching by name
                                        //////////////////////////////////////////////////////////////////
                                        WatTests.models.role.fetch({   
                                            complete: function (e) {
                                                WatTests.values.role.id = WatTests.models.role.attributes['id'];
                                                $.each (WatTests.fakeValues.role, function (fieldName) {
                                                    var valRetrieved = WatTests.models.role.attributes[fieldName];
                                                    
                                                    if (fieldName == 'acls' && WatTests.values.role[fieldName] != undefined) {
                                                        deepEqual(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                    else if (WatTests.values.role[fieldName] != undefined) {
                                                        equal(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                    }
                                                    else {
                                                        notEqual(WatTests.models.role.attributes[fieldName], undefined, "Role field '" + fieldName + "' retrieved successfully (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                });

                                                //////////////////////////////////////////////////////////////////
                                                // After get role details, update it again
                                                //////////////////////////////////////////////////////////////////
                                                Up.CurrentView.updateModel(WatTests.updateValues.role2, {'id': WatTests.values.role.id}, function (e) { 
                                                    equal(e.retrievedData.status, 0, "Role updated succesfully (" + JSON.stringify(WatTests.updateValues.role) + ")");

                                                    //////////////////////////////////////////////////////////////////
                                        // After update, get list of roles matching by name
                                        //////////////////////////////////////////////////////////////////
                                        WatTests.models.role.fetch({   
                                            complete: function (e) {
                                                WatTests.values.role.id = WatTests.models.role.attributes['id'];
                                                $.each (WatTests.fakeValues.role, function (fieldName) {
                                                    var valRetrieved = WatTests.models.role.attributes[fieldName];
                                                    
                                                    if (fieldName == 'acls' && WatTests.values.role[fieldName] != undefined) {
                                                        deepEqual(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                    else if (WatTests.values.role[fieldName] != undefined) {
                                                        equal(valRetrieved, WatTests.values.role[fieldName], "Role field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                    }
                                                    else {
                                                        notEqual(WatTests.models.role.attributes[fieldName], undefined, "Role field '" + fieldName + "' retrieved successfully (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                });


                                                //////////////////////////////////////////////////////////////////
                                                            // After match the updated role, delete it
                                                //////////////////////////////////////////////////////////////////
                                                Up.CurrentView.deleteModel({'id': WatTests.values.role.id}, function (e) { 
                                                    equal(e.retrievedData.status, 0, "Role deleted succesfully (ID: " + JSON.stringify(WatTests.values.role.id) + ")");

                                                    // Unblock task runner
                                                    start();
                                                }, Up.CurrentView.model);
                                            }
                                        });
                                    }, Up.CurrentView.model);
                                                
                                            }
                                        });
                                    }, Up.CurrentView.model);
                                }
                            });
                        }, Up.CurrentView.model);
                    }
                });
            });
        });
}