Up.Views.LoginView = Up.Views.MainView.extend({
    qvdObj: 'login',

    initialize: function (params) {
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Up.B.bindLoginEvents();
                
        Up.C.language = 'auto';
        
        $('.js-super-wrapper').addClass('super-wrapper--login');
        $('body').css('background',$('.super-wrapper--login').css('background-color'));

        var templates = Up.I.T.getTemplateList('login');

        Up.A.getTemplates(templates,  this.getApiInfo, this);
    },
    
    getApiInfo: function (that) {
        Up.A.apiInfo(that.render, that);
    },
    
    events: {
    },
    
    render: function () {  
        Up.C.multitenant = this.retrievedData.multitenant || true;
        Up.C.authSeparators = this.retrievedData.auth ? this.retrievedData.auth.separators : SEPARATORS_DEFAULT;
        
        var template = Up.TPL.login;
        
        if (this.retrievedData.readyState == 0 || this.retrievedData.status == STATUS_NOT_FOUND) {
            template = Up.TPL.errorRefresh;
        }
        
        // Retrieve public configuration 
        var publicConfig = this.retrievedData.public_configuration || {};

        // Fill the html with the template
        publicConfig.login = publicConfig.login || {};
        publicConfig.login.link = publicConfig.login.link || {};
        this.template = _.template(
            template, {
                multitenant: Up.C.multitenant,
                loginLinkSrc: publicConfig.login.link.src,
                loginLinkLabel: publicConfig.login.link.label
            }
        );
        
        $(this.el).html(this.template);
        
        Up.T.translateAndShow();
    }
});