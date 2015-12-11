Wat.Views.ViewsView = Wat.Views.MainView.extend({
    sideContainer: '.bb-setup-side',
    setupFormContainer: '.bb-customize-form',
    setupOption: 'customize',
    selectedSection: 'user',
    selectedTenant: '0',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        // If administrator is superadmin, use selected tenant. Otherwise, his tenant
        if (!Wat.C.isSuperadmin()) {
            this.selectedTenant = undefined;
        }
    },
    
    events: {
        'change select[name="obj-qvd-select"]': 'changeSection',
        'change select[name="tenant-select"]': 'changeSection',
        'change select[name="element-select"]': 'changeElement',
        'change .js-desktop-fields>input': 'checkDesktopFilter',
        'change .js-mobile-fields>input': 'checkMobileFilter',
        'change .js-field-check>input': 'checkListColumn',
        'click .js-reset-views': 'resetViews'
    },
    
    changeElement: function (e) {
        $('.js-customize-options').hide();
        $('.js-customize-options--' + $(e.target).val()).show();
    },
    
    resetViews: function () {
        var that = this;
        
        var dialogConf = {};

        dialogConf.title = "Reset views to default configuration";

        dialogConf.buttons = {
            Cancel: function (e) {
                Wat.I.closeDialog($(this));
            },
            "Reset": function (e) {
                that.performResetViews ();
                Wat.I.closeDialog($(this));
            }
        };
        
        dialogConf.button1Class = 'fa fa-ban js-button-cancel';
        dialogConf.button2Class = 'fa fa-eraser js-button-reset';

        dialogConf.fillCallback = that.fillResetViewsEditor;


        Wat.I.dialog(dialogConf, this);
    },
    
    showViewsMessage: function (response) {
        var messageParams = {};

        switch (this.retrievedData.status) {
            case STATUS_SUCCESS:
                messageParams.message = $.i18n.t("Successfully resetted");
                messageParams.messageType = 'success';
                break;
            case STATUS_ZERO_SELECTED:
                messageParams.message = $.i18n.t("Nothing to do");
                messageParams.messageType = 'info';
                break;
            default:
                messageParams.message = $.i18n.t("Error resetting");
                messageParams.messageType = 'error';
                break;
        }

        Wat.I.M.showMessage(messageParams, response);
    },
    
    checkDesktopFilter: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        var isProperty = $(this.targetClicked).parent().hasClass('js-is-property');
        var propertyId = $(this.targetClicked).parent().attr('data-property-id');
        
        if (isProperty) {
            var setAction = this.setActionProperty;
        }
        else {
            var setAction = this.setActionAttribute;
        }
        
        var qvdObj = this.selectedSection;

        if (!this.currentFilters[fieldName] || this.currentFilters[fieldName].displayDesktop != checked) {
            var args = {
                'view_type': 'filter',
                'device_type': 'desktop',
                'visible': checked
            };
            
            if (isProperty) {
                args.qvd_obj_prop_id = propertyId;
            }
            else {
                args.qvd_object = qvdObj;
                args.field = fieldName;
            this.addIDToArgs(args);
            }

            Wat.A.performAction(setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckDesktopFilter, this);
        }
    },
    
    processCheckDesktopFilter: function (that) {  
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is performed successfuly, update in memory
            if (that.currentFilters[fieldName]) {
                that.currentFilters[fieldName].displayDesktop = checked;
            }
            else {
                that.currentFilters[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    displayDesktop: checked,
                    displayMobile: 0,
                    filterField: fieldName,
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                    type: "text",
                };
            }

            if (that.viewKind == 'admin') {
                Wat.I.formFilters[qvdObj][fieldName] = that.currentFilters[fieldName];
            }
            else {
                that.updateCurrentViews(that);
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(e.target).prop('checked', !checked);
        }
    },
    
    checkMobileFilter: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        var isProperty = $(this.targetClicked).parent().hasClass('js-is-property');
        var propertyId = $(this.targetClicked).parent().attr('data-property-id');
        
        if (isProperty) {
            var setAction = this.setActionProperty;
        }
        else {
            var setAction = this.setActionAttribute;
        }
        
        var qvdObj = this.selectedSection;
        
        if (!this.currentFilters[fieldName] || this.currentFilters[fieldName].displayMobile != checked) {
            var args = {
                'view_type': 'filter',
                'device_type': 'mobile',
                'visible': checked
            };
            
            if (isProperty) {
                args.qvd_obj_prop_id = propertyId;
            }
            else {
                args.qvd_object = qvdObj;
                args.field = fieldName;
            this.addIDToArgs(args);
            }

            Wat.A.performAction(setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckMobileFilter, this);
        }
    },

    processCheckMobileFilter: function (that) { 
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is perfermed successfuly, update in memory
            if (that.currentFilters[fieldName]) {
                that.currentFilters[fieldName].displayMobile = checked;
            }
            else {
                that.currentFilters[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    displayDesktop: 0,
                    displayMobile: checked,
                    filterField: fieldName,
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                    type: "text",
                };
            }

            if (that.viewKind == 'admin') {
                Wat.I.formFilters[qvdObj][fieldName] = that.currentFilters[fieldName];
            }
            else {
                that.updateCurrentViews(that);
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(e.target).prop('checked', !checked);
        }
    },
    
    checkListColumn: function (e) {
        this.targetClicked = e.target;

        var checked = $(this.targetClicked).is(':checked');
        var fieldName = $(this.targetClicked).parent().attr('data-name');
        var isProperty = $(this.targetClicked).parent().hasClass('js-is-property');
        var propertyId = $(this.targetClicked).parent().attr('data-property-id');

        if (isProperty) {
            var setAction = this.setActionProperty;
        }
        else {
            var setAction = this.setActionAttribute;
        }
        
        var qvdObj = this.selectedSection;
        
        if (!this.currentColumns[fieldName] || this.currentColumns[fieldName].display != checked) {
            var args = {
                'view_type': 'list_column',
                'device_type': 'desktop',
                'visible': checked
            };
            
            if (isProperty) {
                args.qvd_obj_prop_id = propertyId;
            }
            else {
                args.qvd_object = qvdObj;
                args.field = fieldName;
            this.addIDToArgs(args);
            }
            

            Wat.A.performAction(setAction, args, {}, {'error': i18n.t('Error updating'), 'success': i18n.t('Successfully updated')}, this.processCheckListColumn, this);
        }
    },
    
    processCheckListColumn: function (that) { 
        var checked = $(that.targetClicked).is(':checked');
        var fieldName = $(that.targetClicked).parent().attr('data-name');
        var qvdObj = that.selectedSection;

        if (that.retrievedData.status == STATUS_SUCCESS) {
            // If update is perfermed successfuly, update in memory
            if (that.currentColumns[fieldName]) {
                that.currentColumns[fieldName].display = checked;
            }
            else {
                that.currentColumns[fieldName] = {
                    acls: qvdObj + ".see.properties",
                    display: checked,
                    fields: [fieldName],
                    noTranslatable: true,
                    property: true,
                    text: fieldName,
                };
            }
            
            if (that.viewKind == 'admin') {
                Wat.I.listFields[qvdObj][fieldName] = that.currentColumns[fieldName];
            }
            else {
                that.updateCurrentViews(that);
            }
        }
        else {
            // If update fails, change ckeckbox to previous state
            $(that.targetClicked).prop('checked', !checked);
        }
    },
    
    updateCurrentViews: function (that) {
        // Get admin setup configuration to get the views updated
        Wat.A.performAction('current_admin_setup', {}, VIEWS_COMBINATION, {}, function () {
            // Restore possible residous views configuration to default values
            Wat.I.restoreListColumns();
            Wat.I.restoreFormFilters();

            // Store views configuration
            Wat.C.storeViewsConfiguration(that.retrievedData.views);
        }, that);
    },
    
    changeSection: function (e) {
        $('.js-customize-columns').html(HTML_MID_LOADING);
        $('.js-customize-filters').html(HTML_MID_LOADING);
        this.selectedSection = $('select[name="obj-qvd-select"]').val();

        if (Wat.C.isSuperadmin()) {
            this.selectedTenant = $('select[name="tenant-select"]').val();
        }
        else {
            this.selectedTenant = undefined;
        }
        
        this.getDataAndRender();
    },
    
    render: function () {
        $(this.el).html(this.template);
        
        this.template = _.template(
            Wat.TPL.viewCustomize, {
                selectedSection: this.selectedSection,
                limitByACLs: this.limitByACLs,
                viewKind: this.viewKind,
                cid: this.cid,
            }
        );
        
        $(this.el).html(this.template);
        
        // Store as selected the current selected section
        this.selectedSection = $('select[name="obj-qvd-select"]').val();
        
        if (Wat.C.isSuperadmin()) {
            // Fill Tenant select on viees customization view
            var params = {
                'action': 'tenant_tiny_list',
                'controlName': 'tenant-select',
            };

            Wat.A.fillSelect(params, function () {
                Wat.I.updateChosenControls('[name="tenant-select"]');
            });  
        }
        
        this.getDataAndRender();
    },
    
    renderForm: function () {        
        this.template = _.template(
            Wat.TPL.viewFormCustomize, {
                filters: this.currentFilters,
                columns: this.currentColumns,
                limitByACLs: this.limitByACLs
            }
        );
        
        $(this.setupFormContainer).html(this.template);
                
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        $('.js-custom-views-container').show();
        
        Wat.T.translateAndShow();
    },
    
    addIDToArgs: function (args) {
        switch (this.viewKind) {
            case 'tenant':
                // If administrator is superadmin, use selected tenant. Otherwise, no tenant filter will be used
                if (Wat.C.isSuperadmin()) {
                    args['tenant_id'] = this.selectedTenant;
                }
                break;
        }        
    },
    
    completeColumnListWithProperties: function (columnList, properties, qvdObj) {
        $.each(properties, function (iProp, prop) {
            if (columnList[prop.get('key')]) {
                columnList[prop.get('key')].property = true;
                columnList[prop.get('key')].property_id = prop.get('in_' + qvdObj);
                return;
            }
            
            columnList[prop.get('key')] = {
                'display': 0,
                'noTranslatable': true,
                'fields': [
                    prop.get('key')
                ],
                'acls': qvdObj + '.see.properties',
                'property': true,
                'property_id': prop.get('in_' + qvdObj),
                'text': prop.get('key')
            };
        });
    },   
    
    completeFilterListWithProperties: function (filterList, properties, qvdObj) {
        $.each(properties, function (iProp, prop) {
            if (filterList[prop.get('key')]) {
                filterList[prop.get('key')].property = true;
                filterList[prop.get('key')].property_id = prop.get('in_' + qvdObj);
                return;
            }
            
            filterList[prop.get('key')] = {
                'filterField': prop.get('key'),
                'type': 'text',
                'text': prop.get('key'),
                'noTranslatable': true,
                'property': true,
                'property_id': prop.get('in_' + qvdObj),
                'acls': qvdObj + '.filter.properties'
            };
        });
    },

});