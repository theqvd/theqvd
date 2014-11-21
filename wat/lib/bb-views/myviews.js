Wat.Views.MyViewsView = Wat.Views.ViewsView.extend({
    setupOption: 'views',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Personal area',
            'next': {
                'screen': 'Customize views'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
        
        // Get side menu
        this.sideMenu = {
            'profile': {
                icon: 'fa fa-user',
                link: '#profile',
                text: 'Profile'
            },
            'views': {
                icon: 'fa fa-columns',
                link: '#myviews',
                text: 'Customize views'
            }
        };
        
        // Get filters and columns
        this.currentFilters = Wat.I.getFormFilters(this.selectedSection);
        this.currentColumns = Wat.I.getListColumns(this.selectedSection);
        
        this.render();
    },
    
    renderForm: function () {
        // Get filters and columns
        this.currentFilters = Wat.I.getFormFilters(this.selectedSection);
        this.currentColumns = Wat.I.getListColumns(this.selectedSection);
        
        Wat.Views.ViewsView.prototype.renderForm.apply(this);
    }
});