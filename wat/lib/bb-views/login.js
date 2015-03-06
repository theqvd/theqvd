Wat.Views.LoginView = Wat.Views.MainView.extend({
    qvdObj: 'login',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Wat.B.bindLoginEvents();
                
        Wat.C.language = 'auto';
        Wat.T.initTranslate();
        
        var templates = {
            login: {
                name: 'login'
            },
            errorRefresh: {
                name: 'error-refresh'
            }
        }

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
        
        if (this.retrievedData.readyState == 0) {
            template = Wat.TPL.errorRefresh;
        }
        
        // Fill the html with the template
        this.template = _.template(
            template, {
                multitenant: Wat.C.multitenant
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translate();        
    }
});