Wat.Models.OSD = Wat.Models.DIG.extend({
    pluginDef: {},
    pluginData: {},
    
    initialize: function (attrs, opts) {
        Backbone.Model.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = this.baseUrl() + '/osd';
    },
    
    initPlugins: function () {
        var that = this;
        $.each (this.pluginDef.models, function (iModel, model) {
            var pluginId = model.get('code');
            var plugin = model.get('plugin');
            
            that.pluginData[pluginId] = new Wat.Models.Plugin({}, {osdId: that.id, pluginId: pluginId});
        });
    },
    
    defaults: {
    },
    
    parse: function(response) {
        if (response.status && response.status != STATUS_SUCCESS) {
            response.error = response.message;
        }
        
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
    
    getPluginDef: function (pluginId) {
        var pluginModel = this.pluginDef.where({code: pluginId})[0];
        
        return pluginModel ? pluginModel.attributes : false;
    },
    
    // Get possible options of an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: os.distro|execution_hooks.script
    getPluginAttrOptions: function (pluginAttr, enumCallback) {
        var [pluginId, attr] = pluginAttr.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        
        if (!plugin) {
            return [];
        }
        
        var attrModel = {};
        $.each(plugin.values, function (i,v) {
            if (v.method == 'PUT') {
                $.each(v.model, function (ii, vv) {
                    if (vv.code == attr) {
                        attrModel = vv;
                        return false;
                    }
                });
                return false;
            }
        });
        
        if (attrModel.type == 'enum') {
            return attrModel.values;
        }
        
        var location = '/' + pluginId;
        var enums = new Wat.Collections.PluginEnums({location: location});
        enums.fetch({
            complete: function () {
                var listEnums = {};
                $.each(enums.models, function (i, model) {
                    listEnums[model.id] = model.attributes;
                    listEnums[model.id].value = model.get('name');
                });
                
                enumCallback(listEnums);
            }
        });
    },
    
    // Get possible options of a setting of type list form an attribute of type list of a plugin
    // - pluginAttr: Plugin and attribute Ids separated by dots
    //      I.E.: execution_hooks.script.hook
    getPluginAttrSettingOptions: function (pluginAttrSetting) {
        var [pluginId, attr, setting] = pluginAttrSetting.split('.');
        
        var plugin = this.getPluginDef(pluginId);
        
        if (plugin.plugin) {
            return plugin.plugin[attr].settings[setting].list_options;
        }
        else {
            return {};
        }
    },
});