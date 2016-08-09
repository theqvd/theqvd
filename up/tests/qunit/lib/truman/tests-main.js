var login = 'truman';
var password = 'truman';
var tenant = 'default';
var tenantUserId = 10000;
var tenantVMId = 10014;
var tenantOSFId = 10000;
var tenantDIId = 10000;
var tenantHostId = 10001;

var visibleViews = ['vm', 'osf', 'di'];

Up.C.setAbortOldRequests(false);

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

