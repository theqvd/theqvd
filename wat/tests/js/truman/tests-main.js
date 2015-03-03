var login = 'truman';
var password = 'truman';
var tenant = 'Madrid';
var tenantUserId = 17;
var tenantVMId = 3;
var tenantOSFId = 14;
var tenantDIId = 14;
var tenantHostId = 1;

// Backbone's Models and Collections instantiation
backboneTest();

loggedTests = function () {
    // Tests calling API
    userTestReal();
    vmTestReal();
    hostTestReal();
    osfTestReal();
    diTestReal();
    
    // Tests switching language and loading each embeded documentation
    languageDocTest();
}

// Login tests
loginTest();

// Render views tests. Just render view by view
//viewTest();