function profileTest () {
    module( "Profile edition testing", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
    
        QUnit.asyncTest("Profile changes (language, block and password)", function() {
            var assertions = 1;
            expect(assertions);
            
            var filters = {
                "id": Up.C.adminID
            };
                        
            var currentAttrs = {
                language: Up.C.language,
                block: Up.C.block,
                password: password
            };
            
            var newAttrs = {
                password: getRandomStr()
            };
            
            if (currentAttrs.language != 'es') {
                newAttrs.language = 'es';
            }
            else {
                newAttrs.language = 'en';
            }      
            
            if (currentAttrs.block != 10) {
                newAttrs.block = 10;
            }
            else {
                newAttrs.block = 20;
            }
            
            var args = newAttrs;
            

            // Get 'model.' branch
            Up.A.performAction('myadmin_update', args, filters, {}, function (that) {
                equal(that.retrievedData.status, STATUS_SUCCESS, "Profile updated successfully (" + JSON.stringify(args) + ")");
                start();
                
                loginTest(login, newAttrs.password, tenant, function () {
                    profileAfterUpdateTest(currentAttrs, newAttrs, profileRestoreTest);
                });

            }, this);
        });
  
}

function profileAfterUpdateTest (oldAttrs, newAttrs, callback) {
    module( "Profile edition testing", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
        
        test("Profile checks after update", function() {
            var assertions = Object.keys(newAttrs).length - 1; // Check all attrs but password because it is tested in login
            expect(assertions);
            
            $.each(newAttrs, function (name, value) {
                if (name == 'password') {
                    return;
                }
                equal(Up.C[name], value, "New field '" + name + "' has setted new value '" + value + "' succesfully");
            });
            
            callback(oldAttrs, newAttrs);
        });
  }

function profileRestoreTest (oldAttrs, newAttrs) {
    module( "Profile edition testing", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
    
        QUnit.asyncTest("Profile restoring to original values", function() {
            var assertions = 1;
            expect(assertions);
            
            var filters = {
                "id": Up.C.adminID
            };
            
            var args = {
                "language": oldAttrs.language,
                "block": oldAttrs.block,
                "password": oldAttrs.password
            };
            

            // Get 'model.' branch
            Up.A.performAction('myadmin_update', args, filters, {}, function (that) {
                equal(that.retrievedData.status, STATUS_SUCCESS, "Profile updated successfully (" + JSON.stringify(args) + ")");
                start();
                
                loginTest(login, oldAttrs.password, tenant, function () {
                    profileAfterUpdateTest(newAttrs, oldAttrs, afterProfileTests);
                });

            }, this);
        });
  }