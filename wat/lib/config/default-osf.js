var shortName = 'osf';

// Columns configuration on list view
Wat.I.listColumns[shortName] = {
    "checks": {
        "display": true,
        "fields": {
            
        },
        "text": "checks"
    },
    "id": {
        "display": true,
        "fields": {
            
        },
        "text": "id"
    },
    "name": {
        "display": true,
        "fields": {
            
        },
        "text": "name"
    },
    "overlay": {
        "display": true,
        "fields": {
            
        },
        "text": "overlay"
    },
    "memory": {
        "display": true,
        "fields": {
            
        },
        "text": "memory"
    },
    "user_storage": {
        "display": true,
        "fields": {
            
        },
        "text": "user_storage"
    },
    "dis": {
        "display": true,
        "fields": {
            
        },
        "text": "dis"
    },
    "vms": {
        "display": true,
        "fields": {
            
        },
        "text": "vms"
    }
};

// Filters configuration on list view
Wat.I.formFilters[shortName] = {
    'name': {
        'filterField': 'name',
        'type': 'text',
        'text': 'Search by name',
        'display': true,
        'device': 'both'
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
        'display': true,
        'device': 'desktop'
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
        'display': true,
        'device': 'desktop'
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[shortName] = [
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[shortName] = {
            'name': 'new_osf_button',
            'value': 'New OS Flavour',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[shortName], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[shortName]['next'] = {
            'screen': 'OSF list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[shortName], Wat.I.listBreadCrumbs[shortName]);
Wat.I.detailsBreadCrumbs[shortName].next.link = '#/osfs';
Wat.I.detailsBreadCrumbs[shortName].next.next = {
            'screen': '' // Will be filled dinamically
        };