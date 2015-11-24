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
        'fixed': true,
        'sortable': false,
    },
    'info': {
        'display': true,
        'fields': [
            'blocked'
        ],
        'groupAcls': [
            'userInfo',
            'tenantUserEmbeddedInfo'
        ],
        'aclsLogic': 'OR',
        'text': 'Info',
        'sortable': false,
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'user.see.id',
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
    'description': {
        'display': false,
        'fields': [
            'description'
        ],
        'acls': 'user.see.description',
        'text': 'Description',
        'sortable': true,
    },
    'connected_vms': {
        'display': true,
        'fields': [
            'id',
            'number_of_vms',
            'number_of_vms_connected'
        ],
        'acls': 'user.see.vms-info',
        'text': 'Connected VMs',
        'sortable': false,
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'user.see.log',
        'display': false,
        'sortable': true,
    },
    'creation_admin_name': {
        'text': 'Created by',
        'fields': [
            'creation_admin_name',
            'creation_admin_id'
        ],
        'acls': 'user.see.log',
        'display': false,
        'sortable': true,
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
        'text': 'Name',
        'displayMobile': true,
        'displayDesktop': true,
        'acls': 'user.filter.name'
    },
    'blocked': {
        'filterField': 'blocked',
        'type': 'select',
        'text': 'Blocking',
        'class': 'chosen-advanced',
        'fillable': false,
        'options': [
            {
                'value': FILTER_ALL,
                'text': 'All',
                'selected': true
            },
            {
                'value': 1,
                'text': 'Blocked'
            },
            {
                'value': 0,
                'text': 'Unblocked'
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'user.filter.block'
    },
    'administrator': {
        'filterField': 'creation_admin_id',
        'type': 'select',
        'text': 'Created by',
        'class': 'chosen-advanced',
        'fillable': true,
        'tenantDepent': true,
        'options': [
            {
                'value': FILTER_ALL,
                'text': 'All',
                'selected': true
            }
                    ],
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'user.filter.created-by',
    },
    'antiquity': {
        'filterField': 'creation_date',
        'type': 'select',
        'text': 'Antiquity',
        'class': 'chosen-single',
        'fillable': false,
        'transform': 'dateGreatThanPast',
        'options': ANTIQUITY_OPTIONS,
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'user.filter.creation-date'
    },
    'min_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Min creation date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'user.filter.creation-date'
    },
    'max_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Max creation date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'user.filter.creation-date'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'userMassiveEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil'
    },
    'block': {
        'text': 'Block',
        'acls': 'user.update-massive.block',
        'iconClass': 'fa fa-lock',
        'visibilityCondition': {
            'type': 'eq',
            'field': 'blocked',
            'value': '0'
        }
    },
    'unblock': {
        'text': 'Unblock',
        'acls': 'user.update-massive.block',
        'iconClass': 'fa fa-unlock-alt',
        'visibilityCondition': {
            'type': 'eq',
            'field': 'blocked',
            'value': '1'
        }
    },
    'disconnect_all': {
        'text': 'Disconnect',
        'acls': 'vm.update-massive.disconnect-user',
        'iconClass': 'fa fa-plug',
        'visibilityCondition': {
            'type': 'ne',
            'field': 'number_of_vms_connected',
            'value': '0'
        }
    },
    'delete': {
        'text': 'Delete',
        'acls': 'user.delete-massive.',
        'iconClass': 'fa fa-trash',
        'darkButton': true
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