var qvdObj = 'user';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'fixed': true,
        'text': '',
        'fixed': true
    },
    'info': {
        'display': true,
        'fields': [
            'blocked'
        ],
        'text': 'Info'
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
    'connected_vms': {
        'display': true,
        'fields': [
            'id',
            'vms',
            'vms_connected'
        ],
        'text': 'Connected VMs'
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
    },
    'world': {
        'display': true,
        'noTranslatable': true,
        'fields': [
            'world'
        ],
        'property': true,
        'text': 'world'
    },
    'sex': {
        'display': true,
        'noTranslatable': true,
        'fields': [
            'sex'
        ],
        'property': true,
        'text': 'sex'
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
    'world': {
        'filterField': 'world',
        'type': 'text',
        'text': 'world',
        'noTranslatable': true,
        'displayMobile': false,
        'displayDesktop': true,
        'property': true
    },     
    'sex': {
        'filterField': 'sex',
        'type': 'text',
        'text': 'sex',
        'noTranslatable': true,
        'displayMobile': false,
        'displayDesktop': true,
        'property': true
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = [
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
            },
            {
                'value': 'massive_changes',
                'text': 'Massive changes'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_user_button',
            'value': 'New User',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'User list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/users';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };