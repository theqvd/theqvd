Wat.Views.OSDAssetsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change .js-change-mode': 'changeMode',
        'click .js-show-upload': 'showUploadControl',
        'click .js-hide-upload': 'hideUploadControl',
        'click .js-upload-asset': 'createAsset',
        'click .js-delete-asset': 'deleteAsset',
        'change .js-asset-check': 'changeAssetManagerSelector',
        'change .js-asset-selector': 'changeAssetSelector',
        'click .input[type="radio"][name="wallpaper"]': 'changeAssetSelector',
        'click .js-wallpaper-name': 'clickAssetName',
        'click .js-icon-name': 'clickAssetName',
        'click .js-script-name': 'clickAssetName',
        'change input[name="asset_file"]': 'loadFile'
    },
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorAssets, {
                massive: this.massive,
                cid: this.cid
            }
        );
        
        $('.bb-os-conf-assets').html(template);
        
        Wat.I.chosenElement('select.js-change-mode', 'single100');
    },
    
    // Set filename as script name when load file
    loadFile: function (e) {
        var filename = $(e.target)[0].files[0].name;
        var assetType = $(e.target).attr('data-asset-type');
        
        $('.' + this.cid + ' input[name="asset_name"][data-asset-type="' + assetType + '"]').val(filename);
    },
    
    changeMode: function (e) {
        var assetType = $(e.target).val();
        
        $('table[data-asset-type] input[name="' + assetType + '"]').eq(0).trigger('click').trigger('change');
        $('.js-upload-mode').hide();
        $('.js-upload-mode[data-asset-type="' + assetType + '"]').show();
    },
    
    showUploadControl: function (e) {
        var assetType = $(e.target).attr('data-asset-type');
        var pluginId = $(e.target).attr('data-plugin-id');
        
        var template = _.template(
            Wat.TPL.osConfigurationEditorAssetsUploadControl, {
                assetType: assetType,
                pluginId: pluginId
            }
        );

        $('.' + this.cid + ' .bb-upload-control[data-asset-type="' + assetType + '"]').html(template);
        
        Wat.T.translate();
        
        $('.' + this.cid + ' .js-upload-control[data-asset-type="' + assetType + '"]').show();
        $('.' + this.cid + ' .js-asset-switch-buttonset').hide();
        $('.' + this.cid + ' .js-osf-conf-editor').hide();
    },
    
    hideUploadControl: function (e) {
        var assetType = $(e.target).attr('data-asset-type');
        
        $('.' + this.cid + ' .js-upload-control').hide();
        $('.' + this.cid + ' .js-asset-switch-buttonset').show();
        $('.' + this.cid + ' .js-osf-conf-editor[data-asset-type="' + assetType + '"]').show();
    },
    
    createAsset: function (e) {
        var that = this;
        
        var assetType = $(e.target).attr('data-asset-type');
        var pluginId = $(e.target).attr('data-plugin-id');
        
        var name = $('.' + this.cid + ' input[name="asset_name"][data-asset-type="' + assetType + '"]').val();
        
        if (!name) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        this.assetModel = new Wat.Models.Asset({
            name: name,
            assetType: assetType
        });
        
        this.assetModel.save().complete(
            function (e) {
                that.uploadAsset(that.assetModel.id, assetType, pluginId);
            }
        );
    },
    
    uploadAsset: function (assetId, assetType, pluginId) {
        var that = this;
        
        this.assetFileModel = new Wat.Models.AssetFile({
            id: assetId
        });
        
        var file = $('.' + this.cid + ' input[name="asset_file"][data-asset-type="' + assetType + '"]')[0].files[0];
        
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
                assetType: assetType,
                pluginId: pluginId,
                afterRender: function () {
                    // Select uploaded element
                    $('.' + that.cid + ' [data-id="' + assetId + '"]>td>input.js-asset-check').trigger('click');
                }
            });
            
            Wat.I.M.showMessage({message: i18n.t('Successfully uploaded'), messageType: 'success'});
            
            // Hide upload control
            $('.js-hide-upload[data-asset-type="' + assetType + '"]').trigger('click');
        });
    },
    
    deleteAsset: function (e) {
        var that = this;
        
        var assetType = $(e.target).attr('data-asset-type');
        var pluginId = $(e.target).attr('data-plugin-id');
        var id = $(e.target).attr('data-id');
        
        var assetModel = new Wat.Models.Asset({
            id: id
        });
        
        assetModel.destroy({
            success: function () {
                that.renderAssetsControl({ 
                    assetType: assetType,
                    pluginId: pluginId,
                    afterRender: function () {
                        // Select uploaded element
                        $('table[data-asset-type] input[name="' + assetType + '"]:first-child').trigger('click');
                    }
                });
                
                Wat.I.M.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'});
            },
            error: function () {
                Wat.I.M.showMessage({message: i18n.t('Error deleting'), messageType: 'error'});
            }
        });
    },
    
    changeAssetSelector: function (e) {
        var opt = $(e.target).find('option:checked');
        
        Wat.DIG.updateAssetPreview(opt);
    },
    
    clickAssetName: function (e) {
        // Select this script
        $(e.target).parent().find('input[type="radio"]').trigger('click');
    }
});