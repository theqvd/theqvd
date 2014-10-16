var qvdObj = 'host';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': [
            'host.delete-massive.',
            'host.update-massive.block',
            'host.update-massive.stop-vms',
            'host.update-massive.properties-create',
            'host.update-massive.properties-update',
            'host.update-massive.properties-delete'
        ],
        'aclsLogic': 'OR',
        'fixed': true
    },
    'info': {
        'display': true,
        'fields': [
            'state',
            'blocked'
        ],
        'acls': [
            'host.see-main.block',
            'host.see-main.state'
        ],
        'aclsLogic': 'OR',
        'text': 'Info'
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'host.see-main.id',
        'text': 'Id'
    },
    'name': {
        'display': true,
        'fields': [
            'id',
            'name'
        ],
        'text': 'Name'
    },
    'state': {
        'display': false,
        'fields': [
            'state'
        ],
        'acls': 'host.see-main.state',
        'text': 'State'
    },
    'address': {
        'display': true,
        'fields': [
            'address'
        ],
        'acls': 'host.see-main.address',
        'text': 'IP address'
    },
    'vms_connected': {
        'display': true,
        'fields': [
            'id',
            'vms_connected'
        ],
        'acls': 'host.see-main.vms-info',
        'text': 'Running VMs'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'host.see-main.creation-date',
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'host.see-main.created-by',
        'display': false
    },
    'Cosa': {
        'display': true,
        'fields': [
            'Cosa'
        ],
        'acls': 'host.see-main.properties',
        'property': true,
        'text': 'Cosa'
    }
};

// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'filterField': 'name',
        'type': 'text',
        'text': 'Search by name',
        'displayMobile': true,
        'displayDesktop': true
    },
    'vm': {
        'filterField': 'vm_id',
        'type': 'select',
        'text': 'Virtual machine',
        'class': 'chosen-advanced',
        'fillable': true,
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'host.see-main.vms-info'
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'block': {
        'text': 'Block',
        'acls': 'host.update-massive.block'
    },
    'unblock': {
        'text': 'Unblock',
        'acls': 'host.update-massive.block'
    },
    'stop_all': {
        'text': 'Stop all VMs',
        'acls': 'vm.update-massive.state'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'host.delete-massive.'
    },
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'hostMassiveEdit',
        'aclsLogic': 'OR'
    }
};

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_host_button',
            'value': 'New Node',
            'link': 'javascript:',
            'acl': 'host.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'Node list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/hosts';
Wat.I.detailsBreadCrumbs[qvdObj].next.linkACL = 'host.see-main.';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };