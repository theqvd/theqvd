var qvdObj = 'di';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': [
            'di.delete-massive.',
            'di.update-massive.block',
            'di.update-massive.tags-add',
            'di.update-massive.tags-delete',
            'di.update-massive.properties'
        ],
        'aclsLogic': 'OR',
        'fixed': true,
        'text': 'checks',
        'sortable': false,
    },
    'info': {
        'display': true,
        'fields': [
            'blocked',
            'tags'
        ],
        'groupAcls': [
            'diInfo', 
            'osfDiEmbeddedInfo',
            'tenantDiEmbeddedInfo',
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
        'acls': 'di.see.id',
        'text': 'Id',
        'sortable': true,
    },
    'disk_image': {
        'display': true,
        'fields': [
            'id',
            'disk_image'
        ],
        'text': 'Disk image',
        'sortable': true,
    },
    'description': {
        'display': false,
        'fields': [
            'description'
        ],
        'acls': 'di.see.description',
        'text': 'Description',
        'sortable': true,
    },
    'osf': {
        'display': true,
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'di.see.osf',
        'text': 'OSF',
        'sortable': true,
    },
    'version': {
        'display': true,
        'fields': [
            'version'
        ],
        'acls': 'di.see.version',
        'text': 'Version',
        'sortable': true,
    },
    'default': {
        'display': false,
        'fields': [
            'tags'
        ],
        'acls': 'di.see.default',
        'text': 'Default',
        'sortable': false,
    },
    'head': {
        'display': false,
        'fields': [
            'tags'
        ],
        'acls': 'di.see.head',
        'text': 'Head',
        'sortable': false,
    },
    'tags': {
        'display': false,
        'fields': [
            'tags'
        ],
        'acls': 'di.see.tags',
        'text': 'Tags',
        'sortable': false,
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'di.see.log',
        'display': false,
        'sortable': true,
    },
    'creation_admin_name': {
        'text': 'Created by',
        'fields': [
            'creation_admin_name',
            'creation_admin_id'
        ],
        'acls': 'di.see.log',
        'display': false,
        'sortable': true,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

// Fields configuration on details view
Wat.I.detailsFields[qvdObj] = {
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'di.see.id',
        'text': 'Id'
    },
    'disk_image': {
        'display': true,
        'fields': [
            'id',
            'disk_image'
        ],
        'text': 'Disk image'
    },
    'block': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'di.see.block',
        'text': 'Blocking'
    },
    'tags': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'di.see.tags',
        'text': 'Tags'
    },
    'osf': {
        'display': true,
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'di.see.osf',
        'text': 'OS Flavour'
    },
    'version': {
        'display': true,
        'fields': [
            'version'
        ],
        'acls': 'di.see.version',
        'text': 'Version'
    },
    'default': {
        'display': false,
        'fields': [
            'tags'
        ],
        'acls': 'di.see.default',
        'text': 'Default'
    },
    'head': {
        'display': false,
        'fields': [
            'tags'
        ],
        'acls': 'di.see.head',
        'text': 'Head'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'di.see.creation-date',
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'di.see.created-by',
        'display': false
    }
};

Wat.I.detailsDefaultFields[qvdObj] = $.extend({}, Wat.I.detailsFields[qvdObj]);


// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'name': 'name',
        'filterField': 'disk_image',
        'type': 'text',
        'text': 'Disk image',
        'displayMobile': true,
        'displayDesktop': true,
        'acls': 'di.filter.disk-image'
    },
    'osf': {
        'name': 'osf',
        'filterField': 'osf_id',
        'type': 'select',
        'text': 'OS Flavour',
        'class': 'chosen-advanced',
        'fillable': true,
        'displayMobile': true,
        'displayDesktop': true,
        'options': [
            {
                'value': FILTER_ALL,
                'text': 'All',
                'selected': true
            }
                    ],
        'acls': 'di.filter.osf'
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
        'acls': 'di.filter.block'
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
        'acls': 'di.filter.created-by',
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
        'acls': 'di.filter.creation-date'
    },
    'min_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Min creation date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'di.filter.creation-date'
    },
    'max_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Max creation date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'di.filter.creation-date'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list configuration on list view (those that will be done with selected items)
Wat.I.selectedActions[qvdObj] = {
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'diMassiveEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil'
    },
    'default': {
        'text': 'Default image',
        'acls': 'di.update.default',
        'iconClass': 'fa fa-home',
        'otherClass': 'js-only-one'
    }, 
    'block': {
        'text': 'Block',
        'acls': 'di.update-massive.block',
        'iconClass': 'fa fa-lock'
    },           
    'unblock': {
        'text': 'Unblock',
        'acls': 'di.update-massive.block',
        'iconClass': 'fa fa-unlock-alt'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'di.delete-massive.',
        'iconClass': 'fa fa-trash',
        'darkButton': true
    }
};

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_di_button',
            'value': 'New Disk image',
            'link': 'javascript:',
            'acl': 'di.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'DI list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/dis';
Wat.I.detailsBreadCrumbs[qvdObj].next.linkACL = 'di.see-main.';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };