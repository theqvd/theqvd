Wat.Router = Backbone.Router.extend({
    routes: {
        "vms": "listVM",
        "vms/:field/:value": "listVM",
        "vm/:id": "detailsVM",
        "users": "listUser",
        "user/:id": "detailsUser",
        "*actions": "defaultRoute" // Backbone will try match the route above first
    }
});