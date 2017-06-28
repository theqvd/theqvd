// Common lib for VM views (list and details)
Wat.Common.BySection.vm = {
    editorViewClass: Wat.Views.VMEditorView,
    
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
    },
    
    spyVM: function (vmModel) {
        var vmModel = vmModel instanceof Backbone.Model ? vmModel : this.model;
        
        var target = window.location.origin + window.location.pathname + "#/vm/" + vmModel.get('id') + "/spy";
        window.open(target);
    },
}
