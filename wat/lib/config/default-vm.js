var qvdObj = 'vm';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'text': 'checks',
        'fields': [],
        'groupAcls': 'vmMassiveActions',
        'aclsLogic': 'OR',
        'display': true,
        'fixed': true
    },
    'info': {
        'text': 'Info',
        'fields': [
            'block',
            'state',
            'expiration_soft',
            'expiration_hard',
            'user_state'
        ],
        'groupAcls': 'vmInfoIcons',
        'aclsLogic': 'OR',
        'display': true
    },
    'id': {
        'text': 'Id',
        'fields': [
            'id'
        ],
        'acls': 'vm.see-main.id',
        'display': false,
    },
    'name': {
        'text': 'Name',
        'fields': [
            'id',
            'name'
        ],
        'display': true
    },
    'host': {
        'text': 'Node',
        'fields': [
            'host_id',
            'host_name'
        ],
        'acls': 'vm.see-main.host',
        'display': true
    },
    'user': {
        'text': 'User',
        'fields': [
            'user_id',
            'user_name'
        ],
        'acls': 'vm.see-main.user',
        'display': true
    },
    'osf': {
        'text': 'OS Flavour',
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'vm.see-main.osf',
        'display': false
    },
    'osf\/tag': {
        'text': 'OSF / Tag',
        'fields': [
            'osf_id',
            'osf_name',
            'di_tag',
            'di_id'
        ],
        'acls': [
            'vm.see-main.osf',
            'vm.see-main.osf-tag'
        ],
        'aclsLogic': 'AND',
        'display': true
    },
    'tag': {
        'text': 'Tag',
        'fields': [
            'di_tag'
        ],
        'acls': 'vm.see-main.osf-tag',
        'display': false
    },
    'di_version': {
        'text': 'DI version',
        'fields': [
            'di_version'
        ],
        'acls': 'vm.see-main.di-version',
        'display': false
    },
    'disk_image': {
        'text': 'Disk image',
        'fields': [
            'di_name',
            'di_id'
        ],
        'acls': 'vm.see-main.di',
        'display': false
    },
    'ip': {
        'text': 'IP address',
        'fields': [
            'ip'
        ],
        'acls': 'vm.see-main.ip',
        'display': false
    },
    'next_boot_ip': {
        'text': 'Next boot IP',
        'fields': [
            'next_boot_ip'
        ],
        'acls': 'vm.see-main.next-boot-ip',
        'display': false
    },
    'serial_port': {
        'text': 'Serial port',
        'fields': [
            'serial_port'
        ],
        'acls': 'vm.see-main.port-serial',
        'display': false
    },
    'ssh_port': {
        'text': 'SSH port',
        'fields': [
            'ssh_port'
        ],
        'acls': 'vm.see-main.port-ssh',
        'display': false
    },
    'vnc_port': {
        'text': 'VNC port',
        'fields': [
            'vnc_port'
        ],
        'acls': 'vm.see-main.port-vnc',
        'display': false
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'vm.see-main.creation-date',
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'vm.see-main.created-by',
        'display': false
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
    'state': {
        'filterField': 'state',
        'type': 'select',
        'text': 'State',
        'class': 'chosen-single',
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            },
            {
                'value': 'running',
                'text': 'Running',
                'selected': false
            },
            {
                'value': 'stopped',
                'text': 'Stopped',
                'selected': false
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'vm.see-main.state'
    },
    'user': {
        'filterField': 'user_id',
        'type': 'select',
        'text': 'User',
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
        'acls': 'vm.see-main.user'
    },
    'osf': {
        'filterField': 'osf_id',
        'type': 'select',
        'text': 'OS Flavour',
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
        'acls': 'vm.see-main.osf'
    },
    'host': {
        'filterField': 'host_id',
        'type': 'select',
        'text': 'Node',
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
        'acls': 'vm.see-main.host'
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = [
            {
                'value': 'start',
                'text': 'Start',
                'acls': 'vm.update-massive.state'
            },
            {
                'value': 'stop',
                'text': 'Stop',
                'acls': 'vm.update-massive.state'
            },
            {
                'value': 'block',
                'text': 'Block',
                'acls': 'vm.update-massive.block'
            },
            {
                'value': 'unblock',
                'text': 'Unblock',
                'acls': 'vm.update-massive.block'
            },
            {
                'value': 'disconnect',
                'text': 'Disconnect user',
                'acls': 'vm.update-massive.disconnect-user'
            },
            {
                'value': 'delete',
                'text': 'Delete',
                'acls': 'vm.delete-massive.'
            },
            {
                'value': 'massive_changes',
                'text': 'Edit',
                'groupAcls': 'vmMassiveEdit',
                'aclsLogic': 'OR'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_vm_button',
            'value': 'New Virtual machine',
            'link': 'javascript:',
            'acl': 'vm.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);

Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'Virtual machine list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/vms';
Wat.I.detailsBreadCrumbs[qvdObj].next.linkACL = 'vm.see-main.';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };

