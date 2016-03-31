Wat.Views.LoginView = Wat.Views.MainView.extend({
    qvdObj: 'login',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Wat.B.bindLoginEvents();
                
        Wat.C.language = 'auto';
        
        $('.js-super-wrapper').addClass('super-wrapper--login');
        $('body').css('background',$('.super-wrapper--login').css('background-color'));

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
            Wat.C.authSeparators = this.retrievedData.auth.separators;
        }
        
        var template = Wat.TPL.login;
        
        if (this.retrievedData.readyState == 0 || this.retrievedData.status == STATUS_NOT_FOUND) {
            template = Wat.TPL.errorRefresh;
        }
        
        // Retrieve public configuration 
        var publicConfig = this.retrievedData.public_configuration || {};

        // Fill the html with the template
        publicConfig.login = publicConfig.login || {};
        publicConfig.login.link = publicConfig.login.link || {};
        this.template = _.template(
            template, {
                multitenant: Wat.C.multitenant,
                loginLinkSrc: publicConfig.login.link.src,
                loginLinkLabel: publicConfig.login.link.label
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translateAndShow();
    }
});