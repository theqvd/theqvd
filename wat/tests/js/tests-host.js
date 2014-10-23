module( "Host fake tests", {
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
            "result": {
                "rows" : [
                    fakeValues
                ]
            },
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
        
        Wat.Router.app_router.trigger('route:detailsHost', [fakeValues.id]);        
        
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