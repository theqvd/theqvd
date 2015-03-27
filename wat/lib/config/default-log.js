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
    'qvd_object': {
        'display': false,
        'fields': [
            'qvd_object'
        ],
        'text': 'Object',
        'fixed': true,
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
    'object_name': {
        'display': true,
        'fields': [
            'qvd_object',
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
    },
    'source': {
        'display': true,
        'fields': [
            'source'
        ],
        'text': 'Source',
        'fixed': true,
        'sortable': true,
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

        
// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'source': {
        'filterField': 'source',
        'type': 'select',
        'text': 'Source',
        'class': 'chosen-single',
        'fillable': true,
        'fillAction': 'sources_in_log',
        'nameAsId': true,
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
    },
    'admin': {
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
    },
    'action': {
        'filterField': 'type_of_action',
        'type': 'select',
        'text': 'Action',
        'class': 'chosen-single',
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
    },
    'object': {
        'filterField': 'qvd_object',
        'type': 'select',
        'text': 'Object',
        'class': 'chosen-single',
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
    },
    'response': {
        'filterField': 'status',
        'type': 'select',
        'text': 'Response',
        'class': 'chosen-single',
        'fillable': false,
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            },
            {
                'value': STATUS_SUCCESS,
                'text': 'Success'
            },
            {
                'value': STATUS_SUCCESS,
                'not': STATUS_SUCCESS,
                'text': 'Not success'
            },
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'log.see-main.',
        'displayMobile': true,
        'displayDesktop': true
    },
};

$.each(LOG_TYPE_OBJECTS, function(typeObject, typeObjectName) {
    Wat.I.formFilters[qvdObj]['object']['options'].push({
        'value': typeObject,
        'text': typeObjectName,
        'selected': false
    });
});

$.each(LOG_TYPE_ACTIONS, function(typeAction, typeActionName) {
    Wat.I.formFilters[qvdObj]['action']['options'].push({
        'value': typeAction,
        'text': typeActionName,
        'selected': false
    });
});


Wat.I.formDefaultFilters[qvdObj] = $.extend({}, Wat.I.formFilters[qvdObj]);

// Breadcrumbs configuration on list view
$.extend(Wat.I.listBreadCrumbs[qvdObj], Wat.I.homeBreadCrumbs);
Wat.I.listBreadCrumbs[qvdObj]['next'] = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Log registers'
            }
        };

// Breadcrumbs configuration on details view
$.extend(true, Wat.I.detailsBreadCrumbs[qvdObj], Wat.I.listBreadCrumbs[qvdObj]);

Wat.I.detailsBreadCrumbs[qvdObj].next = {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Log registers',
                'link': '#/log',
                'linkACL': 'log.see-main.',
                'next': {
                    'screen': '' // Will be filled dinamically
                }
            }
        };