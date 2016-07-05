Up.C.aclGroups = {};

///////////////////////////////
// Administrator ACL groups
///////////////////////////////
Up.C.aclGroups.administratorEdit = [
    'administrator.update.password',
    'administrator.update.language',
    'administrator.update.description'
];

Up.C.aclGroups.administratorMassiveEdit = [
    'administrator.update-massive.description'
];

Up.C.aclGroups.administratorMassiveActions = [
    'administrator.delete-massive.',
];
// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.administratorMassiveActions, Up.C.aclGroups.administratorMassiveEdit);


///////////////////////////////
// Roles ACL groups
///////////////////////////////
Up.C.aclGroups.roleEdit = [
    'role.update.name',
    'role.update.description'
];

Up.C.aclGroups.roleMassiveEdit = [
    'role.update-massive.description'
];

Up.C.aclGroups.roleMassiveActions = [
    'role.delete-massive.',
];
// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.roleMassiveActions, Up.C.aclGroups.roleMassiveEdit);

///////////////////////////////
// Tenants ACL groups
///////////////////////////////
Up.C.aclGroups.tenantEdit = [
    'tenant.update.name',
    'tenant.update.language',
    'tenant.update.description'
];

Up.C.aclGroups.tenantMassiveEdit = [
    'tenant.update.description'
];

Up.C.aclGroups.tenantMassiveActions = [
    'tenant.delete-massive.',
];

Up.C.aclGroups.tenantDiEmbeddedInfo = [
    'tenant.see.di-list-default',
    'tenant.see.di-list-head',
    'tenant.see.di-list-tags',
    'tenant.see.di-list-block'
];

Up.C.aclGroups.tenantVmEmbeddedInfo = [
    'tenant.see.vm-list-block',
    'tenant.see.vm-list-state',
    'tenant.see.vm-list-expiration',
    'tenant.see.vm-list-user-state'
];

Up.C.aclGroups.tenantUserEmbeddedInfo = [
    'tenant.see.user-list-block'
];

// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.tenantMassiveActions, Up.C.aclGroups.tenantMassiveEdit);

///////////////////////////////
// User ACL groups
///////////////////////////////
Up.C.aclGroups.userEdit = [
    'user.update.password',
    'user.update.properties',
    'user.update.description'
];

Up.C.aclGroups.userInfo = [
    'user.see.block'
];

Up.C.aclGroups.userMassiveEdit = [
    'user.update-massive.properties',
    'role.update-massive.description'
];

Up.C.aclGroups.userMassiveActions = [
    'user.delete-massive.',
    'user.update-massive.block',
    'vm.update-massive.disconnect-user'
];
// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.userMassiveActions, Up.C.aclGroups.userMassiveEdit);

Up.C.aclGroups.userVmEmbeddedInfo = [
    'user.see.vm-list-block',
    'user.see.vm-list-state',
    'user.see.vm-list-expiration',
    'user.see.vm-list-user-state'
];

///////////////////////////////
// Virtual Machine ACL groups
///////////////////////////////
Up.C.aclGroups.vmInfo = [
    'vm.see.block',
    'vm.see.state',
    'vm.see.expiration',
    'vm.see.user-state'
];

Up.C.aclGroups.vmEdit = [
    'vm.update.name',
    'vm.update.di-tag',
    'vm.update.expiration',
    'vm.update.properties',
    'vm.update.description'
];

Up.C.aclGroups.vmMassiveEdit = [
    'vm.update-massive.di-tag',
    'vm.update-massive.expiration',
    'vm.update-massive.properties',
    'vm.update-massive.description'
];

Up.C.aclGroups.vmMassiveActions = [
    'vm.delete-massive.',
    'vm.update-massive.block',
    'vm.update-massive.disconnect-user',
    'vm.update-massive.state'
];

Up.C.aclGroups.vmRemoteAdminDetails = [
    'vm.see.host',
    'vm.see.next-boot-ip',
    'vm.see.port-ssh',
    'vm.see.port-vnc',
    'vm.see.port-serial'
];

Up.C.aclGroups.vmStateInfoDetails = [
    'vm.see.host',
    'vm.see.ip',
    'vm.see.di',
    'vm.see.user-state',
    'vm.see.port-ssh',
    'vm.see.port-vnc',
    'vm.see.port-serial'
];

// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.vmMassiveActions, Up.C.aclGroups.vmMassiveEdit);


///////////////////////////////
// Hosts ACL groups
///////////////////////////////
Up.C.aclGroups.hostEdit = [
    'host.update.name',
    'host.update.address',
    'host.update.properties',
    'host.update.description'
];

Up.C.aclGroups.hostMassiveEdit = [
    'host.update-massive.properties',
    'host.update-massive.description'
];

Up.C.aclGroups.hostMassiveActions = [
    'host.delete-massive.',
    'host.update-massive.block'
];
// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.hostMassiveActions, Up.C.aclGroups.hostMassiveEdit);

Up.C.aclGroups.hostVmEmbeddedInfo = [
    'host.see.vm-list-block',
    'host.see.vm-list-state',
    'host.see.vm-list-expiration',
    'host.see.vm-list-user-state'
];


///////////////////////////////
// OSF Flavours ACL groups
///////////////////////////////
Up.C.aclGroups.osfEdit = [
    'osf.update.name',
    'osf.update.memory',
    'osf.update.user-storage',
    'osf.update.properties',
    'osf.update.description'
];

Up.C.aclGroups.osfMassiveEdit = [
    'osf.update-massive.memory',
    'osf.update-massive.user-storage',
    'osf.update-massive.properties',
    'osf.update-massive.description'
];

Up.C.aclGroups.osfMassiveActions = [
    'osf.delete-massive.'
];

Up.C.aclGroups.osfDiEmbeddedInfo = [
    'osf.see.di-list-default',
    'osf.see.di-list-head',
    'osf.see.di-list-tags',
    'osf.see.di-list-block'
];

// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.osfMassiveActions, Up.C.aclGroups.osfMassiveEdit);

Up.C.aclGroups.osfVmEmbeddedInfo = [
    'osf.see.vm-list-block',
    'osf.see.vm-list-state',
    'osf.see.vm-list-expiration',
    'osf.see.vm-list-user-state'
];


///////////////////////////////
// Disk Image ACL groups
///////////////////////////////
Up.C.aclGroups.diEdit = [
    'di.update.tags-create',
    'di.update.tags-delete',
    'di.update.properties',
    'di.update.description'
];

Up.C.aclGroups.diInfo = [
    'di.see.block',
    'di.see.tags'
];

Up.C.aclGroups.diMassiveEdit = [
    'di.update-massive.tags-add',
    'di.update-massive.tags-delete',
    'di.update-massive.properties',
    'di.update-massive.description'
];

Up.C.aclGroups.diMassiveActions = [
    'di.delete-massive.',
    'di.update-massive.block'
];
// Massive actions include massive edit ACLs
$.merge(Up.C.aclGroups.diMassiveActions, Up.C.aclGroups.diMassiveEdit);

Up.C.aclGroups.diVmEmbeddedInfo = [
    'di.see.vm-list-block',
    'di.see.vm-list-state',
    'di.see.vm-list-expiration',
    'di.see.vm-list-user-state',
];

///////////////////////////////
// Tenant ACL groups
///////////////////////////////

Up.C.aclGroups.tenantInfo = [
    'tenant.see.block'
];

///////////////////////////////
// Statistics
///////////////////////////////
Up.C.aclGroups.statisticsSummaryObjects = [
    'user.stats.summary',
    'vm.stats.summary',
    'host.stats.summary',
    'osf.stats.summary',
    'di.stats.summary'
];

      
Up.C.aclGroups.statisticsBlockedObjects = [
    'user.stats.blocked',
    'vm.stats.blocked',
    'host.stats.blocked',
    'di.stats.blocked'
];

///////////////////////////////
// Properties
///////////////////////////////
Up.C.aclGroups.propertiesManagement = [
    'property.manage.user',
    'property.manage.vm',
    'property.manage.host',
    'property.manage.osf',
    'property.manage.di'
];
