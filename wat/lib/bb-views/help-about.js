Wat.Views.AboutView = Wat.Views.MainView.extend({
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
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        var templates = {
            about: {
                name: 'help-about'
            }
        }
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    events: {
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Wat.TPL.about, { 
                version: Wat.C.version
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        this.renderRelatedDocs();

        Wat.T.translateAndShow();       
    }
});