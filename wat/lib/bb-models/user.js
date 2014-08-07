Wat.Models.User = Wat.Models.Model.extend({
    url: "http://172.20.126.12:3000/?login=benja&password=benja&action=user_get_details",
    
    defaults: {
        name: 'New user',
        startedVMs: 0,
        blocked: 0
    }

});