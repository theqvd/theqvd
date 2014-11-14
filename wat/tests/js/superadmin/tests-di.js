function diTestFake () {
    module( "Fake tests", {
        setup: function() {
            // prepare something for all following tests
            this.server = sinon.fakeServer.create();
        },
        teardown: function() {
            // clean up after each test
            this.server.restore();
        }
    });

        test("DI details processing", function() {
            var callback = sinon.spy();

            var fakeValues = WatTests.fakeValues.di;

            var fakeResponse = {
                "failures": {},
                "status": 0,
                "result": {
                    "rows" : [
                        jQuery.extend({}, fakeValues)
                    ]
                },
                "message": "Successful completion."
            };

            // Get custom tags from all retrieved tags. These are the not fixed (version is a fixed tag) and those that not are 'default' or 'head'.
            var fakeTags = [];
            $.each(fakeValues.tags, function (i, tagValues) {
                if (tagValues.tag != 'default' && tagValues.tag != 'head' && tagValues.fixed == 0) {
                    fakeTags.push(tagValues.tag);
                }
            });

            // Some elements of the response will be processed, so the model attributes will not be exactly the same
            fakeValues.head = 1;
            fakeValues.default = 1;
            fakeValues.tags = fakeTags.join(',');

            // Number of Assertions we Expect
            expect( Object.keys(fakeValues).length + 2 );

            this.server.respondWith(
                "POST", 
                Wat.C.apiUrl + '?sid=' + Wat.C.sid  + '&action=di_get_details&filters={"id":' + fakeValues.id + '}',
                [
                    200, 
                    { "Content-Type": "application/json" },
                    JSON.stringify(fakeResponse)
                ]
           );

            Wat.Router.app_router.trigger('route:detailsDI', [fakeValues.id]);        

            // Bind to the change event on the model
            Wat.CurrentView.model.bind('change', callback);

            this.server.respond();

            ok(callback.called, "Server call");

            $.each(fakeValues, function (fieldName, fieldValue) {
                if (typeof fieldValue == 'object') {
                    deepEqual(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "DI fetching should recover '" + fieldName + "' properly (Random generated: " + JSON.stringify(fieldValue) + ")");
                }
                else {
                    equal(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "DI fetching should recover '" + fieldName + "' properly (Random generated: " + fieldValue + ")");
                }
            });

            deepEqual(callback.getCall(0).args[0], Wat.CurrentView.model, "Spied result and Backbone model should be equal");
        });
}

function diTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Disk images CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.di).length * 2; // Create & Update verifications. (Password will not be verified because is not returned)
            assertions +=2; // Create and Delete dependences (OSF)
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            Wat.Router.app_router.trigger('route:listOSF');

            Wat.CurrentView.model = new Wat.Models.OSF();

            //////////////////////////////////////////////////////////////////
            // Create dependency OSF
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.osf, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "OSF created succesfully (" + JSON.stringify(WatTests.values.osf) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.osf.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                Wat.Router.app_router.trigger('route:listDI');

                Wat.CurrentView.model = new Wat.Models.DI();

                // Create DI associated to the created OSF
                WatTests.values.di.osf_id = WatTests.values.osf.id;

                //////////////////////////////////////////////////////////////////
                // Create DI
                //////////////////////////////////////////////////////////////////
                Wat.CurrentView.createModel(WatTests.values.di, function (e) { 
                    equal(e.retrievedData.status, STATUS_SUCCESS, "DI created succesfully (" + JSON.stringify(WatTests.values.di) + ")");

                    if(e.retrievedData.status == STATUS_SUCCESS) {
                        WatTests.values.di.id = e.retrievedData.rows[0].id;
                    }
                    else {
                        start();
                        return;
                    }

                    //////////////////////////////////////////////////////////////////
                    // After create, get list of dis matching by the created name
                    //////////////////////////////////////////////////////////////////
                    WatTests.models.di = new Wat.Models.DI({
                        id: WatTests.values.di.id
                    });            

                    WatTests.models.di.fetch({      
                        complete: function () {
                            $.each (WatTests.fakeValues.di, function (fieldName) {
                                var valRetrieved = WatTests.models.di.attributes[fieldName];

                                if (fieldName == 'properties' && WatTests.values.di['__properties__'] != undefined) {
                                    deepEqual(valRetrieved, WatTests.values.di['__properties__'], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                }
                                else if (WatTests.values.di[fieldName] != undefined) {
                                    
                                    if (fieldName == 'disk_image') {
                                        equal(valRetrieved, WatTests.values.di['id'] + '-' + WatTests.values.di[fieldName], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                    }
                                    else {
                                        equal(valRetrieved, WatTests.values.di[fieldName], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                    }
                                }
                                else {
                                    notEqual(WatTests.models.di.attributes[fieldName], undefined, "DI field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                }
                            });

                            // Perform changes in testing osf values
                            performUpdation(WatTests.values.di, WatTests.updateValues.di);

                            //////////////////////////////////////////////////////////////////
                            // After get list of DIs, update it
                            //////////////////////////////////////////////////////////////////
                            Wat.CurrentView.updateModel(WatTests.updateValues.di, {'id': WatTests.values.di.id}, function (e) { 
                                equal(e.retrievedData.status, 0, "DI updated succesfully (" + JSON.stringify(WatTests.updateValues.di) + ")");

                                //////////////////////////////////////////////////////////////////
                                // After update, get list of di matching by name
                                //////////////////////////////////////////////////////////////////
                                WatTests.models.di.fetch({   
                                    complete: function (e) {
                                        WatTests.values.di.id = WatTests.models.di.attributes['id'];
                                        $.each (WatTests.fakeValues.di, function (fieldName) {
                                            var valRetrieved = WatTests.models.di.attributes[fieldName];

                                            if (fieldName == 'properties' && WatTests.values.di['__properties__'] != undefined) {
                                                deepEqual(valRetrieved, WatTests.values.di['__properties__'], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                            }
                                            else if (WatTests.values.di[fieldName] != undefined) {
                                                if (fieldName == 'disk_image') {
                                                    equal(valRetrieved, WatTests.values.di['id'] + '-' + WatTests.values.di[fieldName], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                }
                                                else {
                                                    equal(valRetrieved, WatTests.values.di[fieldName], "DI field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                }
                                            }
                                            else {
                                                notEqual(WatTests.models.di.attributes[fieldName], undefined, "DI field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                            }
                                        });


                                        //////////////////////////////////////////////////////////////////
                                        // After match the updated di, delete it
                                        //////////////////////////////////////////////////////////////////
                                        Wat.CurrentView.deleteModel({'id': WatTests.values.di.id}, function (e) { 
                                            equal(e.retrievedData.status, 0, "DI deleted succesfully (ID: " + JSON.stringify(WatTests.values.di.id) + ")");

                                            //////////////////////////////////////////////////////////////////
                                            // After delete di, delete the dependency osf
                                            //////////////////////////////////////////////////////////////////

                                            Wat.Router.app_router.trigger('route:listOSF');

                                            Wat.CurrentView.model = new Wat.Models.OSF();

                                            Wat.CurrentView.deleteModel({'id': WatTests.values.di.osf_id}, function (e) { 
                                                equal(e.retrievedData.status, 0, "OSF deleted succesfully (ID: " + JSON.stringify(WatTests.values.osf.id) + ")");

                                                // Unblock task runner
                                                start();
                                            }, Wat.CurrentView.model);
                                        }, Wat.CurrentView.model);
                                    }
                                });
                            }, Wat.CurrentView.model);
                        }
                    });
                });
            });
        });
}