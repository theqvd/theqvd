function vmTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
            
            // Truman will not receive tenant info
            delete WatTests.fakeValues.vm.tenant_name;
            delete WatTests.fakeValues.vm.tenant_id;
            
            // Name will not be updated to not ruin the tests environment 
            delete WatTests.updateValues.vm.name;
            delete WatTests.values.vm.name;
            
            // Restricted fields
            restrictedFields = [
                'properties',
                'vnc_port',
                'ssh_port',
                'serial_port',
                'user_id',
                'user_name',
                'host_id',
                'host_name',
                'di_id',
                'di_name',
                'next_boot_ip',
                'creation_admin',
                'creation_date'
            ];
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("VM CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.vm).length * 2; // Create & Update verifications. (Password will not be verified because is not returned)
            assertions += 3; // Create, Read and Update verifications

            expect(assertions);

            Wat.Router.app_router.trigger('route:listVM');
            
            Wat.CurrentView.model = new Wat.Models.VM();

            //////////////////////////////////////////////////////////////////
            // Create VM
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.vm, function (e) { 
                equal(e.retrievedData.status, STATUS_FORBIDDEN_ACTION, "VM cannot be created due ACLs restriction (" + JSON.stringify(WatTests.values.vm) + ")");

                if(e.retrievedData.status == STATUS_FORBIDDEN_ACTION) {
                    // As the creation is forbidden, we store existing vm ID
                    WatTests.values.vm.id = tenantVMId;
                }
                else {
                    start();
                    return;
                }

                //////////////////////////////////////////////////////////////////
                // Try to get list of vms matching by the existing ID
                //////////////////////////////////////////////////////////////////
                WatTests.models.vm = new Wat.Models.VM({
                    id: WatTests.values.vm.id
                });            
                                
                WatTests.models.vm.fetch({      
                    complete: function () {
                        $.each (WatTests.fakeValues.vm, function (fieldName) {
                            var valRetrieved = WatTests.models.vm.attributes[fieldName];

                            // Truman cannot see properties of any qvd Object
                            if ($.inArray(fieldName, restrictedFields) != -1) {
                                equal(WatTests.models.vm.attributes[fieldName], undefined, "DI field '" + fieldName + "' cannot be retrieved due ACLs restriction (" + valRetrieved + ")");
                            }
                            else {
                                notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "DI field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                            }
                        });
                        
                        //////////////////////////////////////////////////////////////////
                        // After get list of osfs, update it
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.vm, {'id': WatTests.values.vm.id}, function (e) { 
                            equal(e.retrievedData.status, STATUS_FORBIDDEN_ARGUMENT, "VM cannot be updated due ACLs restriction (" + JSON.stringify(WatTests.updateValues.vm) + ")");
                        }, Wat.CurrentView.model);
                        
                        
                        // Truman will not be able to update properties 
                        delete WatTests.updateValues.vm.__properties_changes__;
                        
                        // Perform changes in testing virtual machine values
                        performUpdation(WatTests.values.vm, WatTests.updateValues.vm);

                        //////////////////////////////////////////////////////////////////
                        // After get list of virtual machines, update it
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.updateModel(WatTests.updateValues.vm, {'id': WatTests.values.vm.id}, function (e) { 
                            equal(e.retrievedData.status, 0, "Virtual machine updated succesfully (" + JSON.stringify(WatTests.updateValues.vm) + ")");

                            //////////////////////////////////////////////////////////////////
                            // After update, get list ofvirtual machines matching by name
                            //////////////////////////////////////////////////////////////////
                            
                            WatTests.values.vm.osf_id = tenantOSFId;
                            
                            WatTests.models.vm.fetch({   
                                complete: function (e) {
                                    WatTests.values.vm.id = WatTests.models.vm.attributes['id'];
                                    $.each (WatTests.fakeValues.vm, function (fieldName) {
                                        var valRetrieved = WatTests.models.vm.attributes[fieldName];

                                        if ($.inArray(fieldName, restrictedFields) != -1) {
                                            equal(WatTests.models.vm.attributes[fieldName], undefined, "DI field '" + fieldName + "' cannot be retrieved due ACLs restriction (" + valRetrieved + ")");
                                        }
                                        else if (WatTests.values.vm[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.vm[fieldName], "Virtual machine '" + fieldName + "' retrieved successfully and match with updated value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "Virtual machine field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });
                                    
                                    start();
                                }
                            });
                        }, Wat.CurrentView.model);
                    }
                });
            });
        });
}

function vmTestReal2 () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Virtual machine CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.vm).length * 2; // Create & Update verifications
            assertions +=2; // Create and Delete dependences (User)
            assertions +=2; // Create and Delete dependences (OSF)
            assertions +=2; // Create and Delete dependences (DI)
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            // Move to OSFs section
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

                // Move to Disk images section
                Wat.Router.app_router.trigger('route:listDI');

                Wat.CurrentView.model = new Wat.Models.DI();

                // Create DI associated to the created OSF
                WatTests.values.di.osf_id = WatTests.values.osf.id;

                //////////////////////////////////////////////////////////////////
                // Create dependency DI
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

                    // Move to Users section
                    Wat.Router.app_router.trigger('route:listUser');

                    Wat.CurrentView.model = new Wat.Models.User();

                    //////////////////////////////////////////////////////////////////
                    // Create Dependency User
                    //////////////////////////////////////////////////////////////////
                    Wat.CurrentView.createModel(WatTests.values.user, function (e) { 
                        equal(e.retrievedData.status, STATUS_SUCCESS, "User created succesfully (" + JSON.stringify(WatTests.values.user) + ")");

                        if(e.retrievedData.status == STATUS_SUCCESS) {
                            WatTests.values.user.id = e.retrievedData.rows[0].id;
                        }
                        else {
                            start();
                            return;
                        }

                        // Move to Virtual machines section
                        Wat.Router.app_router.trigger('route:listVM');

                        Wat.CurrentView.model = new Wat.Models.VM();

                        // Create VM associated to the created User, OSF and DI
                        WatTests.values.vm.osf_id = WatTests.values.osf.id;
                        WatTests.values.vm.di_tag = WatTests.values.di.version;
                        WatTests.values.vm.user_id = WatTests.values.user.id;

                        //////////////////////////////////////////////////////////////////
                        // Create Virtual machine
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.createModel(WatTests.values.vm, function (e) { 
                            equal(e.retrievedData.status, STATUS_SUCCESS, "Virtual machine created succesfully (" + JSON.stringify(WatTests.values.vm) + ")");

                            if(e.retrievedData.status == STATUS_SUCCESS) {
                                WatTests.values.vm.id = e.retrievedData.rows[0].id;
                            }
                            else {
                                start();
                                return;
                            }

                            //////////////////////////////////////////////////////////////////
                            // After create, get list of virtual machines matching by the created name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.vm = new Wat.Models.VM({
                                id: WatTests.values.vm.id
                            });

                            WatTests.models.vm.fetch({      
                                complete: function () {
                                    $.each (WatTests.fakeValues.vm, function (fieldName) {
                                        var valRetrieved = WatTests.models.vm.attributes[fieldName];

                                        if (fieldName == 'properties' && WatTests.values.vm['__properties__'] != undefined) {
                                            deepEqual(valRetrieved, WatTests.values.vm['__properties__'], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                        }
                                        else if (WatTests.values.vm[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.vm[fieldName], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "Virtual machine field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });

                                    // Perform changes in testing virtual machine values
                                    performUpdation(WatTests.values.vm, WatTests.updateValues.vm);

                                    //////////////////////////////////////////////////////////////////
                                    // After get list of virtual machines, update it
                                    //////////////////////////////////////////////////////////////////
                                    Wat.CurrentView.updateModel(WatTests.updateValues.vm, {'id': WatTests.values.vm.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Virtual machine updated succesfully (" + JSON.stringify(WatTests.updateValues.vm) + ")");

                                        //////////////////////////////////////////////////////////////////
                                        // After update, get list ofvirtual machines matching by name
                                        //////////////////////////////////////////////////////////////////
                                        WatTests.models.vm.fetch({   
                                            complete: function (e) {
                                                WatTests.values.vm.id = WatTests.models.vm.attributes['id'];
                                                $.each (WatTests.fakeValues.vm, function (fieldName) {
                                                    var valRetrieved = WatTests.models.vm.attributes[fieldName];

                                                    if (fieldName == 'properties' && WatTests.values.vm['__properties__'] != undefined) {
                                                        deepEqual(valRetrieved, WatTests.values.vm['__properties__'], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                    else if (WatTests.values.vm[fieldName] != undefined) {
                                                        equal(valRetrieved, WatTests.values.vm[fieldName], "Virtual machine '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                    }
                                                    else {
                                                        notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "Virtual machine field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                                    }
                                                });


                                                //////////////////////////////////////////////////////////////////
                                                // After tests, delete virtual machine
                                                //////////////////////////////////////////////////////////////////
                                                Wat.CurrentView.deleteModel({'id': WatTests.values.vm.id}, function (e) { 
                                                    equal(e.retrievedData.status, 0, "Virtual machine deleted succesfully (ID: " + JSON.stringify(WatTests.values.vm.id) + ")");

                                                    //////////////////////////////////////////////////////////////////
                                                    // After delete virtual machine, delete the dependency user
                                                    //////////////////////////////////////////////////////////////////

                                                    Wat.Router.app_router.trigger('route:listUser');

                                                    Wat.CurrentView.model = new Wat.Models.User();

                                                    Wat.CurrentView.deleteModel({'id': WatTests.values.user.id}, function (e) { 
                                                        equal(e.retrievedData.status, 0, "User deleted succesfully (ID: " + JSON.stringify(WatTests.values.user.id) + ")");
                                                    }, Wat.CurrentView.model);

                                                    //////////////////////////////////////////////////////////////////
                                                    // After delete virtual machine, delete the dependency disk image
                                                    //////////////////////////////////////////////////////////////////

                                                    Wat.Router.app_router.trigger('route:listDI');

                                                    Wat.CurrentView.model = new Wat.Models.DI();

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
                                                }, Wat.CurrentView.model);

                                            }
                                        });
                                    }, Wat.CurrentView.model);
                                }
                            });
                        });
                    });
                });
            });
        });
}