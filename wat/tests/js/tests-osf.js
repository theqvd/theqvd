module( "OS Flavour fake tests", {
    setup: function() {
        // prepare something for all following tests
        this.server = sinon.fakeServer.create();
    },
    teardown: function() {
        // clean up after each test
        this.server.restore();
    }
});
    
    test("OSF details processing", function() {
        var callback = sinon.spy();
        
        var fakeValues = WatTests.fakeValues.osf;
        
        // Number of Assertions we Expect
        expect( Object.keys(fakeValues).length + 2 );
        
        var fakeResponse = {
            "failures": {},
            "status": 0,
            "result": {
                "rows" : [
                    fakeValues
                ]
            },
            "message": "Successful completion."
        };

        this.server.respondWith(
            "POST", 
            Wat.C.apiUrl + '?sid=' + Wat.C.sid  + '&action=osf_get_details&filters={"id":' + fakeValues.id + '}',
            [
                200, 
                { "Content-Type": "application/json" },
                JSON.stringify(fakeResponse)
            ]
       );
        
        Wat.Router.app_router.trigger('route:detailsOSF', [fakeValues.id]);        
        
        // Bind to the change event on the model
        Wat.CurrentView.model.bind('change', callback);
                
        this.server.respond();
        
        ok(callback.called, "Server call");
        
        $.each(fakeValues, function (fieldName, fieldValue) {
            if (typeof fieldValue == 'object') {
                deepEqual(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "OSF fetching should recover '" + fieldName + "' properly (Random generated: " + JSON.stringify(fieldValue) + ")");
            }
            else {
                equal(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "OSF fetching should recover '" + fieldName + "' properly (Random generated: " + fieldValue + ")");
            }
        });

        deepEqual(callback.getCall(0).args[0], Wat.CurrentView.model, "Spied result and Backbone model should be equal");
    });


module( "OS Flavours Real tests", {
    setup: function() {
        // prepare something for all following tests
        
        // Fake Login
    },
    teardown: function() {
        // clean up after each test
    }
});

    QUnit.asyncTest("OS Flavours CRUD", function() {
        // Number of Assertions we Expect
        var assertions = 0;
        assertions += Object.keys(WatTests.fakeValues.osf).length * 2; // Create & Update verifications. (Password will not be verified because is not returned)
        assertions +=3; // Create, Update and Delete verifications
        
        expect(assertions);
        
        Wat.Router.app_router.trigger('route:listOSF');
        
        Wat.CurrentView.model = new Wat.Models.OSF();
        
        //////////////////////////////////////////////////////////////////
        // Create OSF
        //////////////////////////////////////////////////////////////////
        Wat.CurrentView.createModel(WatTests.values.osf, function (e) { 
            if(e.retrievedData.status == 0) {
                WatTests.values.osf.id = e.retrievedData.result.rows[0].id;
            }
            equal(e.retrievedData.status, 0, "OSF created succesfully (" + JSON.stringify(WatTests.values.osf) + ")");
            
            //////////////////////////////////////////////////////////////////
            // After create, get list of osfs matching by the created name
            //////////////////////////////////////////////////////////////////
            WatTests.models.osf = new Wat.Models.OSF({
                id: WatTests.values.osf.id
            });            
            
            
            WatTests.models.osf.fetch({      
                complete: function () {
                    $.each (WatTests.fakeValues.osf, function (fieldName) {
                        var valRetrieved = WatTests.models.osf.attributes[fieldName];

                        if (fieldName == 'properties' && WatTests.values.osf['__properties__'] != undefined) {
                            deepEqual(valRetrieved, WatTests.values.osf['__properties__'], "OSF field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                        }
                        else if (WatTests.values.osf[fieldName] != undefined) {
                            equal(valRetrieved, WatTests.values.osf[fieldName], "OSF field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                        }
                        else {
                            notEqual(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                        }
                    });
                    
                    // Perform changes in testing osf values
                    performUpdation(WatTests.values.osf, WatTests.updateValues.osf);
                    
                    //////////////////////////////////////////////////////////////////
                    // After get list of osfs, update it
                    //////////////////////////////////////////////////////////////////
                    Wat.CurrentView.updateModel(WatTests.updateValues.osf, {'id': WatTests.values.osf.id}, function (e) { 
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
                                        deepEqual(valRetrieved, WatTests.values.osf['__properties__'], "OSF field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                    }
                                    else if (WatTests.values.osf[fieldName] != undefined) {
                                        equal(valRetrieved, WatTests.values.osf[fieldName], "OSF field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                    }
                                    else {
                                        notEqual(WatTests.models.osf.attributes[fieldName], undefined, "OSF field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                    }
                                });


                                //////////////////////////////////////////////////////////////////
                                // After match the updated osf, delete it
                                //////////////////////////////////////////////////////////////////
                                Wat.CurrentView.deleteModel({'id': WatTests.values.osf.id}, function (e) { 
                                    equal(e.retrievedData.status, 0, "OSF deleted succesfully (ID: " + JSON.stringify(WatTests.values.osf.id) + ")");
                                    
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