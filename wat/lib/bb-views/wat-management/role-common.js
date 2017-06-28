// Common lib for Role views (list and details)
Wat.Common.BySection.role = {
    editorViewClass: Wat.Views.RoleEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonRole');
        
        this.templates = $.extend({}, this.templates, templates);
        
        // Extend view with common methods with Role views
        $.extend(that, Wat.Common.BySection.administratorRole);
    },
}