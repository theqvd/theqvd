var login = 'truman';
var password = 'truman';

// Backbone's Models and Collections instantiation
backboneTest();

// Login tests
loginTest();

var tenantUserId = 17;
var tenantVMId = 3;
var tenantOSFId = 14;
var tenantDIId = 14;
var tenantHostId = 1;

// Render views tests. Just render view by view
//viewTest();

// Tests calling API
userTestReal();
vmTestReal();
hostTestReal();
osfTestReal();
diTestReal();