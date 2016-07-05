Up.Views.AboutView = Up.Views.MainView.extend({
    qvdObj: 'about',
    
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
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        var templates = Up.I.T.getTemplateList('about');
        
        Up.A.getTemplates(templates, this.render); 
    },
    
    events: {
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Up.TPL.about, { 
                version: Up.C.version
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        Up.T.translateAndShow();       
    }
});