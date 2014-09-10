var qvdObj = 'vm';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'text': 'checks',
        'fields': [],
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
        'display': true
    },
    'id': {
        'text': 'Id',
        'fields': [
            'id'
        ],
        'display': true
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
        'display': true
    },
    'user': {
        'text': 'User',
        'fields': [
            'user_id',
            'user_name'
        ],
        'display': true
    },
    'osf': {
        'text': 'OS Flavour',
        'fields': [
            'osf_id',
            'osf_name'
        ],
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
        'display': true
    },
    'tag': {
        'text': 'Tag',
        'fields': [
            'di_tag'
        ],
        'display': false
    },
    'di_version': {
        'text': 'DI version',
        'fields': [
            'di_version'
        ],
        'display': false
    },
    'disk_image': {
        'text': 'Disk image',
        'fields': [
            'di_name',
            'di_id'
        ],
        'display': false
    },
    'ip': {
        'text': 'IP address',
        'fields': [
            'ip'
        ],
        'display': false
    },
    'next_boot_ip': {
        'text': 'Next boot IP',
        'fields': [
            'next_boot_ip'
        ],
        'display': false
    },
    'serial_port': {
        'text': 'Serial port',
        'fields': [
            'serial_port'
        ],
        'display': false
    },
    'ssh_port': {
        'text': 'SSH port',
        'fields': [
            'ssh_port'
        ],
        'display': false
    },
    'vnc_port': {
        'text': 'VNC port',
        'fields': [
            'vnc_port'
        ],
        'display': false
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
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
        'displayDesktop': true
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
        'displayDesktop': true
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
        'displayDesktop': true
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
        'displayDesktop': true
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = [
            {
                'value': 'start',
                'text': 'Start'
            },
            {
                'value': 'stop',
                'text': 'Stop'
            },
            {
                'value': 'block',
                'text': 'Block'
            },
            {
                'value': 'unblock',
                'text': 'Unblock'
            },
            {
                'value': 'disconnect',
                'text': 'Disconnect user'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_vm_button',
            'value': 'New Virtual machine',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'Virtual machine list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/vms';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };

