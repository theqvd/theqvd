Wat.Models.OSD = Backbone.Model.extend({
    actionPrefix: 'osd',
    apiCode: 'dig',
    
    initialize: function (params) {
        Backbone.Model.prototype.initialize.apply(this, [params]);
        
        this.urlRoot = Wat.C.getApiUrl() + 'proxy/' + this.apiCode + '/osd';
    },
    
    defaults: {
    },
    
    parse: function(response) {
        return $.extend({}, response, this.mock(response));
    },
    
    mock: function (response) {
        var osd = {
            distro_id: parseInt(response.name),
            wallpaper: 23,
            vma_allow_sound: 1,
            vma_allow_printing: 1,
            vma_allow_sharing: 0,
            config_params: {
                wallpaper: {
                    description: 'Wallpaper',
                    type: '__asset_list[type="wallpapers"]__',
                    list_options: null
                },
                vma_allow_sound: {
                    description: 'Allow sound',
                    type: 'list',
                    list_options: {
                        0: 'No',
                        1: 'Yes'
                    }
                },
                vma_allow_printing: {
                    description: 'Allow printing',
                    type: 'list',
                    list_options: {
                        0: 'No',
                        1: 'Yes'
                    }
                },
                vma_allow_sharing: {
                    description: 'Allow folders and USB sharing',
                    type: 'list',
                    list_options: {
                        0: 'No',
                        1: 'Yes'
                    }
                }
            },
            scripts: [
                {
                    id: 12,
                    name: 'configure_anything.sh',
                    execution_hook: 'first_connection'
                },
                {
                    id: 17,
                    name: 'log_connection.sh',
                    execution_hook: 'vma.on_state.connected'
                },
                {
                    id: 34,
                    name: 'close_connection.sh',
                    execution_hook: 'vma.on_state.expire'
                },
            ],
            shortcuts: [
                {
                    id: 12,
                    name: 'QVD Website',
                    command: 'firefox',
                    icon_url: 'https://www.mozilla.org/media/img/styleguide/identity/firefox/guidelines-logo.7ea045a4e288.png',
                    icon_id: 45
                }
            ]
        };
        
        return osd;
    },
    
    urlz: function () {
        var url = Wat.C.getApiUrl() + 'proxy/' + this.apiCode + '/osd';
        
        return url;
    }
});