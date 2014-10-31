Wat.Views.ProfileView = Wat.Views.ViewsView.extend({
    setupOption: 'views',
    
    limitByACLs: true,
    
    setAction: 'admin_view_set',
    
    viewKind: 'admin',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Personal area'
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
        
        // Get side menu
        this.sideMenu = {
            'password': {
                iconClass: 'fa fa-user',
                link: '#',
                text: 'My profile'
            },
            'password': {
                iconClass: 'fa fa-key',
                link: '#',
                text: 'Change password'
            },
            'views': {
                iconClass: 'fa fa-columns',
                link: '#',
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