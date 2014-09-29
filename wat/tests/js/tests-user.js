module( "Users tests", {
    setup: function() {
        // prepare something for all following tests
        this.server = sinon.fakeServer.create();
        
        // Fake Login
        Wat.C.logOut();
        Wat.C.logIn('superadmin', 'superadmin');
    },
    teardown: function() {
        // clean up after each test
        this.server.restore();
        Wat.C.logOut();
    }
});
    
    test("User details call", function() {
        var callback = sinon.spy();
        
        var fakeValues = {};

        fakeValues.id = getRandomInt();
        fakeValues.name = getRandomStr();
        fakeValues.tenant_name = getRandomStr();
        fakeValues.tenant_id = getRandomInt();
        fakeValues.number_of_vms = getRandomInt();
        fakeValues.number_of_vms_connected = getRandomInt();
        fakeValues.blocked = getRandomInt() > 100 ? 1 : 0;
        fakeValues.properties = {
            'property 1': getRandomStr(),
            'property N': getRandomStr()
        };
        
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
                                    Wat.C.apiUrl + '?login=superadmin&password=superadmin&action=user_get_details&filters={"id":' + fakeValues.id + '}',
                                    [
                                        200, 
                                        { "Content-Type": "application/json" },
                                        JSON.stringify(fakeResponse)
                                    ]
                               );
        
        Wat.Router.app_router.trigger('route:detailsUser', [fakeValues.id]);        
        
        // Bind to the change event on the model
        Wat.CurrentView.model.bind('change', callback);
                
        this.server.respond();
        
        ok(callback.called, "Server call");
        
        $.each(fakeValues, function (fieldName, fieldValue) {
            if (typeof fieldValue == 'object') {
                deepEqual(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Virtual machine fetching should recover '" + fieldName + "' properly (Random generated: " + JSON.stringify(fieldValue) + ")");
            }
            else {
                equal(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Virtual machine fetching should recover '" + fieldName + "' properly (Random generated: " + fieldValue + ")");
            }
        });

        deepEqual(callback.getCall(0).args[0], Wat.CurrentView.model, "Spied result and Backbone model should be equal");
    });