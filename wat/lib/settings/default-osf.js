var qvdObj = 'osf';

// Columns configuration on list view
Wat.I.listFields[qvdObj] = {
    'checks': {
        'display': true,
        'fields': [],
        'acls': [
            'osf.delete-massive.',
            'osf.update-massive.memory',
            'osf.update-massive.user-storage',
            'osf.update-massive.properties'
        ],
        'aclsLogic': 'OR',
        'fixed': true,
        'sortable': false,
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'acls': 'osf.see.id',
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
        'acls': 'osf.see.description',
        'text': 'Description',
        'sortable': true,
    },
    'overlay': {
        'display': true,
        'fields': [
            'overlay'
        ],
        'acls': 'osf.see.overlay',
        'text': 'Overlay',
        'sortable': true,
    },
    'memory': {
        'display': true,
        'fields': [
            'memory'
        ],
        'acls': 'osf.see.memory',
        'text': 'Memory',
        'sortable': true,
    },
    'user_storage': {
        'display': true,
        'fields': [
            'user_storage'
        ],
        'acls': 'osf.see.user-storage',
        'text': 'User storage',
        'sortable': true,
    },
    'dis': {
        'display': true,
        'fields': [
            'id',
            'dis'
        ],
        'acls': 'osf.see.dis-info',
        'text': 'DIs',
        'sortable': false,
    },
    'vms': {
        'display': true,
        'fields': [
            'id',
            'vms'
        ],
        'acls': 'osf.see.vms-info',
        'text': 'VMs',
        'sortable': false,
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'acls': 'osf.see.creation-date',
        'display': false,
        'sortable': false,
    },
    'creation_admin_name': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
        'acls': 'osf.see.created-by',
        'display': false,
        'sortable': false,
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
                'display': false,
                'fields': [
                    'id'
                ],
                'acls': 'osf.see.id',
                'text': 'Id',
                'icon': 'fa fa-asterisk'
            },
            'description': {
                'display': false,
                'fields': [
                    'description'
                ],
                'acls': 'osf.see.description',
                'text': 'Description',
                'icon': 'fa fa-align-justify',
            }
        }
    },
    'hardware': {
        'text': 'Hardware',
        'fieldList': {
            'memory': {
                'display': true,
                'fields': [
                    'memory'
                ],
                'acls': 'osf.see.memory',
                'text': 'Memory',
                'icon': 'fa fa-bolt'
            },
            'user_storage': {
                'display': true,
                'fields': [
                    'user_storage'
                ],
                'acls': 'osf.see.user-storage',
                'text': 'User storage',
                'icon': 'fa fa-archive'
            },
            'overlay': {
                'display': true,
                'fields': [
                    'overlay'
                ],
                'acls': 'osf.see.overlay',
                'text': 'Overlay',
                'icon': 'fa fa-exchange'
            },
        }
    },
    'os': {
        'text': 'Operating system',
        'bb': 'bb-os-configuration'
    },
    'activity': {
        'text': 'Activity',
        'fieldList': {
            'creation_admin': {
                'text': 'Created by',
                'fields': [
                    'creation_admin_name',
                    'creation_admin_id'
                ],
                'acls': 'osf.see.created-by',
                'display': false,
                'icon': 'fa fa-clock-o'
            },
            'creation_date': {
                'text': 'Creation date',
                'fields': [
                    'creation_date'
                ],
                'acls': 'osf.see.creation-date',
                'display': false,
                'icon': CLASS_ICON_ADMINS
            },
            'vms': {
                'display': true,
                'fields': [
                    'id',
                    'vms'
                ],
                'acls': 'osf.see.vms-info',
                'text': 'VMs',
                'icon': CLASS_ICON_VMS
            },
            'dis': {
                'display': true,
                'fields': [
                    'id',
                    'dis'
                ],
                'acls': 'osf.see.dis-info',
                'text': 'DIs',
                'icon': CLASS_ICON_DIS
            }
        }
    }
};

Wat.I.detailsDefaultFields[qvdObj] = $.extend({}, Wat.I.detailsFields[qvdObj]);

Wat.I.editorCategories[qvdObj] = [
    {
        code: 'general',
        text: 'General'
    },
    {
        code: 'hardware',
        text: 'Hardware'
    },
    {
        code: 'software',
        text: 'Software',
        isEnabled: Wat.C.isDIGEnabled
    }
];
    
// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'filterField': 'name',
        'type': 'text',
        'text': 'Name',
        'displayMobile': true,
        'displayDesktop': true,
        'acls': 'osf.filter.name'
    },
    'vm': {
        'filterField': 'vm_id',
        'type': 'select',
        'text': 'Virtual machine',
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
        'displayDesktop': true,
        'acls': 'osf.filter.vm'
    },
    'di': {
        'filterField': 'di_id',
        'type': 'select',
        'text': 'Disk image',
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
        'displayDesktop': true,
        'acls': 'osf.filter.di'
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
        'acls': 'osf.filter.created-by',
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
        'acls': 'osf.filter.creation-date'
    },
    'min_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Min creation date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'osf.filter.creation-date'
    },
    'max_date': {
        'filterField': 'creation_date',
        'type': 'text',
        'text': 'Max creation date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'osf.filter.creation-date'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Actions of the bottom of the list (those that will be done with selected items) configuration on list view
Wat.I.selectedActions[qvdObj] = {
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'osfMassiveEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-massive'
    },
    'changes': {
        'text': 'Edit',
        'groupAcls': 'osfEdit',
        'aclsLogic': 'OR',
        'iconClass': 'fa fa-pencil',
        'otherClass': 'js-only-one'
    },
    'new_osf_di': {
        'text': 'New Disk image',
        'iconClass': CLASS_ICON_DIS,
        'acls': 'di.create.',
        'otherClass': 'js-only-one',
        'isEnabledById': Wat.C.isOsfDigEnabled
    },
    'delete': {
        'text': 'Delete',
        'acls': 'osf.delete-massive.',
        'iconClass': 'fa fa-trash',
        'darkButton': true
    }
};

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_osf_button',
            'value': 'New OS Flavour',
            'link': 'javascript:',
            'acl': 'osf.create.'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'OSF list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/osfs';
Wat.I.detailsBreadCrumbs[qvdObj].next.linkACL = 'osf.see-main.';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };