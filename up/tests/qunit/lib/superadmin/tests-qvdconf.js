function qvdConfigTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("QVD Config default keys changes", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += 5; // Get+Update+Get+Default+Get

            expect(assertions);

            Up.Router.watRouter.trigger('route:setupConfig');
            
            // Define different parameters for get, set and default actions
            var searchedKey = 'model.user.login.case-sensitive';
            
            var getAction = 'config_get';
            var getBranchFilters = {
                'key': {'~': 'model.%'},
                'tenant_id': tenantId
            };
            var getTokenFilters = {
                'key': searchedKey,
                'tenant_id': tenantId
            };
            
            var updateAction = 'config_set';
            var updateArguments = {
                'key': searchedKey,
                'value': 1,
                'tenant_id': tenantId
            };
            var updateFilters = {};
            var updateMessage = 'QVD config key update to new value correctly';

            var defaultAction = 'config_default';
            var defaultArguments = {};
            var defaultFilters = {
                'key': searchedKey
            };
            var defaultMessage = 'QVD config key restored to default value correctly';
            
            // Get 'model.' branch
            Up.A.performAction(getAction, {}, getBranchFilters, {}, function (that) {
                var keyFound = false;
                var valueFound = null;
                var defaultValueFound = null;
                
                $.each(that.retrievedData.rows, function (i, row) {
                    if (row.key == searchedKey) {
                        keyFound = true;
                        valueFound = row.operative_value;
                        defaultValueFound = row.default_value;
                    }
                });
                
                equal(keyFound, true, "Key '" + searchedKey + "' retrieved correctly from QVD config (" + valueFound + ")");
                
                // If value is equal to default: UPDATE - SET DEFAULT
                // If value is not equal to default: SET DEFAULT - UPDATE
                
                if (valueFound == defaultValueFound) {
                    var firstUpdateAction = updateAction;
                    var firstUpdateArguments = updateArguments;
                    var firstUpdateFilters = updateFilters;
                    var firstNewValue = firstUpdateArguments.value;
                    var firstMessage = updateMessage;
                    var secondUpdateAction = defaultAction;
                    var secondUpdateArguments = defaultArguments;
                    var secondUpdateFilters = defaultFilters;
                    var secondNewValue = defaultValueFound;
                    var secondMessage = defaultMessage;
                }
                else {
                    var firstUpdateAction = defaultAction;
                    var firstUpdateArguments = defaultArguments;
                    var firstUpdateFilters = defaultFilters;
                    var firstNewValue = defaultValueFound;
                    var firstMessage = defaultMessage;
                    var secondUpdateAction = updateAction;
                    var secondUpdateArguments = updateArguments;
                    var secondUpdateFilters = updateFilters;
                    var secondNewValue = valueFound;
                    var secondMessage = updateMessage;
                }
                
                // First Update (Update or set default)
                Up.A.performAction(firstUpdateAction, firstUpdateArguments, firstUpdateFilters, {}, function (that) {
                    equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config key update successfully");
                    
                    // After first update, get key to check if the value was properly changed
                    Up.A.performAction(getAction, {}, getTokenFilters, {}, function (that) {
                        equal(that.retrievedData.rows[0].operative_value, firstNewValue, firstMessage + " (" + firstNewValue + ")");

                        // Second Update (Update or set default)
                        Up.A.performAction(secondUpdateAction, secondUpdateArguments, secondUpdateFilters, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config key update successfully");
                    
                            // After second update, get key to check if the value was properly changed
                            Up.A.performAction(getAction, {}, getTokenFilters, {}, function (that) {
                                equal(that.retrievedData.rows[0].operative_value, secondNewValue, secondMessage + " (" + secondNewValue + ")");
                                
                                start();
                            }, that);

                        }, that);
                    }, that);
                    
                }, that);

            }, this);
        });
    
    

        QUnit.asyncTest("QVD Config custom keys changes", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += 6; // Check branch+Create key+Check key+Create key2+Check key2+Check branch
            assertions += 2; // Update key+Check key
            assertions += 6; // Delete key+Check key+Check branch+Delete key2+Check key2+Check branch

            expect(assertions);

            Up.Router.watRouter.trigger('route:setupConfig');
            
            // Define different parameters for get, set and default actions
            var customBranch = getRandomStr();
            var customKey = getRandomStr();
            var customKey2 = getRandomStr();
            var customFullKey = customBranch + '.' + customKey;
            var customFullKey2 = customBranch + '.' + customKey2;
            var customValue = getRandomStr();
            var customValue2 =  getRandomStr();
            var customNewValue = getRandomStr();
            
            var getAction = 'config_get';
            var getBranchFilters = {
                'key': {'~': customBranch + '.%'},
                'tenant_id': tenantId
            };
            var getTokenFilters = {
                'key': customFullKey,
                'tenant_id': tenantId
            };
            var getTokenFilters2 = {
                'key': customFullKey2,
                'tenant_id': tenantId
            };
            
            var updateAction = 'config_set';
            var updateArguments = {
                'key': customFullKey,
                'value': customValue,
                'tenant_id': tenantId
            };
            var updateArguments2 = {
                'key': customFullKey2,
                'value': customValue2,
                'tenant_id': tenantId
            };
            var updateNewArguments = {
                'key': customFullKey,
                'value': customNewValue,
                'tenant_id': tenantId
            };
            var updateFilters = {};
            var updateFilters2 = {};
            var updateNewFilters = {};
            
            var deleteAction = 'config_delete';
            var deleteFilters = {
                'key': customFullKey,
                'tenant_id': tenantId
            };
            var deleteFilters2 = {
                'key': customFullKey2,
                'tenant_id': tenantId
            };
            
            // Check if custom branch doesnt exist yet
            Up.A.performAction(getAction, {}, getBranchFilters, {}, function (that) {
                equal(that.retrievedData.total, 0, "Branch " + customBranch + ".* doesnt exist yet");
                                
                // Create custom key
                Up.A.performAction(updateAction, updateArguments, updateFilters, {}, function (that) {
                    equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config custom key created successfully");
                    
                    // After creation, get key to check if the value was properly changed
                    Up.A.performAction(getAction, {}, getTokenFilters, {}, function (that) {
                        equal(that.retrievedData.rows[0].operative_value, customValue, "Value of created key recovered successfully (" + customValue + ")");

                        // Create another custom key
                        Up.A.performAction(updateAction, updateArguments2, updateFilters2, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config custom key created successfully");

                            // After second creation, get key to check if the value was properly changed
                            Up.A.performAction(getAction, {}, getTokenFilters2, {}, function (that) {
                                equal(that.retrievedData.rows[0].operative_value, customValue2, "Value of created key retrieved successfully (" + customValue2 + ")");
                                
                                // Check if custom branch exist and have two results
                                Up.A.performAction(getAction, {}, getBranchFilters, {}, function (that) {
                                    equal(that.retrievedData.total, 2, "Branch " + customBranch + ".* exist and have two keys");
                             
                                    // Update one of the keys
                                    Up.A.performAction(updateAction, updateNewArguments, updateNewFilters, {}, function (that) {
                                        equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config key update successfully");

                                        // After update, get key to check if the value was properly changed
                                        Up.A.performAction(getAction, {}, getTokenFilters, {}, function (that) {
                                            equal(that.retrievedData.rows[0].operative_value, customNewValue, "Updated value of the custom config key retrieved successfully (" + customNewValue + ")");
                                            // Delete custom key
                                            Up.A.performAction(deleteAction, {}, deleteFilters, {}, function (that) {
                                                equal(that.retrievedData.status, STATUS_SUCCESS, "Deleted key successfully (" + customFullKey + ")");

                                                // After deletion, try to recover key to check if is really deleted
                                                Up.A.performAction(getAction, {}, getTokenFilters, {}, function (that) {
                                                    equal(that.retrievedData.total, 0, "Recently deleted key is not found (" + customFullKey + ")");

                                                    // Try to get branch to check if only one key is retrieved
                                                    Up.A.performAction(getAction, {}, getBranchFilters, {}, function (that) {
                                                        equal(that.retrievedData.total, 1, "Branch " + customBranch + ".* exist and has just 1 key");
                                                        
                                                        // Delete another custom key
                                                        Up.A.performAction(deleteAction, {}, deleteFilters2, {}, function (that) {
                                                            equal(that.retrievedData.status, STATUS_SUCCESS, "Deleted key successfully (" + customFullKey2 + ")");

                                                            // After deletion, try to recover key to check if is really deleted
                                                            Up.A.performAction(getAction, {}, getTokenFilters2, {}, function (that) {
                                                                equal(that.retrievedData.total, 0, "Recently deleted key is not found (" + customFullKey2 + ")");
                                                                
                                                                // Finally we try to recover branch to check that doesnt exist
                                                                Up.A.performAction(getAction, {}, getBranchFilters, {}, function (that) {
                                                                    equal(that.retrievedData.total, 0, "Branch " + customBranch + ".* doesnt exist anymore");

                                                                    start();
                                                                }, that);
                                                                
                                                            }, that);

                                                        }, that);

                                                    }, that);
                                                    
                                                }, that);
                                                
                                            }, that);

                                        }, that);

                                    }, that);
                                    
                                }, that);
                                
                            }, that);

                        }, that);
                        
                    }, that);
                    
                }, that);

            }, this);
        });
    

