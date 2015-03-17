var qvdObj = 'role';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': 'role.delete-massive.',
        'fixed': true,
        'text': '',
        'sortable': false,
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'role.see.id',
        'text': 'Id',
        'sortable': true,
    },
    'name': {
        'display': true,
        'fields': [
            'id',
            'name'
        ],
        'text': 'Name',
        'fixed': true,
        'sortable': true,
    },
    'acls': {
        'display': false,
        'fields': [
            'number_of_acls',
            'acls'
        ],
        'acls': 'role.see.acl-list',
        'text': 'ACLs',
        'sortable': false,
    },
    'roles': {
        'display': true,
        'fields': [
            'roles'
        ],
        'acls': 'role.see.acl-list-roles',
        'text': 'Inherited roles',
        'sortable': false,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);
        
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

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'delete': {
        'text': 'Delete',
        'acls': 'role.delete-massive.'
    }
};

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
            'screen': 'WAT Management',
            'next': {
                'screen': 'Roles'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Roles',
                'link': '#/roles',
                'linkACL': 'role.see-main.',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };