var login = 'superadmin';
var password = 'superadmin';
var tenant = '*';
var tenantId = 0;
var roleShort = {"66": "Root"};
var roleLong = {"66": {
        "description": null,
        "fixed": true,
        "internal": false,
        "name": "Root",
        "tenant_id": -1
    }
};

var visibleViews = ['user', 'vm', 'host', 'osf', 'di', 'tenant', 'administrator', 'role'];

Up.C.setAbortOldRequests(false);

// Backbone's Models and Collections instantiation
backboneTest();

loggedTests = function () {    
    // Render views tests. Just render view by view
    viewTest();
    
    // Tests calling API
    userTestReal();
    vmTestReal();
    hostTestReal();
    osfTestReal();
    diTestReal();
    tenantTestReal();
    roleTestReal();
    adminTestReal();
    qvdConfigTestReal();
    qvdViewsAdminReal();

    // Tests switching language and loading each embeded documentation
    languageDocTest();
}

// Login tests
loginTest(login, password, tenant, loggedTests);


// Tests simulating server response
/*
userTestFake();
vmTestFake();
hostTestFake();
osfTestFake();
diTestFake();
*/