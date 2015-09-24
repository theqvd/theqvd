Wat.Views.MyViewsView = Wat.Views.ViewsView.extend({
    setupOption: 'views',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    
    qvdObj: 'myviews',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'My views'
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
                
        var templates = Wat.I.T.getTemplateList('viewsMine');
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    getDataAndRender: function () {
        // Get filters and columns
        this.currentFilters = Wat.I.getFormFilters(this.selectedSection);
        this.currentColumns = Wat.I.getListColumns(this.selectedSection);
        
        this.renderForm();
    },
    
    // Perform the reset action on DB and update interface
    performResetViews: function () {
        var sectionReset = $('[name="section_reset"]:checked').val();
        
        var filter = {};
        
        if (sectionReset) {
            filter.qvd_object = sectionReset;
        }
        
        Wat.A.performAction('admin_view_reset',{},filter,{}, function (that) {
            // Show message with result
            that.showViewsMessage(that.retrievedData);
            
            // Get admin setup configuration to get the views updated
            Wat.A.performAction('current_admin_setup', {}, VIEWS_COMBINATION, {}, function () {
                // Restore possible residous views configuration to default values
                Wat.I.restoreListColumns();
                Wat.I.restoreFormFilters();

                // Store views configuration
                Wat.C.storeViewsConfiguration(that.retrievedData.views);

                that.getDataAndRender();
            }, that);
        }, this);
    },
    
    fillResetViewsEditor: function (target) {
        var qvdObj = $('[name="obj-qvd-select"]').val();
        var qvdObjName = $('[name="obj-qvd-select"] option:selected').html();
        
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        var template = _.template(
                    Wat.TPL.resetViewsMine, {
                        qvdObj: qvdObj,
                        qvdObjName: qvdObjName,
                    }
                );
        
        target.html(template);  
        
        Wat.I.chosenElement('[name="section_reset"]', 'single100');
    },
});