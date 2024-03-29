var qvdObj = 'role';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': 'role.delete.',
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
    'description': {
        'display': false,
        'fields': [
            'description'
        ],
        'acls': 'role.see.description',
        'text': 'Description',
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
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'role.see.creation-date',
        'display': false,
        'sortable': true,
    },
    'creation_admin_name': {
        'text': 'Created by',
        'fields': [
            'creation_admin_name',
            'creation_admin_id'
        ],
        'acls': 'role.see.created-by',
        'display': false,
        'sortable': true,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

// Fields configuration on details view
Wat.I.detailsFields[qvdObj] = {
    'general': {
        'text': 'General',
        'default': true,
        'fieldList': {
            'id': {
                'display': true,
                'fields': [
                    'id'
                ],
                'acls': 'role.see.id',
                'text': 'Id',
                'icon': 'fa fa-asterisk'
            },
            'description': {
                'display': true,
                'fields': [
                    'description'
                ],
                'acls': 'role.see.description',
                'text': 'Description',
                'icon': 'fa fa-align-justify',
            }
        }
    },
    'inheritance': {
        'text': 'Inheritance',
        'fieldList': {
            'roles': {
                'text': 'Inherited roles',
                'fields': [
                    'roles'
                ],
                'acls': 'role.see.inherited-roles',
                'display': true,
                'icon': CLASS_ICON_ROLES
            },
            'templates': {
                'text': 'Inherited templates',
                'fields': [
                    'roles'
                ],
                'acls': 'role.see.inherited-roles',
                'display': true,
                'icon': CLASS_ICON_TEMPLATES
            }
        }
    },
    'activity': {
        'text': 'Activity',
        'fieldList': {
            'creation_admin': {
                'text': 'Created by',
                'fields': [
                    'creation_admin'
                ],
                'acls': 'role.see.created-by',
                'display': true,
                'icon': CLASS_ICON_ADMINS
            },
            'creation_date': {
                'text': 'Creation date',
                'fields': [
                    'creation_date'
                ],
                'acls': 'role.see.creation-date',
                'display': true,
                'icon': 'fa fa-clock-o'
            }
        }
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
        'displayDesktop': true
    },
    'administrator': {
        'filterField': 'creation_admin_id',
        'type': 'select',
        'text': 'Created by',
        'class': 'chosen-advanced',
        'fillable': true,
        'options': [
            {
                'value': FILTER_ALL,
                'text': 'All',
                'selected': true
            }
                    ],
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'role.see.created-by',
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
        'acls': 'role.see.creation-date'
    },
    'min_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Min creation date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'role.see.creation-date'
    },
    'max_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Max creation date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'role.see.creation-date'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'roleMassiveEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-massive'
    },
    'changes': {
        'text': 'Edit',
        'groupAcls': 'roleEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-one'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'role.delete.',
        'iconClass': 'fa fa-trash',
        'darkButton': true
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