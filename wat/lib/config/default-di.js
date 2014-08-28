var shortName = 'di';

// Columns configuration on list view
Wat.I.listColumns[shortName] = {
    "checks": {
        "display": true,
        "fields": {
            
        },
        "text": "checks"
    },
    "info": {
        "display": true,
        "fields": {
            
        },
        "text": "info"
    },
    "id": {
        "display": true,
        "fields": {
            
        },
        "text": "id"
    },
    "disk_image": {
        "display": true,
        "fields": {
            
        },
        "text": "disk_image"
    },
    "version": {
        "display": true,
        "fields": {
            
        },
        "text": "version"
    },
    "osf": {
        "display": false,
        "fields": {
            
        },
        "text": "osf"
    },
    "default": {
        "display": true,
        "fields": {
            
        },
        "text": "default"
    }
};

// Filters configuration on list view
Wat.I.formFilters[shortName] = {
    'name': {
        'name': 'name',
        'filterField': 'disk_image',
        'type': 'text',
        'text': 'Search by disk image',
        'display': true,
        'device': 'both'
    },
    'osf': {
        'name': 'osf',
        'filterField': 'osf_id',
        'type': 'select',
        'text': 'OS Flavour',
        'class': 'chosen-advanced',
        'fillable': true,
        'display': true,
        'device': 'both'
    }
};

// Actions of the bottom of the list configuration on list view (those that will be done with selected items)
Wat.I.selectedActions[shortName] = [
            {
                'value': 'block',
                'text': 'Block'
            },           
            {
                'value': 'unblock',
                'text': 'Unblock'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[shortName] = {
            'name': 'new_di_button',
            'value': 'New Disk image',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[shortName], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[shortName]['next'] = {
            'screen': 'DI list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[shortName], Wat.I.listBreadCrumbs[shortName]);
Wat.I.detailsBreadCrumbs[shortName].next.link = '#/dis';
Wat.I.detailsBreadCrumbs[shortName].next.next = {
            'screen': '' // Will be filled dinamically
        };