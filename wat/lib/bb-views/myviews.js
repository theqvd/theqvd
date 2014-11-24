Wat.Views.MyViewsView = Wat.Views.ViewsView.extend({
    setupOption: 'views',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    
    qvdObj: 'user',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Customize views'
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
        
        // Get filters and columns
        this.currentFilters = Wat.I.getFormFilters(this.selectedSection);
        this.currentColumns = Wat.I.getListColumns(this.selectedSection);
        
        this.render();
    }
});