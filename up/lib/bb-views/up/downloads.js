Up.Views.DownloadsView = Up.Views.MainView.extend({
    qvdObj: 'downloads',
    
    relatedDoc: {
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();

        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="clients"]').addClass('menu-option--current');

        var templates = Up.I.T.getTemplateList('downloads');
        
        Up.A.getTemplates(templates, this.render, this); 
        
    },
    
    render: function () {
        var downloadsLinks = {
            'windows': 'http://theqvd.com/downloads/windows/qvd-client-setup-3.5.0-27493.exe',
            'os_x': 'http://theqvd.com/downloads/macosx/3.4/qvd-client.pkg',
            'os_x_yosemite': 'http://theqvd.com/downloads/macosx/3.4/qvd-client-yosemite.pkg',
            'android': 'https://play.google.com/store/apps/details?id=com.theqvd.android.client',
            'ios': 'https://itunes.apple.com/us/app/qvd-client/id892328999?mt=8',
        };
        
        var currentLan = window.i18n.lng();
        switch (currentLan) {
            case 'es':
                downloadsLinks.linux = "http://theqvd.com/es/producto/descargas#_linux";
                break;
            default:
                downloadsLinks.linux = "http://theqvd.com/product/download#_linux";
                break;
        }
        
        // Fill the html with the template and the model
        this.template = _.template(
            Up.TPL.downloads, {
                cid: this.cid,
                downloadsLinks: downloadsLinks
            }
        );
        
        $(this.el).html(this.template);  
        
        Up.I.addOddEvenRowClass(this.el);

        Up.T.translateAndShow();
    },
});