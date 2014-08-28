var shortName = 'user';

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
    "started_vms": {
        "display": true,
        "fields": {

        },
        "text": "started_vms"
    },
    "world": {
        "display": true,
        "noTranslatable": true,
        "fields": {

        },
        "text": "world"
    },
    "sex": {
        "display": true,
        "noTranslatable": true,
        "fields": {

        },
        "text": "sex"
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
    'world': {
        'filterField': 'world',
        'type': 'text',
        'text': 'world',
        'noTranslatable': true,
        'display': true,
        'device': 'desktop'
    },     
    'sex': {
        'filterField': 'sex',
        'type': 'text',
        'text': 'sex',
        'noTranslatable': true,
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
                'value': 'disconnect_all',
                'text': 'Disconnect from all VMs'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[shortName] = {
            'name': 'new_user_button',
            'value': 'New User',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[shortName], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[shortName]['next'] = {
            'screen': 'User list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[shortName], Wat.I.listBreadCrumbs[shortName]);
Wat.I.detailsBreadCrumbs[shortName].next.link = '#/users';
Wat.I.detailsBreadCrumbs[shortName].next.next = {
            'screen': '' // Will be filled dinamically
        };