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
            'di.update-massive.properties-create',
            'di.update-massive.properties-update',
            'di.update-massive.properties-delete'
        ],
        'aclsLogic': 'OR',
        'fixed': true,
        'text': 'checks'
    },
    'info': {
        'display': true,
        'fields': [
            'blocked',
            'tags'
        ],
        'acls': [
            'di.see.block',
            'di.see.tags'
        ],
        'aclsLogic': 'OR',
        'text': 'Info'
    },
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
    'osf': {
        'display': true,
        'fields': [
            'osf_id',
            'osf_name'
        ],
        'acls': 'di.see.osf',
        'text': 'OSF'
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


// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'name': {
        'name': 'name',
        'filterField': 'disk_image',
        'type': 'text',
        'text': 'Search by disk image',
        'displayMobile': true,
        'displayDesktop': true
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
                'value': -1,
                'text': 'All',
                'selected': true
            }
                    ],
        'acls': 'di.see.osf'
    }
};

// Actions of the bottom of the list configuration on list view (those that will be done with selected items)
Wat.I.selectedActions[qvdObj] = {
    'block': {
        'text': 'Block',
        'acls': 'di.update-massive.block'
    },           
    'unblock': {
        'text': 'Unblock',
        'acls': 'di.update-massive.block'
    },
    'delete': {
        'text': 'Delete',
        'acls': 'di.delete-massive.'
    },
    'massive_changes': {
        'text': 'Edit',
        'groupAcls': 'diMassiveEdit',
        'aclsLogic': 'OR'
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