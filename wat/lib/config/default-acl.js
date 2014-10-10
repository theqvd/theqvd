var qvdObj = 'acl';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'fixed': true,
        'text': 'checks'
    },
    'info': {
        'display': true,
        'fields': [
            'blocked',
            'tags'
        ],
        'text': 'Info'
    },
    'id': {
        'display': false,
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
    'roles': {
        'display': true,
        'fields': [
            'roles'
        ],
        'text': 'Roles'
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
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = [
            {
                'value': 'disable',
                'text': 'Disable'
            },
            {
                'value': 'enable',
                'text': 'Enable'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_role_button',
            'value': 'New Role',
            'link': 'javascript:',
            'acl': 'role_create'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Roles'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Roles',
                'link': '#/setup/roles',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };