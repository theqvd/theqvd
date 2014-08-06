var VM = Model.extend({
    url: "http://172.20.126.12:3000/?login=benja&password=benja&action=vm_get_details",

    defaults: {
        name: 'New VM',
        blocked: 0
    }

});