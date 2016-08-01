function userTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("User CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions = 3; // Create, Read and Update verifications

            expect(assertions);

            Up.Router.upRouter.trigger('route:listUser');
            
            Up.CurrentView.model = new Up.Models.User();

            //////////////////////////////////////////////////////////////////
            // Create User
            //////////////////////////////////////////////////////////////////
            Up.CurrentView.createModel(WatTests.values.user, function (e) { 
                equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "User cannot be created due ACLs restriction (" + JSON.stringify(WatTests.values.user) + ")");

                if(e.retrievedData.status == STATUS_FORBIDDEN_ACTION) {
                    // As the creation is forbidden, we store existing user ID
                    WatTests.values.user.id = tenantUserId;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // Try to get list of users matching by the existing ID
                //////////////////////////////////////////////////////////////////
                WatTests.models.user = new Up.Models.User({
                    id: WatTests.values.user.id
                });            
                                
                WatTests.models.user.fetch({      
                    complete: function (e) {
                        var status = JSON.parse(e.responseText).status;
                        equal(status, STATUS_FORBIDDEN_ACTION, "User cannot be retrieved due ACLs restriction");

                        // Perform changes in testing user values
                        performUpdation(WatTests.values.user, WatTests.updateValues.user);

                        //////////////////////////////////////////////////////////////////
                        // Try to update user
                        //////////////////////////////////////////////////////////////////
                        Up.CurrentView.updateModel(WatTests.updateValues.user, {'id': WatTests.values.user.id}, function (e) { 
                            equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "User cannot be updated due ACLs restriction (" + JSON.stringify(WatTests.updateValues.user) + ")");

                            start();
                        }, WatTests.models.user);
                    }
                });
            });
        });
}