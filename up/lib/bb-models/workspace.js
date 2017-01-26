Up.Models.Workspace = Up.Models.Model.extend({
    actionPrefix: 'workspaces',
    
    defaults: {
        name: "New_Workspace",
        fixed: false,
        active: false,
        settings: {
            client: 'classic',
            connection: 'adsl',
            audio: false,
            printers: false,
            fullscreen: false,
            share_folders: false,
            share_usb: false
        }
    }

});