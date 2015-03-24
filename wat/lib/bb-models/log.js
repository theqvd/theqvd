Wat.Models.Log = Wat.Models.Model.extend({
    actionPrefix: 'log',
    
    defaults: {
    },
    
    processResponse: function(response) {
        switch (response.qvd_object) {
            case 'admin_view': 
                var qvdObject = JSON.parse(response.arguments).qvd_object;

                var field = JSON.parse(response.arguments).field;
                var viewType = JSON.parse(response.arguments).view_type;

                switch (viewType) {
                    case 'list_column':
                        var fieldName = Wat.I.listFields[qvdObject][field].text;
                        var viewTypeName = 'Column';
                        break;
                    case 'filter':
                        var fieldName = Wat.I.formFilters[qvdObject][field].text;
                        var viewTypeName = 'Filters';
                        break;

                }

                // qvd object in vies for admins is administrator, but in the rest of the system is admin
                if (qvdObject == 'administrator') {
                    qvdObject = 'admin';
                }

                var qvdObjectName = LOG_TYPE_OBJECTS[qvdObject];

                response.viewTypeName = viewTypeName;
                response.fieldName = fieldName;
                response.qvdObjectName = qvdObjectName;  
                break;
        }
                                                
        return response;
    },

});