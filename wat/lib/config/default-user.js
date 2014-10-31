var qvdObj = 'user';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'fixed': true,
        'groupAcls': 'userMassiveActions',
        'aclsLogic': 'OR',
        'text': '',
        'fixed': true
    },
    'info': {
        'display': true,
        'fields': [
            'blocked'
        ],
        'acls': 'user.see.block',
        'text': 'Info'
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'user.see.id',
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
            'number_of_vms',
            'number_of_vms_connected'
        ],
        'acls': 'user.see.vms-info',
        'text': 'Connected VMs'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'user.see.creation-date',
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'user.see.created-by',
        'display': false
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

// Fields configuration on details view
Wat.I.detailsFields[qvdObj] = {
    'id': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'user.see.id',
        'text': 'Id'
    },
    'block': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'user.see.block',
        'text': 'Blocking'
    },
    'connected_vms': {
        'display': true,
        'fields': [
            'id',
            'number_of_vms',
            'number_of_vms_connected'
        ],
        'acls': 'user.see.vms-info',
        'text': 'Connected VMs'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'user.see.creation-date',
        'display': true
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'user.see.created-by',
        'display': true
    }
};

Wat.I.detailsDefaultFields[qvdObj] = $.extend({}, Wat.I.detailsFields[qvdObj]);
        
// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'filterField': 'name',
        'type': 'text',
        'text': 'Search by name',
        'displayMobile': true,
        'displayDesktop': true,
        'acls': 'user.filter.name'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'block': {
        'text': 'Block',
        'acls': 'user.update-massive.block'
    },
    'unblock': {
        'text': 'Unblock',
        'acls': 'user.update-massive.block'
    },
    'disconnect_all': {
        'text': 'Disconnect from all VMs',
        'acls': 'vm.update-massive.disconnect-user'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'user.delete-massive.'
    },
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'userMassiveEdit',
        'aclsLogic': 'OR'
    }
};

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_user_button',
            'value': 'New User',
            'link': 'javascript:',
            'acl': 'user.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'User list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/users';
Wat.I.detailsBreadCrumbs[qvdObj].next.linkACL = 'user.see-main.';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };