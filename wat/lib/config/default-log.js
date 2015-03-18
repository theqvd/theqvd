var qvdObj = 'log';

// Columns configuration on list view
// type_ofaction, qvd_object, object_name, admin_id, time
Wat.I.listFields[qvdObj] = {
    'see_details': {
        'display': true,
        'fields': [
            'id'
        ],
        'acls': 'log.see-details.',
        'sortable': false,
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'text': 'Id',
        'sortable': true,
    },
    'action': {
        'display': true,
        'fields': [
            'type_of_action'
        ],
        'text': 'Action',
        'fixed': true,
        'sortable': true,
    },
    'qvd_object': {
        'display': true,
        'fields': [
            'qvd_object'
        ],
        'text': 'Object',
        'fixed': true,
        'sortable': true,
    },
    'object_name': {
        'display': true,
        'fields': [
            'object_id',
            'object_name'
        ],
        'text': 'Name',
        'fixed': true,
        'sortable': true,
    },
    'administrator': {
        'display': true,
        'fields': [
            'admin_id',
            'admin_name'
        ],
        'text': 'Administrator',
        'fixed': true,
        'sortable': true,
    },
    'datetime': {
        'display': true,
        'fields': [
            'time'
        ],
        'text': 'Datetime',
        'fixed': true,
        'sortable': true,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

        
// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'administrator': {
        'filterField': 'admin_id',
        'type': 'select',
        'text': 'Administrator',
        'class': 'chosen-advanced',
        'fillable': true,
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'log.see-main.'
    }
};

Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Logs'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);

Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Logs',
                'link': '#/log',
                'linkACL': 'tenant.see-main.',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };