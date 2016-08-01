Up.Views.SettingsView = Up.Views.SettingsProtoView.extend({  
    qvdObj: 'settings',
    
    relatedDoc: {
    },
    
    settingsEvents: {
        'click .js-active-workspace-button': 'activeWorkspace',
        'click .js-button-settings-conf': 'editWorkspace',
        'click .js-new-workspace-btn': 'newWorkspace',
        'click .js-clone-workspace-btn': 'cloneWorkspace'
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();

        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        this.extendEvents(this.settingsEvents);

        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="settings"]').addClass('menu-option--current');

        var templates = Up.I.T.getTemplateList('settings');
        this.loadFakeData();

        Up.A.getTemplates(templates, this.render, this); 
    },
    
    render: function () {        
        // Get actived model to know what model render
        this.activeModel = this.collectionWorkspaces.where({active: true})[0];
        
        // Fill the html with the template and the model
        this.template = _.template(
            Up.TPL.settings, {
                cid: this.cid
            }
        );
        
        $(this.el).html(this.template);
        
        // List of settings
        this.template = _.template(
            Up.TPL.settingsList, {
                cid: this.cid
            }
        );
        
        $('.bb-settings-list').html(this.template); 

        this.renderWorkspacesConfig();
        
        // Load edition mode on active model
        var activeId = this.activeModel.get('id');
                
        Up.T.translateAndShow();
    },
        
    renderWorkspacesConfig: function () {
        this.template = _.template(
            Up.TPL.settingsRow, {
                cid: this.cid,
                collection: this.collectionWorkspaces
            }
        );
        
        $('.bb-settings-workspaces').html(this.template); 
        
        Up.I.addOddEvenRowClass('.bb-settings-list');
    },
    
    activeWorkspace: function (e) {
        $('.js-active-workspace-button').removeClass('button button-active');
        $('.js-active-workspace-button').addClass('button2 button-activatable');
        
        $(e.target).removeClass('button2 button-activatable');
        $(e.target).addClass('button button-active');
    },
    
    editWorkspace: function (e) {
        var selectedId = $(e.target).attr('data-id');

        var model = this.collectionWorkspaces.where({id: parseInt(selectedId)})[0];

        var that = this;
        var dialogConf = {
            title: $.i18n.t('Edit Workspace') + ': ' + model.get('name'),
            buttons : {
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    model.set(params);
                    model.save();
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-save',
            fillCallback : function (target) { 
                that.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },   
    
    newWorkspace: function (e) {
        var selectedId = $(e.target).attr('data-id');

        var model = this.emptyWorkspace;

        var that = this;
        var dialogConf = {
            title: $.i18n.t('New Workspace'),
            buttons : {
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    // PROVISIONAL
                    params.id = Math.ceil(1000*Math.random());
                    
                    model.set(params);
                    
                    that.collectionWorkspaces.add(model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-save',
            fillCallback : function (target) { 
                that.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    
    cloneWorkspace: function (e) {
        var selectedId = $(e.target).attr('data-id');

        var model = this.collectionWorkspaces.where({id: parseInt(selectedId)})[0].clone();
        model.set({name: model.get('name') + ' (copy)', systemWS: false});

        var that = this;
        var dialogConf = {
            title: $.i18n.t('New Workspace'),
            buttons : {
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    // PROVISIONAL
                    params.id = Math.ceil(1000*Math.random());
                    
                    // New workspace is not active
                    params.active = false;
                    
                    model.set(params);
                    
                    that.collectionWorkspaces.add(model);
                    
                    Up.I.closeDialog($(this));
                    
                    that.render();
                }
            },
            button1Class : 'fa fa-save',
            fillCallback : function (target) { 
                that.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    }, 
});