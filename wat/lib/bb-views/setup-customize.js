Wat.Views.SetupCustomizeView = Wat.Views.ViewsView.extend({
    setupOption: 'customize',
    qvdObj: 'views',

    limitByACLs: false,
    
    setAction: 'tenant_view_set',
    
    viewKind: 'tenant',

    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Views'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
                
        // Get side menu
        var cornerMenu = Wat.I.getCornerMenu();
        this.sideMenu = null;
        //this.sideMenu = cornerMenu.setup.subMenu;
        
        // Get filters and columns
        this.currentFilters = Wat.I.getTenantFormFilters (this.selectedSection, this.selectedTenant, this);
        this.currentColumns = Wat.I.getTenantListColumns (this.selectedSection, this.selectedTenant, this);
        
        this.render();
    },
    
    renderForm: function () {
        // Get filters and columns
        this.currentFilters = Wat.I.getTenantFormFilters (this.selectedSection, this.selectedTenant, this);
        this.currentColumns = Wat.I.getTenantListColumns (this.selectedSection, this.selectedTenant, this);
        
        Wat.Views.ViewsView.prototype.renderForm.apply(this);
    }
});