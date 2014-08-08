Wat.Models.VM = Wat.Models.Model.extend({
    action: "vm_get_details",
    actionPrefix: 'vm_',

    defaults: {
        name: 'New VM',
        blocked: 0
    }

});