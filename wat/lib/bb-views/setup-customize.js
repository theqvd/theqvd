Wat.Views.ConfigCustomizeView = Wat.Views.MainView.extend({
    setupCommonTemplateName: 'setup-common',
    setupCustomizeTemplateName: 'setup-customize',
    sideContainer: '.bb-setup-side',
    setupContainer: '.bb-setup',
    setupOption: 'customize',

    breadcrumbs: {
        'screen': 'Home',
        'link': '#/home',
        'next': {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Customize'
            }
        }
    },
    
    initialize: function (params) {
        //this.model = new Wat.Models.DI(params);
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);

        this.render();
        
        //this.fetchOptions();
        Wat.I.fillCustomizeOptions('vm');
    },
    
    events: {
        'change select[name="obj-qvd-select"]': 'changeSection'
    },
    
    changeSection: function (e) {
        Wat.I.fillCustomizeOptions($(e.target).val());
    },
    
    fetchOptions: function () {
        Wat.A.performAction('config_field_get_list', {}, {qvd_obj: 'vm'}, {}, this.processOptions, this);
    },
    
    processOptions: function (that) {
        var customizeOptions = that.retrievedData.result.rows;
        
        var shortName = 'vm';
        
        var listColumns = Wat.I.getListColumns(shortName);
        
        // Get default values for custom columns
        var defaultListColumnsByField = {};
        $.each(listColumns, function (iColumn, column) {
            $.each(column.fields, function (iField, field) {
                defaultListColumnsByField[field] = defaultListColumnsByField[field] || {};
                defaultListColumnsByField[field][column.name] = column.display;
            });
        });

        // Set default values if not set
        $.each(customizeOptions, function (iOption, option) {
            if (defaultListColumnsByField[option.name]) {
                var options = {
                    'listColumns': JSON.stringify(defaultListColumnsByField[option.name])
                };
                Wat.A.performAction('config_field_update', {'filter_options': options}, {id: option.id});
            }
        });
        
        Wat.I.fillCustomizeOptions(customizeOptions);
    },
    
    render: function () { 
        this.templateSetupCommon = Wat.A.getTemplate(this.setupCommonTemplateName);
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateSetupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: cornerMenu.setup.subMenu
            }
        );
        
        $(this.el).html(this.template);
                
        this.templateSetupCustomize = Wat.A.getTemplate(this.setupCustomizeTemplateName);
        
        this.template = _.template(
            this.templateSetupCustomize, {
                model: this.model
            }
        );
        
        $(this.setupContainer).html(this.template);
        
        Wat.T.translate();
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    }
});