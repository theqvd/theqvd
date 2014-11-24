Wat.Views.AboutView = Wat.Views.MainView.extend({
    aboutTemplateName: 'help-about',
    qvdObj: 'help',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Help',
            'next': {
                'screen': 'About'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        this.render();
    },
    
    events: {
    },
    
    render: function () {
        this.templateAbout = Wat.A.getTemplate(this.aboutTemplateName);
        
        // Fill the html with the template
        this.template = _.template(
            this.templateAbout, { version: Wat.C.version
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        Wat.T.translate();       
    }
});