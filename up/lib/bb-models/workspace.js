Up.Models.Workspace = Up.Models.Model.extend({
    actionPrefix: 'workspaces',
    
    defaults: {
        name: "New_Workspace",
        fixed: false,
        active: false,
        settings: {
            client: {
                list: [],
                value : 'classic'
            },
            connection: {
                list: [],
                value : 'adsl'
            },
            audio: {
                list: [],
                value : false
            },
            printers: {
                list: [],
                value : false
            },
            fullscreen: {
                list: [],
                value : false
            },
            share_folders: {
                list: [],
                value : false
            },
            share_usb: {
                list: [],
                value : false
            },
            kb_layout: {
                list: [],
                value : 'auto'
            }
        }
    }

});