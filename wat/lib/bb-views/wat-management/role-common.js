// Common lib for Role views (list and details)
Wat.Common.BySection.role = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonRole');
        
        this.templates = $.extend({}, this.templates, templates);
        
        // Extend view with common methods with Role views
        $.extend(that, Wat.Common.BySection.administratorRole);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
                
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": this.id};
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
            
            if (that.assignRoles.length > 0) {
                assignTotal = assignTotal.concat(that.assignRoles);
            }          
            
            if (that.assignTemplates.length > 0) {
                assignTotal = assignTotal.concat(that.assignTemplates);
            }    
            
            if (that.unassignRoles.length > 0) {
                unassignTotal = unassignTotal.concat(that.unassignRoles);
            }    
            
            if (that.unassignTemplates.length > 0) {
                unassignTotal = unassignTotal.concat(that.unassignTemplates);
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
        
        this.updateModel(args, filters, this.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }     
        
        this.dialogConf.title = $.i18n.t('Edit Role') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    fillEditor: function (target, that) {
        Wat.Views.MainView.prototype.fillEditor.apply(this, [target, that]);
        
        switch (that.viewKind) {
            case 'list':
                // Editing one element from list view
                var elementId = that.selectedItems[0];
                break;
            case 'details':
                // Editing from details view
                var elementId = that.model.get('id');
                break;
        }
        
        
        // In a role edition form must not appear role itself
        var options = {
            avoidRoleId: elementId
        };
        
        that.fetchAndRenderRoles(options);
        that.fetchAndRenderTemplates();
    },
    
    fetchAndRenderTemplates: function () {
        $('.bb-assign-templates').html(HTML_MID_LOADING);
        
        var that = this;
        
        // Render templates matrix
        Wat.A.performAction('role_tiny_list', {}, {internal: "1"}, {}, function (that) {
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
        }, that);
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
    }
}