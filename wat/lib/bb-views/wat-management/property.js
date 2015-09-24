Wat.Views.PropertyView = Wat.Views.MainView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'properties',
    qvdObj: 'property',
    selectedObj: 'all',
    selectedTenant: '0',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'WAT Management',
            'next': {
                'screen': 'Properties'
            }
        }
    },
    
    initialize: function (params) {     
        this.collection = new Wat.Collections.Properties(params);
        
        // Disable pagination
        this.collection.block = 0;
                
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        var templates = Wat.I.T.getTemplateList('properties');
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    events: {
        'change select[name="obj-qvd-select"]': 'changeObjSelect',
        'change select[name="tenant-select"]': 'changeTenantSelect',
        'click input[name="property-check"]': 'checkProperty',
        'click .js-button-new': 'openNewElementDialog',
        'click .js-button-edit': 'openEditElementDialog',
        'click .js-button-delete': 'askDelete',
    },
    
    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.property, {
                selectedObj: this.selectedObj,
                selectedTenant: this.selectedTenant,
                limitByACLs: false,
                cid: this.cid
            }
        );

        $(this.el).html(this.template);
        
        Wat.T.translateAndShow();
        
        if (Wat.C.isSuperadmin()) {
            // Fill Tenant select on viees customization view
            var params = {
                'action': 'tenant_tiny_list',
                'controlName': 'tenant-select',
                'selectedId': this.selectedTenant
            };

            Wat.A.fillSelect(params, function () {
                Wat.I.updateChosenControls('[name="tenant-select"]');
            });  
        }
        
        var filters = {};
        
        if (Wat.C.isSuperadmin()) {
            filters['tenant_id'] = this.selectedTenant;
        }
        
        $('.bb-property-list').html(HTML_LOADING);
                
        var that = this;

        that.collection.filters = filters;
        
        that.collection.fetch({      
            complete: function () {
                that.renderPropertyList(that);
            }
        });
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    },
    
    renderPropertyList: function (that) { 
        this.template = _.template(
            Wat.TPL.listProperty, {
                model: this.model,
                cid: this.cid,
                properties: that.collection,
                selectedObj: $('select[name="obj-qvd-select"]').val()
            }
        );

        $('.bb-property-list').html(this.template);
        
        Wat.T.translate();
    },
    
    changeObjSelect: function () {
        var selectedObj = $('select[name="obj-qvd-select"]').val();
        
        $('.js-zero-properties').hide();
        
        switch (selectedObj) {
            case 'all':
                $('.js-only-all-properties').show();
                $('.js-row-property').show();
                if ($('.js-row-property').length == 0) {
                    $('.js-zero-properties').show();
                }
                break;
            default:
                //$('.js-only-all-properties').hide();
                $('.js-row-property').hide();
                $('.js-row-property-' + selectedObj).show();

                if ($('.js-row-property-' + selectedObj).length == 0) {
                    $('.js-zero-properties').show();
                }
                break;
        }
    },
    
    changeTenantSelect: function () {
        var newSelectedTenant = $('select[name="tenant-select"]').val();
        
        this.selectedTenant = newSelectedTenant;
        
        filters = {
            "tenant_id":  newSelectedTenant,
        };
        
        $('.bb-property-list').html(HTML_LOADING);
        
        var that = this;

        that.collection.filters = filters;
        
        that.collection.fetch({      
            complete: function () {
                that.renderPropertyList(that);
            }
        });
    },
    
    checkProperty: function (e) {
        var checked = $(e.target).is(':checked');
        var propertyId = $(e.target).attr('data-property-id');
        var qvdObj = $(e.target).attr('data-qvd-object');
        var args = {};
        var filters = {};
        
        if (checked) {
            var action = qvdObj + '_create_property_list';
            args = {
                'property_id': propertyId
            };
        }
        else {
            var action = qvdObj + '_delete_property_list';
            filters = {
                'id': propertyId
            };
        }

        
        Wat.A.performAction(action, args, filters, {}, function (that) {
            if (that.retrievedData.status == STATUS_SUCCESS) {
                var row = $(e.target).parent().parent();
                if (checked) {
                    Wat.I.showMessage({message: i18n.t('Successfully created'), messageType: 'success'}, that.retrievedData);
                    $(row).addClass('js-row-property-' + qvdObj);
                }
                else {
                    Wat.I.showMessage({message: i18n.t('Successfully deleted'), messageType: 'success'}, that.retrievedData);
                    $(row).removeClass('js-row-property-' + qvdObj);
                    var selectedObj = $('select[name="obj-qvd-select"]').val();
                    
                    if (selectedObj == qvdObj) {
                        $(row).hide();                    
                        if ($('.js-row-property-' + qvdObj).length == 0) {
                            $('.js-zero-properties').show();
                        }
                    }
                }
                
            }
            else {
                if (checked) {
                    Wat.I.showMessage({message: i18n.t('Error creating'), messageType: 'error'}, that.retrievedData);
                }
                else {
                    Wat.I.showMessage({message: i18n.t('Error deleting'), messageType: 'error'}, that.retrievedData);
                }
            }                            
        }, this);
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Property();
        this.dialogConf.title = $.i18n.t('New property');
        Wat.Views.MainView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    openEditElementDialog: function (e) {
        var propertyId = $(e.target).attr('data-property-id');
        
        // Doesnt work, do manually
        // this.model = this.collection.where({property_id: propertyId});
        
        var that = this;
        $.each(this.collection.models, function (iMod, mod) {
            if (mod.get('property_id') == propertyId) {
                that.model = mod;
            }
        });
                
        this.editingFromList = true;
        
        this.dialogConf.title = $.i18n.t('Edit property');
        Wat.Views.MainView.prototype.openEditElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        var valid = Wat.Views.MainView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var key = context.find('input[name="key"]').val();
        var description = context.find('textarea[name="description"]').val(); 
        
        var args = {
            "key": key,
            "description": description
        };
        
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        else {
            // TODO: This assignation must be done by the server automatically for tenant admins
            args["tenant_id"] = Wat.C.tenantID;
        }
                
        this.objChecks = {};
        var that = this;
        $.each(QVD_OBJS_WITH_PROPERTIES, function (iObj, qvdObj) {
            that.objChecks[qvdObj] = $('input[name="in_' + qvdObj + '"]').is(':checked');
        });
        
        that.createModel(args, that.getLastId);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
                
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="key"]').val();
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": that.model.get('property_id')};
        var arguments = {};
        
        //if (Wat.C.checkACL('role.update.name')) {
            arguments['key'] = name;
        //}
        
        //if (Wat.C.checkACL('role.update.description')) {
            arguments["description"] = description;
        //}
        
        this.updateModel(arguments, filters, this.render);
    },
    
    askDelete: function (e) {
        var propertyId = $(e.target).attr('data-property-id');
        
        // Doesnt work, do manually
        // this.model = this.collection.where({property_id: propertyId});
        
        var that = this;
        $.each(this.collection.models, function (iMod, mod) {
            if (mod.get('property_id') == propertyId) {
                that.model = mod;
            }
        });
        
        Wat.I.confirm('dialog/confirm-undone', this.applyDelete, this);
    },
        
    applyDelete: function (that) {
        that.deleteModel({id: that.model.get('property_id')}, that.render, that.model);
    },
    
    getLastId: function (that) {
        if (that.retrievedData.status == STATUS_ELEMENT_ALREADY_EXISTS) {
            return;
        }
        
        var lastId = that.retrievedData.rows[0].id;
        
        // Get all the properties orderer by id desc to get the last property created
        Wat.A.performAction('property_get_list', {}, {}, {}, that.addPropertyToObjectsAndRender, that, undefined, {"field":"id","order":"-desc"});
    },
    
    addPropertyToObjectsAndRender: function (that) {
        var lastId = that.retrievedData.rows[0].property_id;
        
        var countChecks = 0;
        var nChecks = 5;
        
        $.each(QVD_OBJS_WITH_PROPERTIES, function (iObj, qvdObj) {
            if (that.objChecks[qvdObj]) {
                var args = {};
                var filters = {};
                var action = qvdObj + '_create_property_list';
                
                args = {
                    'property_id': lastId
                };

                Wat.A.performAction(action, args, filters, {}, function (that) {
                    if (that.retrievedData.status == STATUS_SUCCESS) {
                        //Wat.I.showMessage({message: i18n.t('Successfully created'), messageType: 'success'}, that.retrievedData);
                    }
                    else {
                        //Wat.I.showMessage({message: i18n.t('Error creating'), messageType: 'error'}, that.retrievedData);
                    }

                    countChecks++;
                    
                    if (countChecks == nChecks) {
                        that.render();
                    }
                }, that);
            }
            else {
                countChecks++;
            }
        });
        
        if (countChecks == nChecks) {
            that.render();
        }
    }
});