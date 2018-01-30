Wat.Views.RoleEditorView = Wat.Views.AdministratorRoleEditorView.extend({
    qvdObj: 'role',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.AdministratorRoleEditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'click .js-assign-template-button': 'addTemplate',
        'click .js-delete-template-button': 'deleteTemplate',
        'click .js-templates-matrix-mode-btn': 'openMatrixMode',
        'change .js-add-template-button': 'changeMatrixACL'
    },
    
    render: function (target, that) {
        Wat.Views.EditorView.prototype.render.apply(this, [target, that]);
        
        this.fetchAndRenderRolesAndTemplates();
    },
    
    renderCreate: function (target, that) {
        Wat.CurrentView.model = new Wat.Models.Role();
        $('.ui-dialog-titlebar').html($.i18n.t('New Role'));
        
        Wat.Views.AdministratorRoleEditorView.prototype.renderCreate.apply(this, [target, that]);
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit Role') + ": " + this.model.get('name'));
    },
    
    renderMassiveUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderMassiveUpdate.apply(this, [target, that]);
        
        // Empty roles from aux model to avoid show any role in massive editor
        if (Wat.CurrentView.model) {
            Wat.CurrentView.model.set('roles',{});
        }
        
        this.fetchAndRenderRolesAndTemplates();
    },
    
    fetchAndRenderRolesAndTemplates: function () {
        switch (Wat.CurrentView.viewKind) {
            case 'list':
                // Editing one element from list view
                var elementId = Wat.CurrentView.selectedItems[0];
                break;
            case 'details':
                // Editing from details view
                var elementId = Wat.CurrentView.model.get('id');
                break;
        }
        
        
        // In a role edition form must not appear role itself
        var options = {
            avoidRoleId: elementId
        };
        
        this.fetchAndRenderRoles(options);
        this.fetchAndRenderTemplates();
    },
    
    createElement: function () {
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        
        var args = {
            "name": name
        };
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        if (Wat.C.checkACL('role.update.assign-role')) {
            var assignTotal = [];
            
            if (this.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(this.assignRoles);
            }
            
            if (this.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(this.assignTemplates);
            }
            
            if (assignTotal.length > 0) {
                args["__roles__"] = assignTotal;
            }
        }
        
        // Go to first page and order by ID desc to got the last created element in first place
        Wat.CurrentView.collection.sort = {"field": "id", "order": "-desc"};
        $('div.pagination>.first').trigger('click');
        
        Wat.CurrentView.createModel(args, Wat.CurrentView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": Wat.CurrentView.id};
        var args = {};
        
        if (Wat.C.checkACL('role.update.name')) {
            args['name'] = name;
        }
        
        if (Wat.C.checkACL('role.update.description')) {
            args["description"] = description;
        }
        
        if (Wat.C.checkACL('role.update.assign-role')) {
            var assignTotal = [];
            var unassignTotal = [];
            
            if (this.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(this.assignRoles);
            }
            
            if (this.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(this.assignTemplates);
            }
            
            if (this.unassignRoles.length > 0) {
                unassignTotal = unassignTotal.concat(this.unassignRoles);
            }
            
            if (this.unassignTemplates.length > 0) {
                unassignTotal = unassignTotal.concat(this.unassignTemplates);
            }
            
            if (assignTotal.length > 0 || unassignTotal.length > 0) {
                args["__roles_changes__"] = {};
                
                if (assignTotal.length > 0) {
                    args["__roles_changes__"].assign_roles = assignTotal;
                }
                
                if (unassignTotal.length > 0) {
                    args["__roles_changes__"].unassign_roles = unassignTotal;
                }
            }
        }
        
        Wat.CurrentView.updateModel(args, filters, Wat.CurrentView.fetchAny);
    },
    
    updateMassiveElement: function (dialog, id) {
        var args = {};
        
        if (Wat.C.checkACL('role.update.description')) { 
            var description = $('textarea[name="description"]').val();
            args["description"] = description;
        }
        
        if (Wat.C.checkACL('role.update.assign-role')) {
            var assignTotal = [];

            if (this.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(this.assignRoles);
            }
            
            if (this.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(this.assignTemplates);
            }

            if (assignTotal > 0) {
                args["__roles_changes__"] = {
                    assign_roles: assignTotal
                }
            }
        }
        
        Wat.CurrentView.resetSelectedItems();
        
        var filters = {id: id};
        
        var auxModel = new Wat.Models.Role();
        
        Wat.CurrentView.updateModel(args, filters, Wat.CurrentView.fetchAny, auxModel);
    },
    
    fetchAndRenderTemplates: function () {
        $('.bb-assign-templates').html(HTML_MID_LOADING);
        
        var that = this;
        
        // Render templates matrix
        Wat.A.performAction('role_get_list', {}, {internal: "1"}, {}, function (that) {
            var currentTemplates = [];
            
            if (that.model && that.model.get('roles')) {
                var currentTemplates = that.model.get('roles');
            }
            var templates = that.retrievedData.rows;

            that.editorTemplates = {};
            // Create an object with templates including inherited flag
            $.each (templates, function (i, template) {
                that.editorTemplates[template.name] = template;
                
                if (currentTemplates[template.id]) {
                    that.editorTemplates[template.name].inherited = 1;
                }
                else {
                    that.editorTemplates[template.name].inherited = 0;
                }
            });
            
            // Create structure to store editor variables
            that.assignTemplates = [];
            that.unassignTemplates = [];
            
            that.renderTemplates();
        }, that, ['id', 'name']);
    },
    
    renderTemplates: function () {
        var template = _.template(
            Wat.TPL.inheritanceToolsTemplates, {
                templates: this.editorTemplates
            }
        );

        $('.bb-assign-templates').html(template);
        
        if (Object.keys(this.editorTemplates).length == this.countInheritedTemplates) {
            $('.js-assign-template-control').hide();
        }
        else {
            $('.js-assign-template-control').show();
        }
        
        Wat.I.chosenElement('select[name="template_to_be_assigned"]', 'advanced100');

        Wat.T.translate();
    },
    
    editorAssignTemplate: function (templateId) {
        var that = this;
        
        // If role was previously unassigned, delete from unassign array
        var unassignPos = $.inArray(templateId, this.unassignTemplates);
        
        if (unassignPos != -1) {
            this.unassignTemplates.splice(unassignPos, 1);
        }
        else {
            // Add to assign array
            this.assignTemplates.push(templateId);
        }
        
        // Set as inherited on data structure used to render editor
        this.countInheritedTemplates = 0;
        
        $.each(this.editorTemplates, function (iTemplate, template) {
            if (template.id == templateId) {
                that.editorTemplates[iTemplate].inherited = 1;
            }
            
            if (that.editorTemplates[iTemplate].inherited) {
                that.countInheritedTemplates++;
            }
        });
        
        this.renderTemplates();
    },
    
    editorDeleteTemplate: function (templateId) {
        var that = this;
        
        // If role was previously assigned, delete from assign array
        var assignPos = $.inArray(templateId, this.assignTemplates);
        
        if (assignPos != -1) {
            this.assignTemplates.splice(assignPos, 1);
        }
        else {
            // Add to unassign array
            this.unassignTemplates.push(templateId);
        }
        
        // Set as inherited on data structure used to render editor
        this.countInheritedTemplates = 0;
        
        // Set as inherited on data structure used to render editor
        $.each(this.editorTemplates, function (iTemplate, template) {
            if (template.id == templateId) {
                that.editorTemplates[iTemplate].inherited = 0;
            }
            
            if (that.editorTemplates[iTemplate].inherited) {
                that.countInheritedTemplates++;
            }
        });
        
        this.renderTemplates();
    },
    
    addTemplate: function (e) {
        var templateId = $('select[name="template_to_be_assigned"]').val();

        this.editorAssignTemplate(templateId);
    },

    deleteTemplate: function (e) {
        var templateId = $(e.target).attr('data-id');

        this.editorDeleteTemplate(templateId);
    },
    
    openMatrixMode: function (e) {
        var that = this;
        
        var dialogConf = {
            title: $.i18n.t('Matrix mode'),
            buttons : {
                "Close": function () {
                    Wat.I.closeDialog($(this));
                }
            },
            buttonClasses: ['fa fa-ban js-button-close'],

            fillCallback: function (target) {
                that.templatesEditorView = new Wat.Views.RoleTemplatesEditorView({ el: $(target) });
            }
        }

        Wat.CurrentView.matrixDialog = Wat.I.dialog(dialogConf);
    }
});