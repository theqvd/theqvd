module( "Virtual machine tests", {
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
    
    test("Virtual machine details call", function() {
        var callback = sinon.spy();
        
        var fakeValues = {};

        fakeValues.id = getRandomInt();
        fakeValues.name = getRandomStr();
        fakeValues.tenant_name = getRandomStr();
        fakeValues.tenant_id = getRandomInt();
        fakeValues.blocked = getRandomInt() > 100 ? 1 : 0;
        fakeValues.vnc_port = getRandomInt();
        fakeValues.ssh_port = getRandomInt();
        fakeValues.serial_port = getRandomInt();
        fakeValues.di_id = getRandomInt();
        fakeValues.di_name = getRandomStr();
        fakeValues.di_tag = getRandomStr();
        fakeValues.di_version = getRandomStr();
        fakeValues.host_id = getRandomInt();
        fakeValues.host_name = getRandomStr();
        fakeValues.osf_id = getRandomInt();
        fakeValues.osf_name = getRandomStr();
        fakeValues.user_id = getRandomInt();
        fakeValues.user_name = getRandomStr();
        fakeValues.user_state = getRandomInt() > 150 ? 'connected' : 'disconnected';
        fakeValues.storage = getRandomInt();
        fakeValues.state = getRandomInt()> 50 ? 'started' : 'stopped';
        fakeValues.ip = getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt();
        fakeValues.next_boot_ip = getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt();
        fakeValues.expiration_hard = getRandomStr();
        fakeValues.expiration_soft = getRandomStr();
        fakeValues.creation_date = getRandomStr();
        fakeValues.creation_admin = getRandomStr();
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
                                    Wat.C.apiUrl + '?login=superadmin&password=superadmin&action=vm_get_details&filters={"id":' + fakeValues.id + '}',
                                    [
                                        200, 
                                        { "Content-Type": "application/json" },
                                        JSON.stringify(fakeResponse)
                                    ]
                               );
        
        Wat.Router.app_router.trigger('route:detailsVM', [fakeValues.id]);        
        
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