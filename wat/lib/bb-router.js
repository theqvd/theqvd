Wat.Router = Backbone.Router.extend({
    routes: {
        "dis": "listDI",
        "dis/:field/:value": "listDI",
        "osfs": "listOSF",
        "nodes": "listNode",
        "vms": "listVM",
        "vms/:field/:value": "listVM",
        "vm/:id": "detailsVM",
        "di/:id": "detailsDI",
        "osf/:id": "detailsOSF",
        "node/:id": "detailsNode",
        "users": "listUser",
        "user/:id": "detailsUser",
        "setup/customize": "setupCustomize",
        "*actions": "defaultRoute" // Backbone will try match the route above first
    }
});