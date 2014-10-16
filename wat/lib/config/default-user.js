var qvdObj = 'user';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
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
        'acls': 'user.see-main.block',
        'text': 'Info'
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'user.see-main.id',
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
        'acls': 'user.see-main.vms-info',
        'text': 'Connected VMs'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'user.see-main.creation-date',
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'user.see-main.created-by',
        'display': false
    },
    'world': {
        'display': true,
        'noTranslatable': true,
        'fields': [
            'world'
        ],
        'acls': 'user.see-main.properties',
        'property': true,
        'text': 'world'
    },
    'sex': {
        'display': true,
        'noTranslatable': true,
        'fields': [
            'sex'
        ],
        'acls': 'user.see-main.properties',
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
        'property': true,
        'acls': 'user.see-main.properties',
    },     
    'sex': {
        'filterField': 'sex',
        'type': 'text',
        'text': 'sex',
        'noTranslatable': true,
        'displayMobile': false,
        'displayDesktop': true,
        'property': true,
        'acls': 'user.see-main.properties',
    }
};

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = [
            {
                'value': 'block',
                'text': 'Block',
                'acls': 'user.update-massive.block'
            },
            {
                'value': 'unblock',
                'text': 'Unblock',
                'acls': 'user.update-massive.block'
            },
            {
                'value': 'disconnect_all',
                'text': 'Disconnect from all VMs',
                'acls': 'vm.update-massive.disconnect-user'
            },
            {
                'value': 'delete',
                'text': 'Delete',
                'acls': 'user.delete-massive.'
            },
            {
                'value': 'massive_changes',
                'text': 'Edit',
                'groupAcls': 'userMassiveEdit',
                'aclsLogic': 'OR'
            }
        ];

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