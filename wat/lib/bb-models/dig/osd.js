Wat.Models.OSD = Wat.Models.DIG.extend({
    pluginDef: {},
    pluginData: {},
    
    initialize: function (attrs, opts) {
        Backbone.Model.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = this.baseUrl() + '/osd';
    },
    
    url: function () {
        return this.baseUrl() + '/osd';
    },
    
    initPlugins: function () {
        var that = this;
        
        $.each (this.pluginDef.models, function (iModel, model) {
            var pluginId = model.get('plugin_id');
            var plugin = model.get('plugin');
            
            that.pluginData[pluginId] = new Wat.Models.Plugin({}, {osdId: that.id, pluginId: pluginId});
        });
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
                    id: 10,
                    name: 'configure_anything.sh',
                    execution_hook: 'first_connection'
                },
                {
                    id: 11,
                    name: 'log_connection.sh',
                    execution_hook: 'vma.on_state.connected'
                },
                {
                    id: 12,
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
    
    // Get plugin definition
    // - pluginId: Id of the plugin (alphanumeric)
    //      I.E.: os|vma|execution_hooks|shortcuts...
    getPluginDef: function (pluginId) {
        var pluginModel = this.pluginDef.where({plugin_id: pluginId})[0];
        return pluginModel.get('plugin');
    },
    
    // Get possible options of an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: os.distro|execution_hooks.script
    getPluginAttrOptions: function (pluginAttr) {
        var [pluginId, attr] = pluginAttr.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        return plugin[attr].list_options;
    },
    
    // Get possible options of a setting of type list form an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: execution_hooks.script.hook
    getPluginAttrSettingOptions: function (pluginAttrSetting) {
        var [pluginId, attr, setting] = pluginAttrSetting.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        return plugin[attr].settings[setting].list_options;
    },
});