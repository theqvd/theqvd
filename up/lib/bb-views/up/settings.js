Up.Views.SettingsView = Up.Views.ListView.extend({  
    qvdObj: 'settings',
    
    relatedDoc: {
    },
    
    settingsEvents: {
        'click .js-delete-workspace-btn': 'deleteWorkspace',
        'click .js-active-workspace-btn': 'activeWorkspace',
        'click .js-button-settings-conf': 'editWorkspace',
        'click .js-new-workspace-btn': 'newWorkspace',
        'click .js-clone-workspace-btn': 'cloneWorkspace'
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
    
    renderList: function () {        
        // Get actived model to know what model render
        this.activeModel = this.collection.where({active: true})[0];
        
        // List of settings
        this.template = _.template(
            Up.TPL.settingsList, {
                cid: this.cid
            }
        );
        
        $('.bb-settings-list').html(this.template); 

        this.renderWorkspacesConfig();
        
        // Load edition mode on active model
        if (this.activeModel) {
            var activeId = this.activeModel.get('id');
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
});