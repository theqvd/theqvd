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
            'screen': 'WAT Management',
            'next': {
                'screen': 'Default views'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.ViewsView.prototype.initialize.apply(this, [params]);
                
        // Get side menu
        var cornerMenu = Wat.I.getCornerMenu();
        this.sideMenu = null;
        
        this.render();
    },
    
    getDataAndRender: function () {
        this.getFilters(this);
    },
    
    getFilters: function (that) {                
        var qvdObj = that.selectedSection;
        var tenantId = that.selectedTenant;
                
        var args = {
            "view_type": "filter", 
            "qvd_object": qvdObj
        };
        
        if (tenantId != undefined && tenantId != 0) {
            args.tenant_id = tenantId;
        }
        
        Wat.A.performAction('tenant_view_get_list', {}, args, {}, that.storeFilters, that);
    },
    
    storeFilters: function (that) {
        if (that.retrievedData.status != STATUS_SUCCESS) {
            return {};
        }
               
        var defaultFormFilters = Wat.I.getFormDefaultFilters(qvdObj);

        $.each(that.retrievedData.rows, function (iRegister, register) {
            if (!defaultFormFilters[register.field]) {
                defaultFormFilters[register.field] = {
                    'filterField': register.field,
                    'type': 'text',
                    'text': register.field,
                    'noTranslatable': true,
                    'property': true,
                    'acls': qvdObj + '.filter.properties',
                };
            }     
            
            switch (register.device_type) {
                case 'mobile':
                    defaultFormFilters[register.field].displayMobile = register.visible;
                    break;
                case 'desktop':
                    defaultFormFilters[register.field].displayDesktop = register.visible;
                    break;
            }
        });
        
        that.currentFilters = defaultFormFilters;
        
        that.getColumns(that);
    },
    
    getColumns: function (that) {
        var qvdObj = that.selectedSection;
        var tenantId = that.selectedTenant;
        
        var args = {
            "view_type": "list_column", 
            "qvd_object": qvdObj
        };
        
        if (tenantId != undefined && tenantId != 0) {
            args.tenant_id = tenantId;
        }
        
        Wat.A.performAction('tenant_view_get_list', {}, args, {}, that.storeColumns, that);
    },
    
    storeColumns: function (that) {
        if (that.retrievedData.status != STATUS_SUCCESS) {
            return {};
        }
        
        var defaultListColumns = Wat.I.getListDefaultColumns(qvdObj);

        $.each(that.retrievedData.rows, function (iRegister, register) {
            if (defaultListColumns[register.field]) {
                defaultListColumns[register.field].display = register.visible;
            }
            else {
                defaultListColumns[register.field] = {
                    'display': register.visible,
                    'noTranslatable': true,
                    'fields': [
                        register.field
                    ],
                    'acls': qvdObj + '.see.properties',
                    'property': true,
                    'text': register.field
                };
            }            
        });
              
        that.currentListColumns = defaultListColumns;
        
        that.currentColumns = defaultListColumns;
        
        that.renderForm();
    }
});