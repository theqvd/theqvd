function qvdViewsAdminReal () {
    module( "Customize administrator views", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        $.each(Wat.I.listFields, function (qvdObj, fields) {
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
                        "field": fieldName,
                        "view_type": "list_column",
                        "device_type": "desktop",
                        "visible": !attrs.display,
                        "qvd_object": qvdObj,
                        "property": attrs.property
                    };


                    Wat.A.performAction('admin_view_set', args, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        args.visible = attrs.display;
                        start();

                        Wat.A.performAction('admin_view_set', args, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);

                });
            });
        });
    
        $.each(Wat.I.formFilters, function (qvdObj, fields) {
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
                        "field": fieldName,
                        "view_type": "filter",
                        "device_type": "desktop",
                        "visible": !attrs.displayDesktop,
                        "qvd_object": qvdObj,
                        "property": attrs.property
                    };


                    Wat.A.performAction('admin_view_set', argsDesktop, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        argsDesktop.visible = attrs.displayDesktop;
                        start();

                        Wat.A.performAction('admin_view_set', argsDesktop, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);
                    
                    
                    // Filters for mobile 
                    
                    var argsMobile = {
                        "field": fieldName,
                        "view_type": "filter",
                        "device_type": "mobile",
                        "visible": !attrs.displayMobile,
                        "qvd_object": qvdObj,
                        "property": attrs.property
                    };

                    Wat.A.performAction('admin_view_set', argsMobile, {}, {}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' update successfully from '" + String(attrs.display ? 1 : 0) + "' to '" + String(attrs.display ? 0 : 1) + "' (" + that.retrievedData.message + ")");

                        argsMobile.visible = attrs.displayMobile;
                        start();

                        Wat.A.performAction('admin_view_set', argsMobile, {}, {}, function (that) {
                            equal(that.retrievedData.status, STATUS_SUCCESS, "View for column list of '" + qvdObj + " -> " + fieldName + "' re-update successfully from '" + String(attrs.display ? 0 : 1) + "' to '" + String(attrs.display ? 1 : 0) + "' (" + that.retrievedData.message + ")");
                            start();
                        }, that);

                    }, this);
                });
            });
        });
    
    QUnit.moduleDone(function( details ) {
        // Reset views after done of the Customize administrator views module
        if (details.name == 'Customize administrator views') {
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

                    Wat.A.performAction('admin_view_reset',{},{},{}, function (that) {
                        equal(that.retrievedData.status, STATUS_SUCCESS, "Views resetted to default configuration successfully");
                        start();
                    }, this);
                });
        }
    });
}