// Common lib for OSF views (list and details)
Wat.Common.BySection.osf = {
    editorViewClass: Wat.Views.OSFEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('osDetails');
        
        this.templates = $.extend({}, this.templates, templates);
    },
}