Up.Views.InfoView = Up.Views.MainView.extend({
    qvdObj: 'info',
    
    relatedDoc: {
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();

        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="info"]').addClass('menu-option--current');

        var templates = Up.I.T.getTemplateList('info');
        
        Up.A.getTemplates(templates, this.render, this); 
        
    },
    
    render: function () {
        // Detect OS and browser from userAgent
        var ua = detect.parse(navigator.userAgent);
        
        var shortBrowser = ua.browser.name;
        var longBrowser = ua.browser.name + ' (' + ua.browser.major + '.' + ua.browser.minor + '.' + ua.browser.patch + ')';
        
        var shortDevice = ua.device.type;
        var longDevice = ua.device.type + (ua.device.name ? ' (' + ua.device.name + ')' : '');
        
        var shortOS = ua.os.name;
        
        // Fill the html with the template and the model
        this.template = _.template(
            Up.TPL.infoConnection, {
                cid: this.cid,
                os: shortOS,
                browser: shortBrowser,
                device: longDevice
            }
        );
        
        $(this.el).html(this.template);  
        
        Up.T.translateAndShow();
    },
});