var login = 'truman';
var password = 'truman';
var tenant = 'qvd';
var tenantUserId = 17;
var tenantVMId = 3;
var tenantOSFId = 14;
var tenantDIId = 4;
var tenantHostId = 1;

var visibleViews = ['vm', 'osf', 'di'];

Wat.C.setSource('TESTING truman');
Wat.C.setAbortOldRequests(false);

// Backbone's Models and Collections instantiation
backboneTest();

afterProfileTests = function () {
    // Render views tests. Just render view by view
    viewTest();
    
    // Tests calling API
    userTestReal();
    vmTestReal();
    hostTestReal();
    osfTestReal();
    diTestReal();
    qvdViewsAdminReal();

    // Tests switching language and loading each embeded documentation
    languageDocTest();
}


loggedTests = function () {
    profileTest();
}

// Login tests
loginTest(login, password, tenant, loggedTests);

