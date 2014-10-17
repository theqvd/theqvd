Wat.C.aclGroups = {};

///////////////////////////////
// Administrator ACL groups
///////////////////////////////
Wat.C.aclGroups.administratorEdit = [
    'administrator.update.password'
];
Wat.C.aclGroups.administratorMassiveEdit = [];
Wat.C.aclGroups.administratorMassiveActions = [
    'administrator.delete-massive.',
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.administratorMassiveActions, Wat.C.aclGroups.administratorMassiveEdit);


///////////////////////////////
// Roles ACL groups
///////////////////////////////
Wat.C.aclGroups.roleEdit = [
    'role.update.name'
];
Wat.C.aclGroups.roleMassiveEdit = [];
Wat.C.aclGroups.roleMassiveActions = [
    'role.delete-massive.',
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.roleMassiveActions, Wat.C.aclGroups.roleMassiveEdit);

///////////////////////////////
// User ACL groups
///////////////////////////////
Wat.C.aclGroups.userEdit = [
    'user.update.password',
    'user.update.properties-create',
    'user.update.properties-update',
    'user.update.properties-delete'
];
Wat.C.aclGroups.userMassiveEdit = [
    'user.update-massive.properties-create',
    'user.update-massive.properties-update',
    'user.update-massive.properties-delete'
];
Wat.C.aclGroups.userMassiveActions = [
    'user.delete-massive.',
    'user.update-massive.block',
    'vm.update-massive.disconnect-user'
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.userMassiveActions, Wat.C.aclGroups.userMassiveEdit);


///////////////////////////////
// Virtual Machine ACL groups
///////////////////////////////
Wat.C.aclGroups.vmInfoIcons = [
    'vm.see.block',
    'vm.see.state',
    'vm.see.expiration',
    'vm.see.user-state'
];
Wat.C.aclGroups.vmEdit = [
    'vm.update.name',
    'vm.update.di-tag',
    'vm.update.expiration',
    'vm.update.properties-create',
    'vm.update.properties-update',
    'vm.update.properties-delete'
];
Wat.C.aclGroups.vmMassiveEdit = [
    'vm.update-massive.di-tag',
    'vm.update-massive.expiration',
    'vm.update-massive.properties-create',
    'vm.update-massive.properties-update',
    'vm.update-massive.properties-delete'
];
Wat.C.aclGroups.vmMassiveActions = [
    'vm.delete-massive.',
    'vm.update-massive.block',
    'vm.update-massive.disconnect-user',
    'vm.update-massive.state'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.vmMassiveActions, Wat.C.aclGroups.vmMassiveEdit);


///////////////////////////////
// Hosts ACL groups
///////////////////////////////
Wat.C.aclGroups.hostEdit = [
    'host.update.name',
    'host.update.address',
    'host.update.properties-create',
    'host.update.properties-update',
    'host.update.properties-delete'
];
Wat.C.aclGroups.hostMassiveEdit = [
    'host.update-massive.properties-create',
    'host.update-massive.properties-update',
    'host.update-massive.properties-delete'
];
Wat.C.aclGroups.hostMassiveActions = [
    'host.delete-massive.',
    'host.update-massive.block'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.hostMassiveActions, Wat.C.aclGroups.hostMassiveEdit);


///////////////////////////////
// OSF Flavours ACL groups
///////////////////////////////
Wat.C.aclGroups.osfEdit = [
    'osf.update.name',
    'osf.update.memory',
    'osf.update.user-storage',
    'osf.update.properties-create',
    'osf.update.properties-update',
    'osf.update.properties-delete'
];
Wat.C.aclGroups.osfMassiveEdit = [
    'osf.update-massive.memory',
    'osf.update-massive.user-storage',
    'osf.update-massive.properties-create',
    'osf.update-massive.properties-update',
    'osf.update-massive.properties-delete'
];
Wat.C.aclGroups.osfMassiveActions = [
    'vm.delete-massive.'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.osfMassiveActions, Wat.C.aclGroups.osfMassiveEdit);


///////////////////////////////
// Disk Image ACL groups
///////////////////////////////
Wat.C.aclGroups.diEdit = [
    'di.update.tags-create',
    'di.update.tags-delete',
    'di.update.properties-create',
    'di.update.properties-update',
    'di.update.properties-delete'
];
Wat.C.aclGroups.diMassiveEdit = [
    'di.update-massive.tags-add',
    'di.update-massive.tags-delete',
    'di.update-massive.properties-create',
    'di.update-massive.properties-update',
    'di.update-massive.properties-delete'
];
Wat.C.aclGroups.diMassiveActions = [
    'di.delete-massive.',
    'di.update-massive.block'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.diMassiveActions, Wat.C.aclGroups.diMassiveEdit);
                                              
                                              