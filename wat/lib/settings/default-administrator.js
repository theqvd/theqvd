var qvdObj = 'administrator';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': 'administrator.delete-massive.',
        'fixed': true,
        'text': '',
        'fixed': true,
        'sortable': false,
    },
    'info': {
        'text': 'Info',
        'fields': [
            'roles'
        ],
        'acls': 'administrator.see.roles',
        'display': true,
        'sortable': false,
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'administrator.see.id',
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
        'acls': 'administrator.see.description',
        'text': 'Description',
        'sortable': true,
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'administrator.see.creation-date',
        'display': false,
        'sortable': true,
    },
    'creation_admin_name': {
        'text': 'Created by',
        'fields': [
            'creation_admin_name',
            'creation_admin_id'
        ],
        'acls': 'administrator.see.created-by',
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
                'acls': 'administrator.see.id',
                'text': 'Id',
                'icon': 'fa fa-asterisk'
            },
            'description': {
                'display': true,
                'fields': [
                    'description'
                ],
                'acls': 'administrator.see.description',
                'text': 'Description',
                'icon': 'fa fa-align-justify',
            },
            'global_username': {
                'display': true,
                'fields': [
                    'id'
                ],
                'text': 'Global username',
                'icon': 'fa fa-sitemap',
                'onlyMultitenant': true
            }
        }
    },
    'permissions': {
        'text': 'Permissions',
        'fieldList': {
            'roles': {
                'text': 'Assigned roles',
                'fields': [
                    'roles'
                ],
                'acls': 'administrator.see.roles',
                'display': true,
                'icon': CLASS_ICON_ROLES
            }
        }
    },
    'environment': {
        'text': 'Environment',
        'fieldList': {
            'language': {
                'text': 'Language',
                'fields': [
                    'language'
                ],
                'acls': 'administrator.see.language',
                'display': true,
                'icon': 'fa fa-language'
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
                'acls': 'administrator.see.created-by',
                'display': true,
                'icon': CLASS_ICON_ADMINS
            },
            'creation_date': {
                'text': 'Creation date',
                'fields': [
                    'creation_date'
                ],
                'acls': 'administrator.see.creation-date',
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
        'acls': 'administrator.filter.created-by',
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
        'acls': 'administrator.filter.creation-date'
    },
    'min_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Min creation date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'administrator.filter.creation-date'
    },
    'max_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Max creation date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'administrator.filter.creation-date'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'administratorMassiveEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-massive'
    },
    'changes': {
        'text': 'Edit',
        'groupAcls': 'administratorEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-one'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'administrator.delete-massive.',
        'iconClass': 'fa fa-trash',
        'darkButton': true,
        'visibilityCondition': {
            'type': 'ne',
            'field': 'id',
            'value': '__currentAdminId__'
        }
    }
};

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_admin_button',
            'value': 'New Administrator',
            'link': 'javascript:',
            'acl': 'administrator.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Administrators'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Administrators',
                'link': '#/administrators',
                'linkACL': 'administrator.see-main.',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };