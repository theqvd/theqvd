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
        console.log('init cuztom');
        
        this.render();
        
        this.fetchOptions();
    },
    
    fetchOptions: function () {
        Wat.A.performAction('config_field_get_list', {}, {qvd_obj: 'vm'}, {}, Wat.I.fillCustomizeOptions, this);
    },
    
    render: function () { 
        this.templateSetupCommon = Wat.A.getTemplate(this.setupCommonTemplateName);

        // Fill the html with the template and the model
        this.template = _.template(
            this.templateSetupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: Wat.I.cornerMenu.setup.subMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Wat.T.translate();

        this.templateSetupCustomize = Wat.A.getTemplate(this.setupCustomizeTemplateName);
        
        this.template = _.template(
            this.templateSetupCustomize, {
                model: this.model
            }
        );
        
        $(this.setupContainer).html(this.template);
    }
});