// Set timeout of 60 seconds per test
// QUnit.config.testTimeout = 60000;

// Override configuration constants
APP_PATH = '../../';

// Id of prop1, prop2 and propN properties. This id is in test machine DB. If changes, test will fail
var propertyIDs = {
    prop1: 185,
    prop2: 197,
    prop3: 201,
    propN: 198
};

var propertyNames = {
    185: "prop1",
    197: "prop2",
    201: "prop3",
    198: "propN"
};

WatTests = {};

WatTests.models = {
        user: {},
        vm: {},
        host: {},
        osf: {},
        di: {},
        tenant: {},
        admin: {},
        role: {}
    };
WatTests.collections = {
        user: {},
        vm: {},
        host: {},
        osf: {},
        di: {},
        tenant: {},
        admin: {},
        role: {}
    };
WatTests.listViews = {
        user: {},
        vm: {},
        host: {},
        osf: {},
        di: {},
        tenant: {},
        admin: {},
        role: {}
    };
WatTests.detailViews = {
        user: {},
        vm: {},
        host: {},
        osf: {},
        di: {},
        tenant: {},
        admin: {},
        role: {}
    };
WatTests.values = {
        user: {
            "description": getRandomStr(),
            "__properties__" : {
                "prop1": getRandomStr(),
                "prop2": getRandomStr(),
                "propN": getRandomStr()
            },
            "blocked": getRandomStr() > 127 ? 1 : 0,
            "name": getRandomStr(),
            "password": getRandomStr(),
            "tenant_id": 1
        },
        vm: {
            "description": getRandomStr(),
            "__properties__" : {
                "prop1": getRandomStr(),
                "prop2": getRandomStr(),
                "propN": getRandomStr()
            },
            "blocked": getRandomStr() > 127 ? 1 : 0,
            "name": getRandomStr(),
            "user_id": 0,
            "osf_id": 0,
            "di_tag": 'default'
        },
        host: {
            "description": getRandomStr(),
            "__properties__" : {
                "prop1": getRandomStr(),
                "prop2": getRandomStr(),
                "propN": getRandomStr()
            },
            "blocked": getRandomStr() > 127 ? 1 : 0,
            "name": getRandomStr(),
            "address": getRandomStr()
        },
        osf: {
            "description": getRandomStr(),
            "__properties__" : {
                "prop1": getRandomStr(),
                "prop2": getRandomStr(),
                "propN": getRandomStr()
            },
            "name": getRandomStr(),
            "memory": getRandomInt(),
            "user_storage": getRandomInt(),
            "tenant_id": 1
        },
        di: {
            "description": getRandomStr(),
            "__properties__" : {
                "prop1": getRandomStr(),
                "prop2": getRandomStr(),
                "propN": getRandomStr()
            },
            "__tags__" : [
                getRandomStr(),
                getRandomStr(),
                getRandomStr()
            ],
            "disk_image": 'fake.tgz',
            "version": getRandomStr(),
            "blocked": getRandomStr() > 127 ? 1 : 0,
            "osf_id": 0
        },
        tenant: {
            "description": getRandomStr(),
            "name": getRandomStr(),
            "language": "auto",
            "block": getRandomInt()
        },
        admin: {
            "description": getRandomStr(),
            "name": getRandomStr(),
            "language": "default",
            "block": getRandomInt(),
            "password": getRandomStr(),
            "tenant_id": null,
        },
        role: {
            "description": getRandomStr(),
            "name": getRandomStr(),
            "tenant_id": 1
        }
    };

WatTests.valuesExpected = {};

// Replace properties by IDs
$.each(WatTests.values, function (iVal, val) {
    if (val['__properties__']) {
        WatTests.valuesExpected[iVal] = { 
            '__properties__': {}
        };
        
        $.each(val['__properties__'], function (pName, pValue) {
            WatTests.values[iVal]['__properties__'][propertyIDs[pName]] = pValue;
        
            WatTests.valuesExpected[iVal]['__properties__'][propertyIDs[pName]] = {
                key: pName,
                tenant_id: 1,
                value: pValue
            }
                        
            delete WatTests.values[iVal]['__properties__'][pName];
        });
    }
});

WatTests.updateValues = {
        user: {
            "__properties_changes__" : {
                "set": {
                    "prop3": getRandomStr(), // Add new property
                    "propN": getRandomStr()  // Update property
                }
            },
            "blocked": WatTests.values.user.blocked ? 0 : 1, // Change blocked status
            "description": getRandomStr(),
            "password": getRandomStr()
        },
        vm: {
            "__properties_changes__" : {
                "set": {
                    "prop3": getRandomStr(), // Add new property
                    "propN": getRandomStr()  // Update property
                }
            },
            "name": getRandomStr(),
            "blocked": WatTests.values.user.blocked ? 0 : 1, // Change blocked status
            "description": getRandomStr(),
            "di_tag": 'default',
        },
        host: {},
        osf: {
            "__properties_changes__" : {
                "set": {
                    "prop3": getRandomStr(), // Add new property
                    "propN": getRandomStr()  // Update property
                }
            },
            "name": getRandomStr(),
            "description": getRandomStr(),
            "memory": getRandomInt(),
            "user_storage": getRandomInt()
        },
        di: {
            "__properties_changes__" : {
                "set": {
                    "prop3": getRandomStr(), // Add new property
                    "propN": getRandomStr()  // Update property
                }
            },
            "__tags_changes__" : {
                "create": [
                    getRandomStr() // Add new tag
                ],
                "delete": [
                    WatTests.values.di.__tags__[0] // Delete property
                ]
            },
            "description": getRandomStr(),
            "blocked": WatTests.values.di.blocked ? 0 : 1 // Change blocked status
        },
        tenant: {
            "name": getRandomStr(),
            "description": getRandomStr(),
            "language": "en",
            "block": getRandomInt()
        },
        admin: {
            "name": getRandomStr(),
            "description": getRandomStr(),
            "language": "en",
            "password": getRandomStr(),
            "block": getRandomInt(),
            "__roles_changes__": {
                "assign_roles": ["1"]
            }
        },
        role: {
            "name": getRandomStr(),
            "description": getRandomStr(),
            "__acls_changes__": {
                "unassign_acls": ["user.delete.", "vm.delete"]
            },
            "__roles_changes__": {
                "assign_roles": ["1"]
            }
        }
    };

