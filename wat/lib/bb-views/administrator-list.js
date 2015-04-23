Wat.Views.AdminListView = Wat.Views.ListView.extend({
    sideContainer: '.bb-setup-side',
    secondaryContainer: '.bb-setup',
    setupOption: 'administrators',
    qvdObj: 'administrator',
    
    initialize: function (params) {        
        this.collection = new Wat.Collections.Admins(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.Admin();
        
        this.dialogConf.title = $.i18n.t('New Administrator');
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('[name="language"]', 'single100');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var tenant = context.find('select[name="tenant"]').val();
        var password = context.find('input[name="password"]').val();

        var arguments = {
            "name": name,
            "password": password,
            "tenant": tenant
        };
        
        if (Wat.C.checkACL('administrator.create.language')) { 
            var language = context.find('select[name="language"]').val();
            arguments["language"] = language;
        }           
        
        if (Wat.C.isSuperadmin) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            arguments['tenant_id'] = tenant_id;
        }
        this.createModel(arguments, this.fetchList);
    },
});