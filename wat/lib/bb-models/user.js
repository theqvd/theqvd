Wat.Models.User = Wat.Models.Model.extend({
    action: "user_get_details",
    actionPrefix: 'user_',

    defaults: {
        name: 'New user',
        startedVMs: 0,
        blocked: 0
    }

});