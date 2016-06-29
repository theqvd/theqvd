function hostTestFake () {
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

        test("Host details processing", function() {
            var callback = sinon.spy();

            var fakeValues = WatTests.fakeValues.host;

            // Number of Assertions we Expect
            expect( Object.keys(fakeValues).length + 2 );

            var fakeResponse = {
                "failures": {},
                "status": 0,
                "rows" : [
                    fakeValues
                ],
                "message": "Successful completion."
            };

            this.server.respondWith(
                "POST", 
                Wat.C.apiUrl + '?sid=' + Wat.C.sid  + '&action=host_get_details&filters={"id":' + fakeValues.id + '}',
                [
                    200, 
                    { "Content-Type": "application/json" },
                    JSON.stringify(fakeResponse)
                ]
           );

            Wat.Router.watRouter.trigger('route:detailsHost', [fakeValues.id]);        

            // Bind to the change event on the model
            Wat.CurrentView.model.bind('change', callback);

            this.server.respond();

            ok(callback.called, "Server call");

            $.each(fakeValues, function (fieldName, fieldValue) {
                if (typeof fieldValue == 'object') {
                    deepEqual(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Host fetching should recover '" + fieldName + "' properly (Random generated: " + JSON.stringify(fieldValue) + ")");
                }
                else {
                    equal(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Host fetching should recover '" + fieldName + "' properly (Random generated: " + fieldValue + ")");
                }
            });

            deepEqual(callback.getCall(0).args[0], Wat.CurrentView.model, "Spied result and Backbone model should be equal");
        });
}

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
            assertions += Object.keys(WatTests.fakeValues.host).length * 2; // Create & Update verifications.
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            Wat.Router.watRouter.trigger('route:listHost');

            Wat.CurrentView.model = new Wat.Models.Host();

            //////////////////////////////////////////////////////////////////
            // Create Host
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.host, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "Host created succesfully (" + JSON.stringify(WatTests.values.host) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.host.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // After create, get list of users matching by the created name
                //////////////////////////////////////////////////////////////////
                WatTests.models.host = new Wat.Models.Host({
                    id: WatTests.values.host.id
                });            

                WatTests.models.host.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.host, function (fieldName) {
                            var valRetrieved = WatTests.models.host.attributes[fieldName];

                            if (fieldName == 'properties' && WatTests.values.host['__properties__'] != undefined) {
                                deepEqual(valRetrieved, WatTests.valuesExpected.host['__properties__'], "Host field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                            }
                            else if (WatTests.values.host[fieldName] != undefined) {
                                equal(valRetrieved, WatTests.values.host[fieldName], "Host field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                            }
                            else {
                                notEqual(WatTests.models.host.attributes[fieldName], undefined, "Host field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });

                        // Perform changes in testing host values
                        performUpdation(WatTests.values.host, WatTests.updateValues.host);
                        WatTests.valuesExpected.host['__properties__'] = convertPropsToExpected(WatTests.values.host['__properties__'], 'host');

                        //////////////////////////////////////////////////////////////////
                        // After get list of hosts, update it
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.host, {'id': WatTests.values.host.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Host updated succesfully (" + JSON.stringify(WatTests.updateValues.host) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list of hosts matching by name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.host.fetch({   
                                complete: function (e) {
                                    WatTests.values.host.id = WatTests.models.host.attributes['id'];
                                    $.each (WatTests.fakeValues.host, function (fieldName) {
                                        var valRetrieved = WatTests.models.host.attributes[fieldName];

                                        if (fieldName == 'properties' && WatTests.values.host['__properties__'] != undefined) {
                                            deepEqual(valRetrieved, WatTests.valuesExpected.host['__properties__'], "Host field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                        }
                                        else if (WatTests.values.host[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.host[fieldName], "Host field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notEqual(WatTests.models.host.attributes[fieldName], undefined, "Host field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });


                                    //////////////////////////////////////////////////////////////////
                                    // After match the updated user, delete it
                                    //////////////////////////////////////////////////////////////////
                                    Wat.CurrentView.deleteModel({'id': WatTests.values.host.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Host deleted succesfully (ID: " + JSON.stringify(WatTests.values.host.id) + ")");

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