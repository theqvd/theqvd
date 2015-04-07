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
        'fixed': true
    },
    'id': {
        'display': false,
        'fields': [
            'id'
        ],
        'text': 'Id',
        'sortable': true,
        'acls': 'log.see-main.',
    },
    'qvd_object': {
        'display': false,
        'fields': [
            'qvd_object'
        ],
        'text': 'Object',
        'sortable': true,
    },
    'action': {
        'display': true,
        'fields': [
            'type_of_action'
        ],
        'text': 'Action',
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
        'sortable': true,
    },
    'administrator': {
        'display': true,
        'fields': [
            'admin_id',
            'admin_name'
        ],
        'text': 'Administrator',
        'sortable': true,
        'acls': 'log.see.administrator',
    },
    'datetime': {
        'display': true,
        'fields': [
            'time'
        ],
        'text': 'Passed time',
        'sortable': true,
    },
    'source': {
        'display': true,
        'fields': [
            'source'
        ],
        'text': 'Source',
        'sortable': true,
        'acls': 'log.see.source',
    },
    'address': {
        'display': false,
        'fields': [
            'ip'
        ],
        'text': 'Address',
        'sortable': true,
        'acls': 'log.see.address',
    }
};

Wat.I.listDefaultFields[qvdObj] = $.extend({}, Wat.I.listFields[qvdObj]);

        
// Filters configuration on list view
Wat.I.formFilters[qvdObj] = {
    'antiquity': {
        'filterField': 'time',
        'type': 'select',
        'text': 'Antiquity',
        'class': 'chosen-single',
        'fillable': false,
        'transform': 'dateGreatThan',
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            },
            {
                'value': 3600,
                'text': '<1 hour'
            },
            {
                'value': 21600,
                'text': '<6 hours'
            },
            {
                'value': 43200,
                'text': '<12 hours'
            },
            {
                'value': 86400,
                'text': '<1 day'
            },
            {
                'value': 604800,
                'text': '<1 week'
            },
            {
                'value': 2592000,
                'text': '<1 month'
            },
                    ],
        'displayMobile': false,
        'displayDesktop': false,
        'acls': 'log.filter.date'
    },
    'min_date': {
        'filterField': 'time',
        'type': 'text',
        'text': 'Min Date',
        'transform': 'dateMin',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'log.filter.date'
    },
    'max_date': {
        'filterField': 'time',
        'type': 'text',
        'text': 'Max Date',
        'transform': 'dateMax',
        'class': 'datepicker-past date-filter',
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'log.filter.date'
    },
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
        'acls': 'log.filter.source'
    },
    'admin': {
        'filterField': 'admin_id',
        'type': 'select',
        'text': 'Administrator',
        'class': 'chosen-advanced',
        'fillable': false,
        'options': [
            {
                'value': -1,
                'text': 'All',
                'selected': true
            }
                    ],
        'displayMobile': false,
        'displayDesktop': true,
        'acls': 'log.filter.administrator'
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
        'acls': 'log.filter.action'
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
        'acls': 'log.filter.object'
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
        'acls': 'log.filter.response',
        'displayMobile': true,
        'displayDesktop': true
    }
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