Wat.C.aclGroups = {};

///////////////////////////////
// Administrator ACL groups
///////////////////////////////
Wat.C.aclGroups.administratorEdit = [
    'administrator.update.password',
    'administrator.update.language',
    'administrator.update.description'
];

Wat.C.aclGroups.administratorMassiveEdit = [
    'administrator.update-massive.description'
];

Wat.C.aclGroups.administratorMassiveActions = [
    'administrator.delete-massive.',
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.administratorMassiveActions, Wat.C.aclGroups.administratorMassiveEdit);


///////////////////////////////
// Roles ACL groups
///////////////////////////////
Wat.C.aclGroups.roleEdit = [
    'role.update.name',
    'role.update.description'
];

Wat.C.aclGroups.roleMassiveEdit = [
    'role.update-massive.description'
];

Wat.C.aclGroups.roleMassiveActions = [
    'role.delete-massive.',
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.roleMassiveActions, Wat.C.aclGroups.roleMassiveEdit);

///////////////////////////////
// Tenants ACL groups
///////////////////////////////
Wat.C.aclGroups.tenantEdit = [
    'tenant.update.name',
    'tenant.update.language',
    'tenant.update.description'
];

Wat.C.aclGroups.tenantMassiveEdit = [
    'tenant.update.description'
];

Wat.C.aclGroups.tenantMassiveActions = [
    'tenant.delete-massive.',
];

Wat.C.aclGroups.tenantDiEmbeddedInfo = [
    'tenant.see.di-list-default',
    'tenant.see.di-list-head',
    'tenant.see.di-list-tags',
    'tenant.see.di-list-block'
];

Wat.C.aclGroups.tenantVmEmbeddedInfo = [
    'tenant.see.vm-list-block',
    'tenant.see.vm-list-state',
    'tenant.see.vm-list-expiration',
    'tenant.see.vm-list-user-state'
];

Wat.C.aclGroups.tenantUserEmbeddedInfo = [
    'tenant.see.user-list-block'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.tenantMassiveActions, Wat.C.aclGroups.tenantMassiveEdit);

///////////////////////////////
// User ACL groups
///////////////////////////////
Wat.C.aclGroups.userEdit = [
    'user.update.password',
    'user.update.properties-create',
    'user.update.properties-update',
    'user.update.properties-delete',
    'user.update.description'
];

Wat.C.aclGroups.userInfo = [
    'user.see.block'
];

Wat.C.aclGroups.userMassiveEdit = [
    'user.update-massive.properties-create',
    'user.update-massive.properties-update',
    'user.update-massive.properties-delete',
    'role.update-massive.description'
];

Wat.C.aclGroups.userMassiveActions = [
    'user.delete-massive.',
    'user.update-massive.block',
    'vm.update-massive.disconnect-user'
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.userMassiveActions, Wat.C.aclGroups.userMassiveEdit);

Wat.C.aclGroups.userVmEmbeddedInfo = [
    'user.see.vm-list-block',
    'user.see.vm-list-state',
    'user.see.vm-list-expiration',
    'user.see.vm-list-user-state'
];

///////////////////////////////
// Virtual Machine ACL groups
///////////////////////////////
Wat.C.aclGroups.vmInfo = [
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
    'vm.update.properties-delete',
    'vm.update.description'
];

Wat.C.aclGroups.vmMassiveEdit = [
    'vm.update-massive.di-tag',
    'vm.update-massive.expiration',
    'vm.update-massive.properties-create',
    'vm.update-massive.properties-update',
    'vm.update-massive.properties-delete',
    'vm.update-massive.description'
];

Wat.C.aclGroups.vmMassiveActions = [
    'vm.delete-massive.',
    'vm.update-massive.block',
    'vm.update-massive.disconnect-user',
    'vm.update-massive.state'
];

Wat.C.aclGroups.vmRemoteAdminDetails = [
    'vm.see.host',
    'vm.see.next-boot-ip',
    'vm.see.port-ssh',
    'vm.see.port-vnc',
    'vm.see.port-serial'
];

