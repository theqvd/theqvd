var qvdObj = 'di';

// Columns configuration on list view
Wat.I.listColumns[qvdObj] = {
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
        'text': 'OSF'
    },
    'version': {
        'display': true,
        'fields': [
            'version'
        ],
        'text': 'Version'
    },
    'default': {
        'display': false,
        'fields': [
            'tags'
        ],
        'text': 'Default'
    },
    'creation_date': {
        'text': 'Creation date',
        'fields': [
            'creation_date'
        ],
        'display': false
    },
    'creation_admin': {
        'text': 'Created by',
        'fields': [
            'creation_admin'
        ],
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
    }
};

// Actions of the bottom of the list configuration on list view (those that will be done with selected items)
Wat.I.selectedActions[qvdObj] = [
            {
                'value': 'block',
                'text': 'Block'
            },           
            {
                'value': 'unblock',
                'text': 'Unblock'
            },
            {
                'value': 'delete',
                'text': 'Delete'
            },
            {
                'value': 'massive_changes',
                'text': 'Massive changes'
            }
        ];

// Action button (tipically New button) configuration on list view
Wat.I.listActionButton[qvdObj] = {
            'name': 'new_di_button',
            'value': 'New Disk image',
            'link': 'javascript:',
            'acl': 'di_create'
        };

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'DI list'
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);
Wat.I.detailsBreadCrumbs[qvdObj].next.link = '#/dis';
Wat.I.detailsBreadCrumbs[qvdObj].next.next = {
            'screen': '' // Will be filled dinamically
        };