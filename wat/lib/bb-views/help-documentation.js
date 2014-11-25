Wat.Views.DocView = Wat.Views.MainView.extend({
    docTemplateName: 'help-documentation',
    qvdObj: 'documentation',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Help',
            'next': {
                'screen': 'Documentation'
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
        this.templateDoc = Wat.A.getTemplate(this.docTemplateName);
        
        // Fill the html with the template
        this.template = _.template(
            this.templateDoc, {}
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        Wat.T.translate();       
    }
});