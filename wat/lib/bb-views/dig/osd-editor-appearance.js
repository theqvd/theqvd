Wat.Views.OSDAppearenceEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
        
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change .js-asset-selector': 'changeAssetSelector',
    },
    
    render: function () {
        var that = this;
        
        if (!Wat.CurrentView.OSDmodel.pluginData.wallpaper) {
            return;
        }
        
        Wat.CurrentView.OSDmodel.pluginData.wallpaper.fetch({
            complete: function () {
                var template = _.template(
                    Wat.TPL.osConfigurationEditorAppearance, {
                        massive: this.massive,
                        assetType: 'wallpaper',
                        cid: that.cid
                    }
                );

                $('.bb-os-conf-appearance').html(template);

                that.renderAssetsControl({
                    assetType: 'wallpaper',
                    pluginId: 'wallpaper'
                });

                $('.' + that.cid + ' .js-upload-mode').hide();
            }
        });
    },
    
    afterLoadSection: function () {
        this.showSelectMode();
    },
    
    ////////////////////////////////////////////////////
    // Functions for interface
    ////////////////////////////////////////////////////
    
    showSelectMode: function (e) {
        Wat.Views.OSDEditorView.prototype.showSelectMode.apply(this, [e]);
        
        var opt = $('.' + this.cid + ' .js-asset-selector>option:checked');
        this.updateAssetPreview(opt);
    },
    
    ////////////////////////////////////////////////////
    // Functions for wallpapers configuration on OSD
    ////////////////////////////////////////////////////
    
    changeAssetSelector: function (e) {
        var opt = $(e.target).find('option:checked');
        
        this.updateAssetPreview(opt);
        
        var pluginId = $(opt).attr('data-plugin-id');
        
        var setCallback = function () {};
        
        switch(pluginId) {
            case 'wallpaper':
                    var id = $(opt).attr('data-id');
                    var name = $(opt).attr('data-name');
                    var url = $(opt).attr('data-url');
                    setCallback = this.afterSetWallpaper;
                break;
            default:
                return;
        }
        
        // If new option is None, element will be deleted
        if ($(opt).attr('data-none')) {
            // Save plugin element
            Wat.DIG.deletePluginListElement({
                pluginId: 'wallpaper',
                osdId: Wat.CurrentView.OSDmodel.id,
                attributes: {
                    pluginId: pluginId,
                    id: Wat.CurrentView.OSDmodel.pluginData.wallpaper.get('id')
                }
            }, setCallback, function () {});
            
            return;
        }
        
        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: pluginId,
            osdId: Wat.CurrentView.OSDmodel.id,
            attributes: {
                id: id,
                name: name,
                url: url
            }
        }, setCallback, function () {});
    },
    
    afterSetWallpaper: function (e) {
        var opt = $('.js-asset-selector>option:checked');
        if (e.responseText) {
            var response = JSON.parse(e.responseText);
        }
        
        Wat.I.M.showMessage({message: i18n.t('Successfully updated'), messageType: 'success'});
    },
});