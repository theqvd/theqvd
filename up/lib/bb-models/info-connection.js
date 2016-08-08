Up.Models.Connection = Up.Models.Model.extend({
    actionPrefix: 'connection',
    
    defaults: {
    },
    
    url: function () {
        var url = Up.C.getBaseUrl() + 'account/last_connection';
        
        return url;
    },
});