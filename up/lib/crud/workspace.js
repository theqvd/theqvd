// Workspaces CRUD functions
Up.CRUD.workspaces = {
    activeWorkspace: function (model, afterCallback) {
        var params = {'active': 1};
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
                "Reset form": function () {
                    Up.I.resetForm(this);
                },
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var valid = Up.I.validateForm('.editor-container.' + that.cid);
                    
                    if (!valid) {
                        return;
                    }
                    
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.updateModel({id: model.get('id')}, params, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            buttonClasses : [CLASS_ICON_RESET, CLASS_ICON_CANCEL, CLASS_ICON_SAVE],
            fillCallback : function (target) { 
                Up.I.renderEditionMode(model, target);
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
                "Reset form": function () {
                    Up.I.resetForm(this);
                },
                "Cancel": function () {
                    // Close dialog
                    Up.I.closeDialog($(this));
                },
                "Save": function () {
                    var valid = Up.I.validateForm('.editor-container.' + that.cid);
                    
                    if (!valid) {
                        return;
                    }
                    
                    var params = Up.I.parseForm(this);
                    
                    model.set(params);
                    
                    Up.CurrentView.createModel({id: model.get('id')}, Up.CurrentView.render, model);
                    
                    Up.I.closeDialog($(this));
                }
            },
            buttonClasses : [CLASS_ICON_RESET, CLASS_ICON_CANCEL, CLASS_ICON_SAVE],
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
    }
}