var qvdObj = 'role';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': 'role.delete-massive.',
        'fixed': true,
        'text': ''
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'role.see-main.id',
        'text': 'Id'
    },
    'name': {
        'display': true,
        'fields': [
            'id',
            'name'
        ],
        'text': 'Name'
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
                'value': 'delete',
                'text': 'Delete',
                'acls': 'role.delete-massive.'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_role_button',
            'value': 'New Role',
            'link': 'javascript:',
            'acl': 'role.create.'
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
                'linkACL': 'role.see-main.',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };