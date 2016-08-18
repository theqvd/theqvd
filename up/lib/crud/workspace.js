// Workspaces CRUD functions
Up.CRUD.workspaces = {
    activeWorkspace: function (e, model, afterCallback) {
        if (e) {
            var selectedId = parseInt($(e.target).attr('data-id'));
        }
        var afterCallback = afterCallback || Up.CurrentView.render;
        
        var model = model || Up.CurrentView.collection.where({id: selectedId})[0];
        
        var params = {'active': true};
        model.set(params);
        
        var messages = {
            'success': 'Workspace activated successfully',
            'error': 'Error activating Workspace'
        };
                    
        Up.CurrentView.saveModel({id: model.get('id')}, params, messages, afterCallback, model, 'update');
    },  
    
    deleteWorkspace: function (e) {
        Up.I.confirm('dialog/confirm-undone', this.applyDeleteWorkspace, e);
    },
    
    applyDeleteWorkspace: function (e) {
        var selectedId = parseInt($(e.target).attr('data-id'));
        
        var model = Up.CurrentView.collection.where({id: selectedId})[0];
        
        Up.CurrentView.deleteModel({id: model.get('id')}, Up.CurrentView.render, model);
    },
    
    editWorkspace: function (e) {
        var selectedId = parseInt($(e.target).attr('data-id'));
        
        var model = this.collection.where({id: selectedId})[0];

        var that = this;
        var dialogConf = {
            title: $.i18n.t('Edit Workspace') + ': ' + model.get('name'),
            buttons : {
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.updateModel({id: model.get('id')}, params, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    }, 
    
    optionsWorkspace2: function (e) {
        var selectedId = parseInt($(e.target).attr('data-id'));
        
        var model = this.collection.where({id: selectedId})[0];
        
        Up.CurrentView.renderWorkspaceOptions(model, $('.bb-content'));
        Up.T.translate();
        return;

        var that = this;
        var dialogConf = {
            title: $.i18n.t('Workspace options') + ': ' + model.get('name'),
            buttons : {
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.updateModel({id: model.get('id')}, params, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.CurrentView.renderWorkspaceOptions(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },   
    
    newWorkspace: function (e, model) {
        var model = model || new Up.Models.Workspace();
        
        var that = this;
        var dialogConf = {
            title: $.i18n.t('New Workspace'),
            buttons : {
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.createModel({id: model.get('id')}, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },
    
    
    cloneWorkspace: function (e) {
        var selectedId = $(e.target).attr('data-id');
        
        var model = Up.CurrentView.collection.where({id: parseInt(selectedId)})[0].clone();
        model.set({name: model.get('name') + ' (copy)', fixed: false});
        
        Up.CurrentView.newWorkspace(e, model);
    },
    
    firstEditWorkspace: function (model) {
        var that = this;
        var dialogConf = {
            title: $.i18n.t('First Workspace configuration') + ': ' + model.get('name'),
            buttons : {
                "Cancel": function () {
                    // If cancel, check previous workspace active as actived
                    var modelActive = Up.CurrentView.wsCollection.where({active: 1})[0];
                    
                    $('[name="active_configuration_select"]').val(modelActive.get('id'));
                    $('[name="active_configuration_select"]').trigger('chosen:updated');
                    
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.saveModel({id: model.get('id')}, params, {}, function () {
                        Up.CurrentView.activeWorkspace(null, model, function() {});
                    }, model, 'update');
                    
                    Up.I.closeDialog($(this));
                }
            },
            button1Class : 'fa fa-ban',
            button2Class : 'fa fa-save',
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
            },
        }

        Up.I.dialog(dialogConf);
    },   
}