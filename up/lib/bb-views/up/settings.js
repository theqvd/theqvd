Up.Views.SettingsView = Up.Views.ListView.extend({  
    qvdObj: 'settings',
    loadSectionCallback: {
    },
    
    relatedDoc: {
    },
    
    settingsEvents: {
        'click .js-delete-workspace-btn': 'deleteWorkspace',
        'click .js-active-workspace-btn.js-button-activable': 'activeWorkspace',
        'click .js-button-settings-conf': 'editWorkspace',
        'click .js-button-settings-options': 'optionsWorkspace',
        'click .js-new-workspace-btn': 'newWorkspace',
        'click .js-clone-workspace-btn': 'cloneWorkspace',
        'click .js-back-settings-button': 'loadSettingsSection'
    },
    
    initialize: function (params) {
        this.collection = new Up.Collections.Workspaces(params);
                
        Up.Views.ListView.prototype.initialize.apply(this, [params]);        
        
        this.extendEvents(this.settingsEvents);
    },
    
    addListTemplates: function () {
        Up.Views.ListView.prototype.addListTemplates.apply(this, []);
        
        var templates = Up.I.T.getTemplateList('settings');
        this.templates = $.extend({}, this.templates, templates);        
    },
    
    renderList: function (that) {  
        var that = that || this;
        
        // Get actived model to know what model render
        that.activeModel = that.collection.where({active: true})[0];
        
        // List of settings
        var template = _.template(
            Up.TPL.settingsList, {
                cid: that.cid
            }
        );
        
        $('.bb-settings-list').html(template); 

        that.renderWorkspacesConfig();
        
        // Load edition mode on active model
        if (that.activeModel) {
            var activeId = that.activeModel.get('id');
        }
                
        Up.T.translateAndShow();
    },
        
    renderWorkspacesConfig: function () {
        this.template = _.template(
            Up.TPL.settingsRow, {
                cid: this.cid,
                collection: this.collection
            }
        );
        
        $('.bb-settings-workspaces').html(this.template); 
        
        Up.I.addOddEvenRowClass('.bb-settings-list');
    },
    
    // Workspace options
    renderWorkspaceOptions: function (model) {
        // List of settings
        var template = _.template(
            Up.TPL.settingsOptions, {
                model: model,
                canBeDisabled: typeof model.get('settings_enabled') != 'undefined'
            }
        );
        
        $('.bb-settings-list').html(template);
        
        Up.I.chosenElement($('select[name="connection"]'), 'single100');
        
        Up.T.translate();
    },
    
    optionsWorkspace: function (e) {
        var selectedId = parseInt($(e.target).attr('data-id'));
        
        var model = this.collection.where({id: selectedId})[0];
        
        $('.js-section-sub-title').html(model.get('name'));

        this.renderWorkspaceOptions(model);
    },
    
    loadSettingsSection: function (e) {
        this.renderList();
    }
});