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
        'click .js-show-upload': 'showUploadControl',
        'click .js-hide-upload': 'hideUploadControl',
        'change .js-change-mode': 'changeMode',
    },
    
    render: function () {
        var that = this;
        
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

                Wat.I.chosenElement('select.js-change-mode', 'single100');

                var template = _.template(
                    Wat.TPL.osConfigurationEditorAssetUploadControl, {
                    }
                );

                $('.bb-upload-control').html(template);

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
        Wat.DIG.updateAssetPreview(opt);
    },
    
    ////////////////////////////////////////////////////
    // Functions for wallpapers configuration on OSD
    ////////////////////////////////////////////////////
    
    afterSetWallpaper: function (e) {
        var opt = $('.js-asset-selector>option:checked');
        if (e.responseText) {
            var response = JSON.parse(e.responseText);
        }
        
        Wat.I.M.showMessage({message: i18n.t('Successfully updated'), messageType: 'success'});
    },
    
    ////////////////////////////////////////////////////
    // Functions for wallpapers (assets) management
    ////////////////////////////////////////////////////
    
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
                pluginId: 'wallpaper',
                afterRender: function () {
                    // Select uploaded element
                    $('.' + this.cid + ' [data-id="' + assetId + '"]>td>input.js-asset-check').trigger('change').prop('checked', true);
                }
            });
            
            Wat.I.M.showMessage({message: i18n.t('Successfully uploaded'), messageType: 'success'});
            
            // Hide upload control
            that.hideUploadControl();
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
                    pluginId: 'wallpaper'
                });
                
                Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
            },
            error: function () {
                Wat.I.M.showMessage({message: i18n.t('Error deleting'), messageType: 'error'});
            }
        });
    },
});