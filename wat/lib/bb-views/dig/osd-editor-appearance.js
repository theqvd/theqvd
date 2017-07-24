Wat.Views.OSDAppearenceEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .input[type="radio"][name="wallpaper"]': 'changeAssetSelector',
        'click .js-wallpaper-name': 'clickWallpaperName',
        'change .js-asset-selector': 'changeAssetSelector',
        'click .js-toggle-upload-select-mode': 'toggleUploadSelectMode',
        'click .js-upload-wallpaper': 'uploadWallpaper'
    },
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorAppearance, {
                massive: this.massive,
                assetType: 'wallpaper',
                cid: this.cid
            }
        );

        $('.bb-os-conf-appearance').html(template);
        
        this.renderAssetsControl({
            assetType: 'wallpaper',
            pluginId: 'desktop'
        });
        
        $('.js-upload-mode').hide();
    },
    
    changeAssetSelector: function (e) {
        Wat.DIG.changeAssetSelector(e);
        
        var row = $(e.target).closest('tr');
        var pluginId = $(row).attr('data-plugin-id');
        var setCallback = function () {};

        switch(pluginId) {
            case 'desktop':
                    var id = $(row).attr('data-id');
                    var name = $(row).attr('data-name');
                    var url = $(row).attr('data-url');
                    setCallback = this.afterSetWallpaper;
                break;
            default:
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
        
        // Show loading message for preview image until it is loaded
        $('.js-preview img').hide();
        $('.js-data-preview-message').show();
        $('.js-preview img').on('load', function () {
            $('.js-preview img').show();
            $('.js-data-preview-message').hide();
        });
    },
    
    afterSetWallpaper: function (e) {
        var row = $('tr[data-type="wallpaper"].selected-row');
        
        var response = JSON.parse(e.responseText);
        
        // Mock
        var newWallpaper = {
            id: $(row).attr('data-id'),
            name: $(row).attr('data-name'),
            url: $(row).attr('data-url'),
        };
        // End Mock
        
        return;
        
        // Render new shortcut on shortcut list
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRows, {
                shortcuts: [newShortcut]
            }
        );
        
        $('.bb-os-conf-shortcuts-new-rows').prepend(template);
        
        // Reset controls
        $('.shortcuts-form input[name="shortcut_command"]').val('');
        $('.shortcuts-form input[name="shortcut_name"]').val('');
        
        Wat.T.translate();
    },
    
    clickWallpaperName: function (e) {
        // Select this script
        $(e.target).parent().find('input[type="radio"]').trigger('click');
    },
    
    toggleUploadSelectMode: function (e) {
        $('.js-upload-mode, .js-select-mode').toggle();
        $('.js-preview img').toggle();
        
        $('input[name="wallpaper_name"]').val('');
        var file = $('input[name="wallpaper_file"]').val('');
    },
    
    uploadWallpaper: function (e) {
        var name = $('input[name="wallpaper_name"]').val();
        var file = $('input[name="wallpaper_file"]')[0].files[0];
        
        if (!name || !file) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var uploadedWallpaper = {
            name: name,
            url: 'https://s-media-cache-ak0.pinimg.com/originals/8b/8f/b2/8b8fb268842167174d0265df49c2a0ba.jpg'
        };
        
        Wat.CurrentView.OSDmodel.pluginDef.where({code: 'desktop'})[0].attributes.plugin.wallpaper.list_images[55] = uploadedWallpaper;
        
        this.toggleUploadSelectMode();
        
        Wat.CurrentView.editorView.softwareEditorView.renderSectionAppearence();
    }
});