Wat.C.aclGroups.vmStateInfoDetails = [
    'vm.see.host',
    'vm.see.ip',
    'vm.see.di',
    'vm.see.user-state',
    'vm.see.port-ssh',
    'vm.see.port-vnc',
    'vm.see.port-serial'
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
    'host.update.properties-delete',
    'host.update.description'
];

Wat.C.aclGroups.hostMassiveEdit = [
    'host.update-massive.properties-create',
    'host.update-massive.properties-update',
    'host.update-massive.properties-delete',
    'host.update-massive.description'
];

Wat.C.aclGroups.hostMassiveActions = [
    'host.delete-massive.',
    'host.update-massive.block'
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.hostMassiveActions, Wat.C.aclGroups.hostMassiveEdit);

Wat.C.aclGroups.hostVmEmbeddedInfo = [
    'host.see.vm-list-block',
    'host.see.vm-list-state',
    'host.see.vm-list-expiration',
    'host.see.vm-list-user-state'
];


///////////////////////////////
// OSF Flavours ACL groups
///////////////////////////////
Wat.C.aclGroups.osfEdit = [
    'osf.update.name',
    'osf.update.memory',
    'osf.update.user-storage',
    'osf.update.properties-create',
    'osf.update.properties-update',
    'osf.update.properties-delete',
    'osf.update.description'
];

Wat.C.aclGroups.osfMassiveEdit = [
    'osf.update-massive.memory',
    'osf.update-massive.user-storage',
    'osf.update-massive.properties-create',
    'osf.update-massive.properties-update',
    'osf.update-massive.properties-delete',
    'osf.update-massive.description'
];

Wat.C.aclGroups.osfMassiveActions = [
    'osf.delete-massive.'
];

Wat.C.aclGroups.osfDiEmbeddedInfo = [
    'osf.see.di-list-default',
    'osf.see.di-list-head',
    'osf.see.di-list-tags',
    'osf.see.di-list-block'
];

// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.osfMassiveActions, Wat.C.aclGroups.osfMassiveEdit);

Wat.C.aclGroups.osfVmEmbeddedInfo = [
    'osf.see.vm-list-block',
    'osf.see.vm-list-state',
    'osf.see.vm-list-expiration',
    'osf.see.vm-list-user-state'
];


///////////////////////////////
// Disk Image ACL groups
///////////////////////////////
Wat.C.aclGroups.diEdit = [
    'di.update.tags-create',
    'di.update.tags-delete',
    'di.update.properties-create',
    'di.update.properties-update',
    'di.update.properties-delete',
    'di.update.description'
];

Wat.C.aclGroups.diInfo = [
    'di.see.block',
    'di.see.tags'
];

Wat.C.aclGroups.diMassiveEdit = [
    'di.update-massive.tags-add',
    'di.update-massive.tags-delete',
    'di.update-massive.properties-create',
    'di.update-massive.properties-update',
    'di.update-massive.properties-delete',
    'di.update-massive.description'
];

Wat.C.aclGroups.diMassiveActions = [
    'di.delete-massive.',
    'di.update-massive.block'
];
// Massive actions include massive edit ACLs
$.merge(Wat.C.aclGroups.diMassiveActions, Wat.C.aclGroups.diMassiveEdit);

Wat.C.aclGroups.diVmEmbeddedInfo = [
    'di.see.vm-list-block',
    'di.see.vm-list-state',
    'di.see.vm-list-expiration',
    'di.see.vm-list-user-state',
];


///////////////////////////////
// Statistics
///////////////////////////////
Wat.C.aclGroups.statisticsSummaryObjects = [
    'user.stats.summary',
    'vm.stats.summary',
    'host.stats.summary',
    'osf.stats.summary',
    'di.stats.summary'
];

      
Wat.C.aclGroups.statisticsBlockedObjects = [
    'user.stats.blocked',
    'vm.stats.blocked',
    'host.stats.blocked',
    'di.stats.blocked'
];