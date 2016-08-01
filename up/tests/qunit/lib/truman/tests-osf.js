function osfTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests

            // Truman will not receive tenant info
            delete WatTests.fakeValues.osf.tenant_name;
            delete WatTests.fakeValues.osf.tenant_id;
            
            // Name will not be updated to not ruin the tests environment 
            delete WatTests.updateValues.osf.name;
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("OSF CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.osf).length * 2; // Create & Update verifications. (Password will not be verified because is not returned)
            assertions += 3; // Create, Read and Update verifications

            expect(assertions);

            Up.Router.upRouter.trigger('route:listOSF');

            Up.CurrentView.model = new Up.Models.OSF();

            //////////////////////////////////////////////////////////////////
            // Create OSF
            //////////////////////////////////////////////////////////////////
            Up.CurrentView.createModel(WatTests.values.osf, function (e) { 
                equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "OSF cannot be created due ACLs restriction (" + JSON.stringify(WatTests.values.osf) + ")");

                if(e.retrievedData.status == STATUS_FORBIDDEN_ACTION) {
                    // As the creation is forbidden, we store existing osf ID
                    WatTests.values.osf.id = tenantOSFId;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // Try to get list of osfs matching by the existing ID
                //////////////////////////////////////////////////////////////////
                WatTests.models.osf = new Up.Models.OSF({
                    id: WatTests.values.osf.id
                });            
                                
                WatTests.models.osf.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.osf, function (fieldName) {
                            var valRetrieved = WatTests.models.osf.attributes[fieldName];

                            // Truman cannot see properties of any qvd Object
                            if (fieldName == 'properties') {
                                equal(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' cannot be retrieved due ACLs restriction (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });
                        
                        //////////////////////////////////////////////////////////////////
                        // After get list of osfs, update it
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.osf, {'id': WatTests.values.osf.id}, function (e) { 
                            equal(e.retrievedData.status, STATUS_FORBIDDEN_ARGUMENT, "OSF cannot be updated due ACLs restriction (" + JSON.stringify(WatTests.updateValues.osf) + ")");
                        }, Up.CurrentView.model);
                        
                        
                        // Truman will not be able to update properties 
                        delete WatTests.updateValues.osf.__properties_changes__;
                        
                        // Perform changes in testing osf values
                        performUpdation(WatTests.values.osf, WatTests.updateValues.osf);

                        //////////////////////////////////////////////////////////////////
                        // After get list of osfs, update it
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.osf, {'id': WatTests.values.osf.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "OSF updated succesfully (" + JSON.stringify(WatTests.updateValues.osf) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of osfs matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.osf.fetch({   
                                complete: function (e) {
                                    WatTests.values.osf.id = WatTests.models.osf.attributes['id'];
                                    $.each (WatTests.fakeValues.osf, function (fieldName) {
                                        var valRetrieved = WatTests.models.osf.attributes[fieldName];

                                        if (fieldName == 'properties' && WatTests.values.osf['__properties__'] != undefined) {
                                            equal(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' cannot be retrieved due ACLs restriction (" + valRetrieved + ")");
                                        }
                                        else if (WatTests.values.osf[fieldName] != undefined && fieldName != 'name') {
                                            equal(valRetrieved, WatTests.values.osf[fieldName], "OSF field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notEqual(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });
                                    
                                    start();
                                }
                            });
                        }, Up.CurrentView.model);
                    }
                });
            });
        });
}