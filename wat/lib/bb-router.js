Wat.Router = Backbone.Router.extend({
    routes: {
        "nodes": "listNode",
        "vms": "listVM",
        "vms/:field/:value": "listVM",
        "vm/:id": "detailsVM",
        "node/:id": "detailsNode",
        "users": "listUser",
        "user/:id": "detailsUser",
        "*actions": "defaultRoute" // Backbone will try match the route above first
    }
});