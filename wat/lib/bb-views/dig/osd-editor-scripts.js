Wat.Views.OSDScriptsEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-open-script-manager': 'openAssetManager',
        'change .js-starting-script-mode': 'changeScriptMode',
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorScripts, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook'),
                cid: this.cid
            }
        );

        $('.bb-os-conf-scripts').html(template);
        
        this.renderAssetsControl({
            assetType: 'script',
            pluginId: 'execution_hooks'
        });
        
        this.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'));
    },
    
    renderSectionScriptsRows: function (scripts) {
        // Render rows with existent scripts
        var rows = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: scripts,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook')
            }
        );

        $('table.js-scripts-list').html(rows);
        Wat.I.chosenElement('.js-starting-script-mode', 'single100');
        
        Wat.T.translate();
    },
    
    openAssetManager: function (e) {
        var that = this;
        
        var dialogConf = {
            title: "Asset manager",
            buttons : {
                "Cancel": function () {
                    Wat.I.closeDialog($(this));
                    
                    that.ScriptsDialogView.remove();
                    delete that.ScriptsDialogView;
                    
                    $('.ui-dialog-secondary').eq(0).css('z-index','1003');
                },
                "Add": function () {
                    var those = this;
                    that.addScript(function () {
                        Wat.I.closeDialog($(those));
                    
                        that.ScriptsDialogView.remove();
                        delete that.ScriptsDialogView;
                        
                        $('.ui-dialog-secondary').eq(0).css('z-index','1003');
                    });
                }
            },
            buttonClasses: ['fa fa-ban js-button-close','fa fa-plus-circle js-button-add'],

            fillCallback: function (target) {
                that.ScriptsDialogView = new Wat.Views.OSDAssetsEditorView({
                    el: $(target),
                    massive: false,
                    osdId: Wat.CurrentView.OSDmodel.id
                });
            },
        }

        Wat.CurrentView.editorView.softwareEditorView.scriptsDialog = Wat.I.dialog(dialogConf);

        // Add secondary dialog class to new dialog to give different look
        //Wat.CurrentView.editorView.softwareEditorView.scriptsDialog.parent().addClass('ui-dialog-secondary');
        Wat.CurrentView.editorView.softwareEditorView.scriptsDialog.dialog("option", "position", {my: "center", at: "center", of: window});
        // Send primary dialog to back because jquery ui doesnt handle it properly
        $('.ui-dialog-secondary').eq(0).css('z-index','1001');
    },
    
    addScript: function (finishCallback) {
        var id = $('input[name="script"]:checked').val();
        
        if (!id) {
            Wat.I.M.showMessage({message: 'Nothing to do', messageType: 'info'});
            return;
        }
        
        var row = $('tr[data-control-id][data-id="' + id + '"]');
        
        var fileName = $(row).attr('data-name');
        var execution_hook = $('.js-starting-script-mode[data-new-file]').val();

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {
                name: fileName,
                hook: execution_hook
            }
        }, this.afterAddScript, finishCallback);
    },
    
    afterAddScript: function (e) {
        // Mock
        var id = $('input[name="script"]:checked').val();
        var row = $('tr[data-control-id][data-id="' + id + '"]');
        var fileName = $(row).attr('data-name');
        var execution_hook = $('.js-starting-script-mode[data-new-file]').val();
        // End mock
        
        // Add starting script row
        var newRow = _.template(
            Wat.TPL.osConfigurationEditorScriptsRows, {
                scripts: [{
                    id: id,
                    name: fileName,
                    execution_hook : execution_hook
                }],
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook')
            }
        );

        Wat.CurrentView.OSDmodel.attributes.scripts.push({
            id: id,
            name: fileName,
            execution_hook : execution_hook
        });
        
        Wat.CurrentView.editorView.softwareEditorView.sectionScriptsView.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'));

        $('.js-starting-script').val('');
    },
    
    deleteScript: function (e) {
        var id = $(e.target).attr('data-id');
        
        // Delete script from stored scripts (just for mock)
        var storedScripts = Wat.CurrentView.OSDmodel.get('scripts');
        
        var deletedScriptIndex = -1;
        $.each(storedScripts, function (i, v) {
            if (v.id == id) {
                deletedScriptIndex = i;
            }
        });
        
        if (deletedScriptIndex > -1) {
            storedScripts.splice(deletedScriptIndex, 1);
        }
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {id: id}
        }, this.afterDeleteScript, function () {});
    },
    
    afterDeleteScript: function (e) {
        var scripts = Wat.CurrentView.OSDmodel.get('scripts');
        Wat.CurrentView.editorView.softwareEditorView.sectionScriptsView.renderSectionScriptsRows(scripts);
    },
    
    changeScriptMode: function (e) {
        var newMode = $(e.target).val();
        var id = $(e.target).attr('data-id');

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'execution_hooks',
            osdId: this.params.osdId,
            attributes: {
                id: id,
                mode: newMode
            }
        }, function () {}, function () {});
    },

});