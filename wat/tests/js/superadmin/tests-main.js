var login = 'superadmin';
var password = 'superadmin';

// Backbone's Models and Collections instantiation
backboneTest();

// Login tests
loginTest();

// Render views tests. Just render view by view
//viewTest();

// Tests simulating server response
/*userTestFake();
vmTestFake();
hostTestFake();
osfTestFake();
diTestFake();*/

// Tests calling API
userTestReal();
vmTestReal();
hostTestReal();
osfTestReal();
diTestReal();