var qvdObj = 'admin';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'fixed': true,
        'text': '',
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
    'tenant': {
        'display': true,
        'fields': [
            'tenant_id',
            'tenant_name'
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
                'text': 'Delete'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_admin_button',
            'value': 'New Administrator',
            'link': 'javascript:'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Administrators'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Administrators',
                'link': '#/setup/admins',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };