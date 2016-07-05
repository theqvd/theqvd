function qvdViewsAdminReal () {
        // Get system properties to complete the dababase data
        var properties = new Up.Collections.Properties();
        properties.fetch({      
            complete: function () {    
    module( "Customize administrator views", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
        $.each(Up.I.listFields, function (qvdObj, fields) {
            if ($.inArray(qvdObj, visibleViews) == -1) {
                return;
            }
            QUnit.asyncTest("Column views (" + qvdObj + ")", function() {
                // Number of Assertions we Expect
                var assertions = 0;

                $.each(fields, function (fieldName, attrs) {
                    if (attrs.fixed != undefined && attrs.fixed) {
                        return;
                    }

                    assertions+=2; // 2 updates for each field
                });

                expect(assertions);

                stop(assertions-1)

                $.each(fields, function (fieldName, attrs) {
                    if (attrs.fixed != undefined && attrs.fixed) {
                        return;
                    }

                    var args = {
                                'view_type': 'list_column',
                                'device_type': 'desktop',
                                'visible': !attrs.display
                    };

                            if (attrs.property) {
                                args.qvd_obj_prop_id = properties.where({key: fieldName})[0].get('in_' + qvdObj);
                                var action = 'admin_property_view_set';
                            }
                            else {
                                args.qvd_object = qvdObj;
                                args.field = fieldName;
                                var action = 'admin_attribute_view_set';
                            }

                            Up.A.performAction(action, args, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        args.visible = attrs.display;
                        start();

                                Up.A.performAction(action, args, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);

                });
            });
        });
    
        $.each(Up.I.formFilters, function (qvdObj, fields) {
            if ($.inArray(qvdObj, visibleViews) == -1) {
                return;
            }
                    
            QUnit.asyncTest("Filter views (" + qvdObj + ")", function() {
                // Number of Assertions we Expect
                var assertions = 0;

                $.each(fields, function (fieldName, attrs) {
                    assertions+=4; // 2 updates for each field in mobile and desktop
                });

                expect(assertions);

                stop(assertions-1)

                $.each(fields, function (fieldName, attrs) {
                    // Filters for desktop 

                    var argsDesktop = {
                                'view_type': 'filter',
                                'device_type': 'desktop',
                                'visible': !attrs.displayDesktop
                    };

                            if (attrs.property) {
                                argsDesktop.qvd_obj_prop_id = properties.where({key: fieldName})[0].get('in_' + qvdObj);
                                var action = 'admin_property_view_set';
                            }
                            else {
                                argsDesktop.qvd_object = qvdObj;
                                argsDesktop.field = fieldName;
                                var action = 'admin_attribute_view_set';
                            }


                            Up.A.performAction(action, argsDesktop, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        argsDesktop.visible = attrs.displayDesktop;
                        start();

                                Up.A.performAction(action, argsDesktop, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);
                    
                    
                    // Filters for mobile 
                    var argsMobile = {
                                'view_type': 'filter',
                                'device_type': 'mobile',
                                'visible': !attrs.displayMobile
                    };

                            if (attrs.property) {
                                argsMobile.qvd_obj_prop_id = properties.where({key: fieldName})[0].get('in_' + qvdObj);
                                var action = 'admin_property_view_set';
                            }
                            else {
                                argsMobile.qvd_object = qvdObj;
                                argsMobile.field = fieldName;
                                var action = 'admin_attribute_view_set';
                            }

                            Up.A.performAction(action, argsMobile, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        argsMobile.visible = attrs.displayMobile;
                        start();

                                Up.A.performAction(action, argsMobile, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);
                });
            });
        });
    
            module( "Reset administrator views", {
                setup: function() {
                    // prepare something for all following tests
                },
                teardown: function() {
                    // clean up after each test
                }
            });
                QUnit.asyncTest("Reset views", function() {
                    expect(1);

                    Up.A.performAction('admin_view_reset',{},{},{}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "Views resetted to default configuration successfully");
                        start();
                    }, this);
                });
                
        }
    });
}