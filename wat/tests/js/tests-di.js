module( "Disk image tests", {
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
                                    Wat.C.apiUrl + '?login=superadmin&password=superadmin&action=di_get_details&filters={"id":' + fakeValues.id + '}',
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

