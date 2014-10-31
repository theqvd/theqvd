var qvdObj = 'acl';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
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
        'text': 'Name',
        'fixed': true
    },
    'roles': {
        'display': true,
        'fields': [
            'roles'
        ],
        'text': 'Roles'
    },
    'name_roles': {
        'display': true,
        'fields': [
            'id',
            'name',
            'roles'
        ],
        'text': 'Roles'
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

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'delete_acl': {
        'text': 'Delete',
    }
};