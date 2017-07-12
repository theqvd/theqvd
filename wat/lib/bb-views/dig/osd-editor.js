Wat.Views.OSDEditorView = Wat.Views.DialogView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
        'click .js-os-editor-menu li': 'clickOSEditorMenu',
        'click .js-add-shortcut': 'addShortcut',
        'click .js-delete-shortcut': 'deleteShortcut',
        'click .js-update-shortcut': 'updateShortcut',
        'click .js-button-show-shortcut-details': 'toggleShortcutConfiguration',
        'change input[type="checkbox"][js-autosave-field]': 'autoSaveCheck',
        'change .js-starting-script-mode': 'changeScriptMode',
        'click .js-open-script-manager': 'openAssetManager',
        'change .js-asset-selector': 'changeAssetSelector',
        'click .input[type="radio"][name="wallpaper"]': 'changeAssetSelector',
        'click .js-wallpaper-name': 'clickWallpaperName',
        'click .js-toggle-upload-select-mode': 'toggleUploadSelectMode',
        'click .js-upload-wallpaper': 'uploadWallpaper'
    },
    
    ////////////////////////////////////////////////////
    // Functions for render
    ////////////////////////////////////////////////////
    
    render: function () {
        Wat.Views.DialogView.prototype.render.apply(this);
        
        // Add common parts of editor to dialog
        var template = _.template(
            Wat.TPL.osConfigurationEditor, {
                osfId: this.params.osfId,
                massive: this.params.massive
            }
        );
        
        $(this.el).html(template);
        
        // Render sections
        this.renderSectionAppearence();
        this.renderSectionPackages();
        this.renderSectionShortcuts();
        this.renderSectionSettings();
        this.renderSectionScripts();

        Wat.I.chosenElement('select.js-app-to-shortcut', 'single100');
        
        Wat.T.translate();
    },
    
    renderSectionAppearence: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorAppearance, {
                massive: this.massive,
                assetType: 'wallpaper'
            }
        );

        $('.bb-os-conf-appearance').html(template);
        
        this.renderAssetsControl({
            assetType: 'wallpaper',
            pluginId: 'desktop'
        });
        
        $('.js-upload-mode').hide();
    },
    
    renderSectionPackages: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorPackages, {
                massive: this.massive
            }
        );
        
        $('.bb-os-conf-packages').html(template);
        
        this.renderPackages();
    },
    
    renderPackages: function() {
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-packages-wrapper';
        params.forceListActionButton = null;

        params.forceSelectedActions = {};
        params.block = 5;
        params.filters = {"tenant_id": this.elementId};
        Wat.CurrentView.embeddedViews = Wat.CurrentView.embeddedViews || {};
        
        Wat.CurrentView.embeddedViews.package = new Wat.Views.PackageListView(params);
        
        $.each (Wat.CurrentView.embeddedViews.package.events, function (actionSelector, func) {
            actionSelector = actionSelector.split(' ');
            var action = actionSelector.shift();
            var selector = actionSelector.join(' ');
            e = {
                target: $(selector)
            };
            Wat.B.bindEvent(action, selector, $.proxy(Wat.CurrentView.embeddedViews.package[func], Wat.CurrentView.embeddedViews.package), e);
        });
    },
    
    renderSectionShortcuts: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcuts, {
                settings: Wat.CurrentView.settings,
                apps: Wat.CurrentView.apps,
                massive: this.massive
            }
        );

        $('.bb-os-conf-shortcuts').html(template);

        // Render rows with existent shortcuts
        var template = _.template(
            Wat.TPL.osConfigurationEditorShortcutsRows, {
                shortcuts: Wat.CurrentView.OSDmodel.get('shortcuts')
            }
        );

        $('.bb-os-conf-shortcuts-rows').html(template);
    },
    
    renderSectionSettings: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorSettings, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel
            }
        );

        $('.bb-os-conf-settings').html(template);
    },
    
    renderSectionScripts: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorScripts, {
                massive: this.massive,
                model: Wat.CurrentView.OSDmodel,
                hookOptions: Wat.CurrentView.OSDmodel.getPluginAttrSettingOptions('execution_hooks.script.hook')
            }
        );

        $('.bb-os-conf-scripts').html(template);
        
        this.renderAssetsControl({
            assetType: 'script',
            pluginId: 'execution_hooks'
        });
        
        this.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'));
    },
    
    renderAssetsControl: function (opts) {
        var assets = new Wat.Collections.Assets(null, {
            filter: {
                type: opts.assetType
            } 
        });
        assets.fetch({
            complete: function () {
                var template = _.template(
                    Wat.TPL.osConfigurationEditorAssetOptions, {
                        models: assets.models,
                        assetType: opts.assetType,
                        pluginId: opts.pluginId
                    }
                );
                
                $('.bb-os-conf-' + opts.assetType + '-assets').html(template);
                
                // Select first radio button
                $('input[type="radio"][name="' + opts.assetType + '"]').eq(0).trigger('click');
            }
        });
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
    
    ////////////////////////////////////////////////////
    // Functions for menu
    ////////////////////////////////////////////////////
    
    clickOSEditorMenu: function (e) {
        target = $(e.target).attr('data-target') || $(e.target).parent().attr('data-target');
        $('li.lateral-menu-option').removeClass('lateral-menu-option--selected');
        $('li.js-lateral-menu-sub-div').hide();
        $('.js-os-editor-panel').hide();


        $('li.lateral-menu-option[data-target="' + target + '"]').addClass('lateral-menu-option--selected');
        $('li.js-lateral-menu-sub-div[data-from-menu="' + target +'"]').show();
        $('.js-os-editor-panel[data-target="' + target + '"]').show();
    },
    
    ////////////////////////////////////////////////////
    // Functions for shortcuts
    ////////////////////////////////////////////////////
    
    addShortcut: function (e) {
        var command = $('input[name="shortcut_command"]').val();
        var name = $('input[name="shortcut_name"]').val();
        var defaultIconUrl = "http://icons.iconarchive.com/icons/custom-icon-design/flatastic-11/256/Application-icon.png";
        
        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {
                name: name,
                icon_url: defaultIconUrl,
                command: command
            }
        }, this.afterAddShortcut, function () {});
    },
    
    afterAddShortcut: function (e) {
        var response = JSON.parse(e.responseText);
        
        // Mock
        var command = $('input[name="shortcut_command"]').val();
        var name = $('input[name="shortcut_name"]').val();
        var defaultIconUrl = "http://icons.iconarchive.com/icons/custom-icon-design/flatastic-11/256/Application-icon.png";

        var newShortcut = {
            name: name,
            icon_url: defaultIconUrl,
            command: command,
            id: btoa(command + name)
        };
        // End Mock
        
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
    
    updateShortcut: function (e) {
        var id = $(e.target).attr('data-id');

        var newName = $('.js-editor-row input[name="shortcut_name"]').val();
        var newCommand = $('.js-editor-row input[name="shortcut_command"]').val();
        var newIcon = $('.js-editor-row input[name="shortcut_icon"]').val();

        // Update visible data
        $('.js-shortcut-row[data-id="' + id + '"] .js-shortcut-name').html(newName);
        $('.js-shortcut-row[data-id="' + id + '"] .js-shortcut-command').html(newCommand);
        $('.icon-bg[data-id="' + id + '"]').css('background-image','url(' + newIcon + ')');

        // Update hidden forms
        $('[data-form-field-name="name"]').val(newName);
        $('[data-form-field-name="command"]').val(newCommand);
        $('[data-form-field-name="icon_url"]').val(newIcon);

        $('.js-button-show-shortcut-details[data-id="' + id + '"]').trigger('click');

        // Save plugin element
        Wat.DIG.setPluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {
                id: id,
                name: newName,
                command: newCommand,
                newIcon:  newIcon
                
            }
        }, function () {}, function () {});
    },
    
    deleteShortcut: function (e) {
        var id = $(e.target).attr('data-id');
        $('.js-shortcut-row[data-id="' + id + '"]').remove();
        $('.js-editor-row[data-id="' + id + '"]').remove();
        
        // Delete plugin element
        Wat.DIG.deletePluginListElement({
            pluginId: 'shortcuts',
            osdId: this.params.osdId,
            attributes: {id: id}
        }, function () {}, function () {});
    },
    
    toggleShortcutConfiguration: function (e) {
        if ($(e.target).hasClass('disabled')) {
            return;
        }

        var id = $(e.target).attr('data-id');

        // Toggle icons
        if ($(e.target).hasClass('fa-chevron-down')) {
            $(e.target).removeClass('fa-chevron-down').addClass('fa-chevron-up');
        }
        else {
            $(e.target).removeClass('fa-chevron-up').addClass('fa-chevron-down');
        }

        // Toggle rows
        $('tr.js-editor-row[data-id="' + id + '"]').toggle();
    },
    
    ////////////////////////////////////////////////////
    // Functions for scripts
    ////////////////////////////////////////////////////
        
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
        
        Wat.CurrentView.editorView.softwareEditorView.renderSectionScriptsRows(Wat.CurrentView.OSDmodel.get('scripts'));

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
        Wat.CurrentView.editorView.softwareEditorView.renderSectionScriptsRows(scripts);
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
    
    ////////////////////////////////////////////////////
    // Functions for single controls
    ////////////////////////////////////////////////////
    
    autoSaveCheck: function (e) {
        var that = this;
    
        var name = $(e.target).attr('name');
        var checked = $(e.target).is(':checked');
        
        var [pluginId, attrName] = name.split('.');
        
        // Save distro id
        var attributes = {};
        attributes['id'] = attrName;
        attributes[attrName] = checked;
        
        Wat.DIG.setPluginAttr({
            pluginId: pluginId,
            attributes: attributes
        }, function () {}, function () {});
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
                this.ScriptsDialogView = new Wat.Views.OSDScriptsEditorView({
                    el: $(target),
                    //osfId: osfId,
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
        
        Wat.CurrentView.OSDmodel.pluginDef.where({plugin_id: 'desktop'})[0].attributes.plugin.wallpaper.list_images[55] = uploadedWallpaper;
        
        this.toggleUploadSelectMode();
        
        Wat.CurrentView.editorView.softwareEditorView.renderSectionAppearence();
    }
});