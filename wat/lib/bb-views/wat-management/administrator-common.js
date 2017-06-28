// Common lib for Administrator views (list and details)
Wat.Common.BySection.administrator = {
    editorViewClass: Wat.Views.AdminEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonAdministrator');
        
        this.templates = $.extend({}, this.templates, templates);
        
        // Extend view with common methods with Role views
        $.extend(that, Wat.Common.BySection.administratorRole);
    }
}