// Replace properties by IDs
$.each(WatTests.updateValues, function (iVal, val) {
    if (val['__properties_changes__']) {
        $.each(val['__properties_changes__']['set'], function (pName, pValue) {
            WatTests.updateValues[iVal]['__properties_changes__']['set'][propertyIDs[pName]] = pValue;
            delete WatTests.updateValues[iVal]['__properties_changes__']['set'][pName];
        });
    }
});

// Calculate random string for DI version here because will be assigned to two fields
var di_version = getRandomStr();

WatTests.fakeValues = {
        user: {
            id: getRandomInt(),
            name: getRandomStr(),
            tenant_name: getRandomStr(),
            tenant_id: getRandomInt(),
            number_of_vms: getRandomInt(),
            number_of_vms_connected: getRandomInt(),
            blocked: getRandomInt() > 127 ? 1 : 0,
            properties: {
                'property 1': getRandomStr(),
                'property N': getRandomStr()
            }
        },
        vm: {
            id: getRandomInt(),
            name: getRandomStr(),
            tenant_name: getRandomStr(),
            tenant_id: getRandomInt(),
            blocked: getRandomInt() > 100 ? 1 : 0,
            vnc_port: getRandomInt(),
            ssh_port: getRandomInt(),
            serial_port: getRandomInt(),
            di_id: getRandomInt(),
            di_name: getRandomStr(),
            di_tag: getRandomStr(),
            di_version: getRandomStr(),
            host_id: getRandomInt(),
            host_name: getRandomStr(),
            osf_id: getRandomInt(),
            osf_name: getRandomStr(),
            user_id: getRandomInt(),
            user_name: getRandomStr(),
            user_state: getRandomInt() > 150 ? 'connected' : 'disconnected',
            storage: getRandomInt(),
            state: getRandomInt()> 50 ? 'started' : 'stopped',
            ip: getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt(),
            next_boot_ip: getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt(),
            expiration_hard: getRandomStr(),
            expiration_soft: getRandomStr(),
            properties: {
                'property 1': getRandomStr(),
                'property N': getRandomStr()
            }
        },
        host: {
            id: getRandomInt(),
            name: getRandomStr(),
            number_of_vms_connected: getRandomInt(),
            state: getRandomInt()> 50 ? 'started' : 'stopped',
            address: getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt() + '.' + getRandomInt(),
            blocked: getRandomInt() > 100 ? 1 : 0,
            properties: {
                'property 1': getRandomStr(),
                'property N': getRandomStr()
            }
        },
        osf: {
            id: getRandomInt(),
            name: getRandomStr(),
            tenant_name: getRandomStr(),
            tenant_id: getRandomInt(),
            memory: getRandomInt(),
            number_of_vms: getRandomInt(),
            number_of_dis: getRandomInt(),
            user_storage: getRandomInt(),
            overlay: getRandomInt() > 50 ? 1 : 0,
            properties: {
                'property 1': getRandomStr(),
                'property N': getRandomStr()
            }
        },
        di: {
            id: getRandomInt(),
            disk_image: 'fake.tgz',
            tenant_name: getRandomStr(),
            tenant_id: getRandomInt(),
            osf_name: getRandomStr(),
            osf_id: getRandomInt(),
            version: di_version,
            tags: [
                {
                    'fixed': 0,
                    'id': getRandomInt(),
                    'tag': 'default',
                    'di_id': getRandomInt()
                },
                {
                    'fixed': 0,
                    'id': getRandomInt(),
                    'tag': 'head',
                    'di_id': getRandomInt()
                },
                {
                    'fixed': 1,
                    'id': getRandomInt(),
                    'tag': di_version,
                    'di_id': getRandomInt()
                },
                {
                    'fixed': 0,
                    'id': getRandomInt(),
                    'tag': getRandomStr(),
                    'di_id': getRandomInt()
                },
                {
                    'fixed': 0,
                    'id': getRandomInt(),
                    'tag': getRandomStr(),
                    'di_id': getRandomInt()
                }
            ],
            properties: {
                'property 1': getRandomStr(),
                'property N': getRandomStr()
            }
        },
        tenant: {
            "id": getRandomInt(),
            "name": getRandomStr(),
            "language": "es",
            "block": getRandomInt()
        },
        admin: {
            "id": getRandomInt(),
            "name": getRandomStr(),
            "language": "en",
            "block": getRandomInt(),
            "tenant_id": null,
            "tenant_name": null,
            "roles": {}
        },
        role: {
            "name": getRandomStr(),
            "acls": {
                "positive": [],
                "negative": []
            },
            "roles": {}
        }
    };


// XML Output in jUnit style for jenkins integration
QUnit.jUnitReport = function(data) {
    console.log(data.xml);
};

QUnit.begin(function( details ) {
    
});