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

                var qvdObjectName = LOG_TYPE_OBJECTS[qvdObject];

                response.viewTypeName = viewTypeName;
                response.fieldName = fieldName;
                response.qvdObjectName = qvdObjectName;  
                break;
        }
        
        var processedAntiquity = Wat.U.processRemainingTime(response.antiquity);
        var AntiquityTime = '';
        var AntiquityTimeAttr = '';
        
        switch (processedAntiquity.returnType) {
            case 'exact':
                AntiquityTime = processedAntiquity.remainingTime;
                break;
            case 'days':
                AntiquityTimeAttr = 'data-days="' + processedAntiquity.remainingTime + '"';
                break;
            case 'months':
                AntiquityTimeAttr = 'data-months="' + processedAntiquity.remainingTime + '"';
                break;
            case '>year':
                AntiquityTimeAttr = 'data-years="' + processedAntiquity.remainingTime + '"';
                break;
        }
        
        response.antiquityHTML = '<span ' + AntiquityTimeAttr + '>' + AntiquityTime + '</span>';
                                                
        return response;
    },

});