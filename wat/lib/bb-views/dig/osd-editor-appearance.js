Wat.Views.OSDAppearenceEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .input[type="radio"][name="wallpaper"]': 'changeAssetSelector',
        'click .js-wallpaper-name': 'clickAssetName',
        'change .js-asset-check': 'changeAssetManagerSelector',
        'change .js-asset-selector': 'changeAssetSelector',
        'click .js-upload-asset': 'createWallpaper',
        'click .js-delete-selected-asset': 'deleteWallpaper',
        'click .js-show-upload': 'toggleUploadControl',
        'click .js-show-select-mode': 'showSelectMode',
        'click .js-show-manage-mode': 'showManageMode',
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
        
        $('.' + this.cid + ' .js-upload-mode').hide();
    },
    
    afterSetWallpaper: function (e) {
        var opt = $('.js-asset-selector>option:checked');
        if (e.responseText) {
            var response = JSON.parse(e.responseText);
        }
        
        // Mock
        var newWallpaper = {
            id: $(opt).attr('data-id'),
            name: $(opt).attr('data-name'),
            url: $(opt).attr('data-url'),
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
    
    createWallpaper: function (e) {
        var that = this;
        
        var name = $('.' + this.cid + ' input[name="asset_name"]').val();
        
        if (!name) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        this.assetModel = new Wat.Models.Asset({
            name: name,
            assetType: 'wallpaper'
        });
        
        this.assetModel.save().complete(
            function (e) {
                that.uploadWallpaper(that.assetModel.id);
            }
        );
    },
    
    uploadWallpaper: function (assetId) {
        var that = this;
        
        this.assetFileModel = new Wat.Models.AssetFile({
            id: assetId
        });
        
        var file = $('.' + this.cid + ' input[name="asset_file"]')[0].files[0];
        
        if (!file) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var data = new FormData();
        data.append('fileUpload', file);
        
        this.assetFileModel.save({
            data: data,
        }).complete(function () {
            that.renderAssetsControl({ 
                assetType: 'wallpaper',
                pluginId: 'desktop',
                afterRender: function () {
                    // Select uploaded element
                    $('.' + this.cid + ' [data-id="' + assetId + '"]>td>input.js-asset-check').trigger('change').prop('checked', true);
                }
            });
            
            Wat.I.M.showMessage({message: i18n.t('Successfully created'), messageType: 'success'});
            
            // Hide upload control
            that.toggleUploadControl();
        });
    },
    
    deleteWallpaper: function (e) {
        var that = this;
        
        var id = $('.' + this.cid + ' .js-asset-check:checked').val();
        
        var assetModel = new Wat.Models.Asset({
            id: id
        });
        
        assetModel.destroy({
            success: function () {
                that.renderAssetsControl({ 
                    assetType: 'wallpaper',
                    pluginId: 'desktop'
                });
                
                Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
            },
            error: function () {
                Wat.I.M.showMessage({message: i18n.t('Error deleting'), messageType: 'error'});
            }
        });
    },
});