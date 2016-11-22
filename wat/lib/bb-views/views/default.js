Wat.Views.SetupCustomizeView = Wat.Views.ViewsView.extend({
    setupOption: 'customize',
    qvdObj: 'views',

    limitByACLs: false,
    
    setActionAttribute: 'tenant_attribute_view_set',
    setActionProperty: 'tenant_property_view_set',
    
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
        
        var templates = Wat.I.T.getTemplateList('viewsDefault');
        
        var that = this;
        
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    getDataAndRender: function () {
        var that = this;
        
        // Get system properties to complete the dababase data
        this.properties = new Wat.Collections.Properties();
        this.properties.fetch({      
            complete: function () {
                that.getFilters(that);
            }
        });
    },
    
    // Perform the reset action on DB and update interface
    performResetViews: function (params) {
        var sectionReset = $('[name="section_reset"]').val();
        var tenantReset = $('[name="tenant_reset"]').val();
        
        var filter = {};
        
        if (sectionReset) {
            filter.qvd_object = sectionReset;
        }
        
        if (tenantReset) {
            filter.tenant_id = tenantReset;
        }
        
        Wat.A.performAction('tenant_view_reset',{},filter,{}, function (that) {
            that.showViewsMessage(that.retrievedData);
            
            // Get admin setup configuration to get the views updated
            Wat.A.performAction('current_admin_setup', {}, {}, {}, function () {
                // Restore possible residous views configuration to default values
                Wat.I.restoreListColumns();
                Wat.I.restoreFormFilters();

                // Store views configuration
                Wat.C.storeViewsConfiguration(that.retrievedData.views);

                // Get admin setup configuration to get the views updated
                that.getFilters(that);
            }, that);
        }, this);
    },
    
    fillResetViewsEditor: function (target) {
        var qvdObj = $('[name="obj-qvd-select"]').val();
        var qvdObjName = $('[name="obj-qvd-select"] option:selected').html();
        var tenantId = $('[name="tenant-select"]').val();
        var tenantName = $('[name="tenant-select"] option:selected').html();
        
        var that = Wat.CurrentView;
        
        // Add common parts of editor to dialog
        var template = _.template(
                    Wat.TPL.resetViewsDefault, {
                        qvdObj: qvdObj,
                        qvdObjName: qvdObjName,
                        tenantId: tenantId,
                        tenantName: tenantName,
                    }
                );
        
        target.html(template); 
        
        Wat.I.chosenElement('select[name="section_reset"]', 'single100');
        
        Wat.T.translate();
    },
    
    getFilters: function (that) {                
        var qvdObj = that.selectedSection;
        var tenantId = that.selectedTenant;
                
        var args = {
            "view_type": "filter", 
            "qvd_object": qvdObj
        };
        
        if (tenantId != undefined) {
            args.tenant_id = tenantId;
        }
        
        Wat.A.performAction('tenant_view_get_list', {}, args, {}, that.storeFilters, that);
    },
    
    storeFilters: function (that) {
        if (that.retrievedData.status != STATUS_SUCCESS || that.retrievedData.statusText == 'abort') {
            return {};
        }
        
        var qvdObj = that.selectedSection;
        var tenantId = that.selectedTenant;
        
        // Filter by tenant
        if (tenantId != undefined) {
            var propModels = that.properties.where({'tenant_id': parseInt(tenantId)});
        }
        else {
            var propModels = that.properties.models;
        }
        
        // Filter by qvd object
        var propModels = propModels.filter(function (mod) {
            return mod.get('in_' + qvdObj) !== 0;
        });

        var defaultFormFilters = Wat.I.getFormDefaultFilters(qvdObj);

        that.completeFilterListWithProperties(defaultFormFilters, propModels, qvdObj);

        $.each(that.retrievedData.rows, function (iRegister, register) {
            if (!defaultFormFilters[register.field]) {
                return;
            }     
            switch (register.device_type) {
                case 'mobile':
                    defaultFormFilters[register.field].displayMobile = register.visible;
                    break;
                case 'desktop':
                    defaultFormFilters[register.field].displayDesktop = register.visible;
                    break;
            }
            
            defaultFormFilters[register.field].customized = true;
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
        
        if (tenantId != undefined) {
            args.tenant_id = tenantId;
        }
        
        Wat.A.performAction('tenant_view_get_list', {}, args, {}, that.storeColumns, that);
    },
    
    storeColumns: function (that) {
        if (that.retrievedData.status != STATUS_SUCCESS || that.retrievedData.statusText == 'abort') {
            return {};
        }
        
        var qvdObj = that.selectedSection;
        var tenantId = that.selectedTenant;
        
        // Filter by tenant
        if (tenantId != undefined) {
            var propModels = that.properties.where({'tenant_id': parseInt(tenantId)});
        }
        else {
            var propModels = that.properties.models;
        }
        
        // Filter by qvd object
        var propModels = propModels.filter(function (mod) {
            return mod.get('in_' + qvdObj) !== 0;
        });
        
        var defaultListColumns = Wat.I.getListDefaultColumns(qvdObj);

        that.completeColumnListWithProperties(defaultListColumns, propModels, qvdObj);
        
        $.each(that.retrievedData.rows, function (iRegister, register) {
            if (defaultListColumns[register.field]) {
                defaultListColumns[register.field].display = register.visible;
                defaultListColumns[register.field].customized = true;
            }
        });
              
        that.currentListColumns = defaultListColumns;
        
        that.currentColumns = defaultListColumns;
        
        that.renderForm();
    }
});