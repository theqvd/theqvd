Wat.Views.OSDAssetsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'change .js-asset-selector': 'changeAssetSelector',
        'click .js-script-name': 'clickScriptName',
        'click .input[type="radio"][name="script"]': 'changeAssetSelector',
        'click .js-upload-script': 'uploadScript',
        'click .js-toggle-upload-select-mode': 'toggleUploadSelectMode'
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        Wat.Views.DialogView.prototype.render.apply(this);
        var template = _.template(
            Wat.TPL.osConfigurationEditorScriptsManager, {
                massive: false,
                model: Wat.CurrentView.OSDmodel,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook'),
                assetType: 'script',
                cid: this.cid
            }
        );

        $(this.el).html(template);
        
        $('.js-upload-mode').hide();
        
        Wat.CurrentView.editorView.softwareEditorView.renderAssetsControl({
            assetType: 'script',
            pluginId: 'execution_hooks'
        });
        
        Wat.I.chosenElement('.js-starting-script-mode', 'single100');
        
        Wat.T.translate();
    },
    
    changeAssetSelector: function (e) {
        Wat.DIG.changeAssetSelector(e);
    },
    
    clickScriptName: function (e) {
        // Select this script
        $(e.target).parent().find('input[type="radio"]').trigger('click');
    },
    
    uploadScript: function (e) {
        var file = $('input[name="script_file"]')[0].files[0];
        
        if (!file) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var fileName = $('input[name="script_file"]').val();
        
        var uploadedScript = {
            name: fileName,
            url: fileName
        };
        
        Wat.CurrentView.OSDmodel.pluginDef.where({code: 'execution_hooks'})[0].attributes.plugin.script.list_files[55] = uploadedScript;
        
        this.toggleUploadSelectMode();
        
        Wat.CurrentView.editorView.softwareEditorView.renderSectionScripts();
    },
    
    toggleUploadSelectMode: function (e) {
        $('.js-upload-mode, .js-select-mode').toggle();
        $('.js-preview img').toggle();
    }
});