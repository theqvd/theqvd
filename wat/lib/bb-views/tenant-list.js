Wat.Views.TenantListView = Wat.Views.ListView.extend({
    setupCommonTemplateName: 'setup-common',
    listTemplateName: 'setup-tenants',
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'tenants',
    selectedSection: 'user',
    qvdObj: 'tenant',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Setup',
            'link': '#/setup',
            'next': {
                'screen': 'Tenants'
            }
        }
    },
    
    initialize: function (params) {
        params.whatRender = 'list';
        
        this.collection = new Wat.Collections.Tenants(params);
        
        this.renderTenants();
    },
    
    events: {
    },
    
    renderTenants: function () {

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
                
        this.embedContent();
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.ListView.prototype.initialize.apply(this, []);
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Tenant();
        
        this.dialogConf.title = $.i18n.t('New Tenant');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        
        var arguments = {
            "name": name
        };
                                
        this.createModel(arguments, this.fetchList);
    },
});