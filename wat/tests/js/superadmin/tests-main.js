var login = 'superadmin';
var password = 'superadmin';
var tenant = '*';

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

// Tests simulating server response
/*
userTestFake();
vmTestFake();
hostTestFake();
osfTestFake();
diTestFake();
*/