/* STRESS TEST

        QUnit.asyncTest("QVD Config stress test", function() {
            var testedKeys = 100;
            
            assertions = testedKeys * 4; // Creation + 2 Updates + Delete
            expect(assertions);

            stop(assertions-1);
            
            var customBranch = getRandomStr();
            
            var deleteAction = 'config_delete';
            var updateAction = 'config_set';
            var getAction = 'config_get';
            
            // Create keys
            for(i=1;i<=testedKeys;i++) {
                var createArguments = {
                    'key': customBranch + '.key' + i,
                    'value': 1
                };
                
                Up.A.performAction(updateAction, createArguments, {}, {}, function (that) {
                    equal(that.retrievedData.status, STATUS_SUCCESS, "QVD config custom key '" + that.key + "' created successfully");
                    start();

                    var updateArguments = {
                        "key": that.key,
                        "value": "0"
                    };
                    
                    Up.A.performAction(updateAction, updateArguments, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "Config key '" + that.key + "' update successfully to '" + that.value + "' (" + that.retrievedData.message + ")");

                        var updateArguments = {
                            "key": that.key,
                            "value": "1"
                        };
                        start();

                        Up.A.performAction(updateAction, updateArguments, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "Config key '" + that.key + "' update successfully to '" + that.value + "' (" + that.retrievedData.message + ")");
                            start();
                            
                            var deleteFilters = {
                                "key": that.key
                            };
                            
                            // Delete another custom key
                            Up.A.performAction(deleteAction, {}, deleteFilters, {}, function (that) {
                                equal(that.retrievedData.status, STATUS_SUCCESS, "Deleted key successfully (" + that.key + ")");
                                start();
                            }, deleteFilters);
                            
                        }, updateArguments);
                        
                    }, updateArguments);
                    
                }, createArguments);
            }
        });
*/

}