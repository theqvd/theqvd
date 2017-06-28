Wat.Views.RoleTemplatesEditorView = Wat.Views.RoleEditorView.extend({
    initialize: function(params) {
        this.extendEvents(this.editorTemplateEvents);
        
        Wat.Views.RoleEditorView.prototype.initialize.apply(this, [params]);
        
        this.render();
    },
    
    editorTemplatesEvents: {
        'change .js-add-template-button': 'changeMatrixACL'
    },
    
    render: function (target, that) {
        //Wat.Views.EditorView.prototype.render.apply(this, [target, that]);
        
        var template = _.template(
            Wat.TPL.inheritanceToolsTemplatesMatrix, {
                templates: Wat.CurrentView.editorView.editorTemplates,
                cid: this.cid
            }
        );
        
        $(this.el).html(template);
    },


    changeMatrixACL: function (e) {
        var templateId = $(e.target).attr('data-role-template-id');
        var checked = $(e.target).is(':checked');

        if (checked) {
            $('select[name="template_to_be_assigned"]').val(templateId);
            $('.js-assign-template-button').trigger('click');
        }
        else {
            $('.js-delete-template-button[data-id="' + templateId + '"]').trigger('click');
        }
    },
});