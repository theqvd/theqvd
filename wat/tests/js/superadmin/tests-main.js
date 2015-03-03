var login = 'superadmin';
var password = 'superadmin';
var tenant = '*';
var roleShort = {"1": "Root"};
var roleLong = {"1": {
        "fixed": true,
        "internal": false,
        "name": "Root"
    }
};
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

    // Tests switching language and loading each embeded documentation
    languageDocTest();
}

// Login tests
loginTest();



// Tests simulating server response
/*
userTestFake();
vmTestFake();
hostTestFake();
osfTestFake();
diTestFake();
*/