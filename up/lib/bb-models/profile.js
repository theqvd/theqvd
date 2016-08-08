Up.Models.Profile = Up.Models.Model.extend({
    actionPrefix: 'profile',
    
    defaults: {
    },
    
    url: function () {
        var url = Up.C.getBaseUrl() + 'account';
        
        return url;
    },
});