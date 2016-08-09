Up.Models.Profile = Up.Models.Model.extend({
    actionPrefix: 'account',
    
    defaults: {
    },
    
    url: function () {
        var url = Up.C.getBaseUrl() + 'account';
        
        return url;
    },
    
    parse: function (response) {
        // Store account settings
        Up.C.account = response;
        
        return this.processResponse(response);
    }
});