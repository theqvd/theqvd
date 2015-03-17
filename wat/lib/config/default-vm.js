var qvdObj = 'vm';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'text': 'checks',
        'fields': [],
        'groupAcls': 'vmMassiveActions',
        'aclsLogic': 'OR',
        'display': true,
        'fixed': true,
        'sortable': false,
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
        'groupAcls': 'vmInfo',
        'aclsLogic': 'OR',
        'display': true,
        'sortable': false,
    },
    'id': {
        'text': 'Id',
        'fields': [
            'id'
        ],
        'acls': 'vm.see.id',
        'display': false,
        'sortable': true,
    },
    'name': {
        'text': 'Name',
        'fields': [
            'id',
            'name'
        ],
        'display': true,
        'fixed': true,
        'sortable': true,
    },
    'host': {
        'text': 'Node',
        'fields': [
            'host_id',
            'host_name'
        ],
        'acls': 'vm.see.host',
        'display': true,
        'sortable': true,
    },
    'user': {
        'text': 'User',
        'fields': [
            'user_id',
            'user_name'
        ],
        'acls': 'vm.see.user',
        'display': true,
        'sortable': true,
    },
    'osf': {
        'text': 'OS Flavour',
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'vm.see.osf',
        'display': false,
        'sortable': true,
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
            'vm.see.osf',
            'vm.see.di-tag'
        ],
        'aclsLogic': 'AND',
        'display': true,
        'sortable': true,
    },
    'tag': {
        'text': 'Tag',
        'fields': [
            'di_tag'
        ],
        'acls': 'vm.see.di-tag',
        'display': false,
        'sortable': true,
    },
    'di_version': {
        'text': 'DI version',
        'fields': [
            'di_version'
        ],
        'acls': 'vm.see.di-version',
        'display': false,
        'sortable': true,
    },
    'di_name': {
        'text': 'Disk image',
        'fields': [
            'di_name',
            'di_id'
        ],
        'acls': 'vm.see.di',
        'display': false,
        'sortable': true,
    },
    'ip': {
        'text': 'IP address',
        'fields': [
            'ip'
        ],
        'acls': 'vm.see.ip',
        'display': false,
        'sortable': true,
    },
    'next_boot_ip': {
        'text': 'Next boot IP',
        'fields': [
            'next_boot_ip'
        ],
        'acls': 'vm.see.next-boot-ip',
        'display': false,
        'sortable': true,
    },
    'mac': {
        'text': 'MAC address',
        'fields': [
            'mac'
        ],
        'acls': 'vm.see.mac',
        'display': false,
        'sortable': false,
    },
    'serial_port': {
        'text': 'Serial port',
        'fields': [
            'serial_port'
        ],
        'acls': 'vm.see.port-serial',
        'display': false,
        'sortable': true,
    },
    'ssh_port': {
        'text': 'SSH port',
        'fields': [
            'ssh_port'
        ],
        'acls': 'vm.see.port-ssh',
        'display': false,
        'sortable': true,
    },
    'vnc_port': {
        'text': 'VNC port',
        'fields': [
            'vnc_port'
        ],
        'acls': 'vm.see.port-vnc',
        'display': false,
        'sortable': true,
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'vm.see.creation-date',
        'display': false,
        'sortable': false,
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'vm.see.created-by',
        'display': false,
        'sortable': false,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

// Fields configuration on details view
Wat.I.detailsFields[qvdObj] = {
    'id': {
        'text': 'Id',
        'fields': [
            'id'
        ],
        'acls': 'vm.see.id',
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
    'block': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'vm.see.block',
        'text': 'Blocking'
    },
    'host': {
        'text': 'Node',
        'fields': [
            'host_id',
            'host_name'
        ],
        'acls': 'vm.see.host',
        'display': true
    },
    'user': {
        'text': 'User',
        'fields': [
            'user_id',
            'user_name'
        ],
        'acls': 'vm.see.user',
        'display': true
    },
    'user_state': {
        'text': 'User state',
        'fields': [
            'user_state'
        ],
        'acls': 'vm.see.user-state',
        'display': true
    },
    'state': {
        'text': 'State',
        'fields': [
            'state'
        ],
        'acls': 'vm.see.state',
        'display': true
    },
    'osf': {
        'text': 'OS Flavour',
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'vm.see.osf',
        'display': false
    },
    'tag': {
        'text': 'Tag',
        'fields': [
            'di_tag'
        ],
        'acls': 'vm.see.di-tag',
        'display': false
    },
    'di_version': {
        'text': 'DI version',
        'fields': [
            'di_version'
        ],
        'acls': 'vm.see.di-version',
        'display': false
    },
    'disk_image': {
        'text': 'Disk image',
        'fields': [
            'di_name',
            'di_id'
        ],
        'acls': 'vm.see.di',
        'display': false
    },
    'expiration': {
        'text': 'Info',
        'fields': [
            'expiration_soft',
            'expiration_hard'
        ],
        'acls': 'vm.see.expiration',
        'display': true
    },
    'ip': {
        'text': 'IP address',
        'fields': [
            'ip'
        ],
        'acls': 'vm.see.ip',
        'display': false
    },
    'next_boot_ip': {
        'text': 'Next boot IP',
        'fields': [
            'next_boot_ip'
        ],
        'acls': 'vm.see.next-boot-ip',
        'display': false
    },
    'mac': {
        'text': 'MAC address',
        'fields': [
            'mac'
        ],
        'acls': 'vm.see.mac',
        'display': true
    },
    'serial_port': {
        'text': 'Serial port',
        'fields': [
            'serial_port'
        ],
        'acls': 'vm.see.port-serial',
        'display': false
    },
    'ssh_port': {
        'text': 'SSH port',
        'fields': [
            'ssh_port'
        ],
        'acls': 'vm.see.port-ssh',
        'display': false
    },
    'vnc_port': {
        'text': 'VNC port',
        'fields': [
            'vnc_port'
        ],
        'acls': 'vm.see.port-vnc',
        'display': false
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'vm.see.creation-date',
        'display': true
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'vm.see.created-by',
        'display': true
    }
};

Wat.I.detailsDefaultFields[qvdObj] = $.extend({}, Wat.I.detailsFields[qvdObj]);

// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'filterField': 'name',
        'type': 'text',
        'text': 'Search by name',
        'displayMobile': true,
        'displayDesktop': true,
        'acls': 'vm.filter.name'
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
        'acls': 'vm.filter.state'
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
        'acls': 'vm.filter.user'
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
        'acls': 'vm.filter.osf'
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
        'acls': 'vm.filter.host'
    },
    'blocked': {
        'filterField': 'blocked',
        'type': 'select',
        'text': 'Blocking',
        'class': 'chosen-single',
        'fillable': false,
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            },
            {
                'value': 1,
                'text': 'Blocked'
            },
            {
                'value': 0,
                'text': 'Unblocked'
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'vm.filter.block'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'start': {
        'text': 'Start',
        'acls': 'vm.update-massive.state'
    },
    'stop': {
        'text': 'Stop',
        'acls': 'vm.update-massive.state'
    },
    'block': {
        'text': 'Block',
        'acls': 'vm.update-massive.block'
    },
    'unblock': {
        'text': 'Unblock',
        'acls': 'vm.update-massive.block'
    },
    'disconnect': {
        'text': 'Disconnect user',
        'acls': 'vm.update-massive.disconnect-user'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'vm.delete-massive.'
    },
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'vmMassiveEdit',
        'aclsLogic': 'OR'
    }
};

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

