Wat.Views.RoleListView = Wat.Views.ListView.extend({
    setupCommonTemplateName: 'setup-common',
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'roles',
    qvdObj: 'role',
    
    initialize: function (params) {
        params.whatRender = 'list';
        
        this.collection = new Wat.Collections.Roles(params);
        
        this.renderSetupCommon();
    },
    
    events: {
    },
    
    renderSetupCommon: function () {

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
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        // After render the side menu, embed the content of the view in secondary container
        this.embedContent();
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.ListView.prototype.initialize.apply(this, []);
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Role();
        
        this.dialogConf.title = $.i18n.t('New Role');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
                
        // Fill DI Tags select on virtual machines creation form
        /*var params = {
            'action': 'tenant_tiny_list',
            'selectedId': '0',
            'controlName': 'tenant',
            'filters': {
            }
        };
        
        Wat.A.fillSelect(params);
        
        Wat.I.chosenElement('[name="tenant"]', 'single100');*/
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var tenant = context.find('select[name="tenant"]').val();
        
        var arguments = {
            "name": name,
            "tenant": tenant
        };
                                
        this.createModel(arguments, this.fetchList);
    },
});