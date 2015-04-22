Wat.Views.TenantListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'tenants',
    selectedSection: 'user',
    qvdObj: 'tenant',

    
    initialize: function (params) {
        params.whatRender = 'list';
        
        this.collection = new Wat.Collections.Tenants(params);
        
        this.renderTenants();
    },
    
    renderTenants: function () {
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            Wat.TPL.setupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: null,
                //setupMenu: cornerMenu.wat.subMenu
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
        
        Wat.I.chosenElement('[name="language"]', 'single100');
        Wat.I.chosenElement('[name="block"]', 'single100');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var language = context.find('select[name="language"]').val(); 
        var block = context.find('select[name="block"]').val();
        
        var arguments = {
            "name": name,
            "block": block,
            "language": language
        };
                                
        this.createModel(arguments, this.fetchList);
    },
});