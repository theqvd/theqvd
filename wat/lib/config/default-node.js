var shortName = 'node';

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
    "name": {
        "display": true,
        "fields": {

        },
        "text": "name"
    },
    "state": {
        "display": false,
        "fields": {

        },
        "text": "state"
    },
    "address": {
        "display": true,
        "fields": {

        },
        "text": "address"
    },
    "vms_connected": {
        "display": true,
        "fields": {

        },
        "text": "vms_connected"
    },
    "Cosa": {
        "display": true,
        "fields": {

        },
        "text": "Cosa"
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
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
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
                'value': 'stop_all',
                'text': 'Stop all VMs'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[shortName] = {
            'name': 'new_node_button',
            'value': 'New Node',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[shortName], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[shortName]['next'] = {
            'screen': 'Node list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[shortName], Wat.I.listBreadCrumbs[shortName]);
Wat.I.detailsBreadCrumbs[shortName].next.link = '#/nodes';
Wat.I.detailsBreadCrumbs[shortName].next.next = {
            'screen': '' // Will be filled dinamically
        };