var qvdObj = 'osf';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'fixed': true
    },
    'id': {
        'display': true,
        'fields': [
            'id'
        ],
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
    'overlay': {
        'display': true,
        'fields': [
            'overlay'
        ],
        'text': 'Overlay'
    },
    'memory': {
        'display': true,
        'fields': [
            'memory'
        ],
        'text': 'Memory'
    },
    'user_storage': {
        'display': true,
        'fields': [
            'user_storage'
        ],
        'text': 'User storage'
    },
    'dis': {
        'display': true,
        'fields': [
            'id',
            'dis'
        ],
        'text': 'DIs'
    },
    'vms': {
        'display': true,
        'fields': [
            'id',
            'vms'
        ],
        'text': 'VMs'
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
        'displayDesktop': true
    },
    'di': {
        'filterField': 'di_id',
        'type': 'select',
        'text': 'Disk image',
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
                'value': 'delete',
                'text': 'Delete'
            },
            {
                'value': 'massive_changes',
                'text': 'Massive changes'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_osf_button',
            'value': 'New OS Flavour',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'OSF list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/osfs';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };