Wat.Views.LoginView = Wat.Views.MainView.extend({
    qvdObj: 'login',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Wat.B.bindLoginEvents();
                
        Wat.C.language = 'auto';
        
        var templates = Wat.I.T.getTemplateList('login');

        Wat.A.getTemplates(templates,  this.getApiInfo, this);
    },
    
    getApiInfo: function (that) {
        Wat.A.apiInfo(that.render, that);
    },
    
    events: {
    },
    
    render: function () {  
        if (this.retrievedData.status == STATUS_SUCCESS) {
            Wat.C.multitenant = this.retrievedData.multitenant;
        }
        
        var template = Wat.TPL.login;
        
        if (this.retrievedData.readyState == 0 || this.retrievedData.status == STATUS_NOT_FOUND) {
            template = Wat.TPL.errorRefresh;
        }
        
        // Fill the html with the template
        this.template = _.template(
            template, {
                multitenant: Wat.C.multitenant
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translateAndShow();        
    }
});