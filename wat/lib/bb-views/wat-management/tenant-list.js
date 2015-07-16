Wat.Views.TenantListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'tenants',
    selectedSection: 'user',
    qvdObj: 'tenant',

    
    initialize: function (params) {        
        this.collection = new Wat.Collections.Tenants(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
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
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
                                
        this.createModel(arguments, this.fetchList);
    },
});