Wat.Models.User = Wat.Models.Model.extend({
    actionPrefix: 'user',
    
    defaults: {
        name: 'New user',
        startedVMs: 0,
        blocked: 0
    }

});