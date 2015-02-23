Wat.Views.DocView = Wat.Views.MainView.extend({
    qvdObj: 'documentation',
    selectedGuide: 'introduction',
    
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
        
        if (params.guide) {
            this.selectedGuide = params.guide;
        }
        
        this.setSelectedGuide(this.selectedGuide);
        
        var templates = {
            doc: {
                name: 'help-documentation'
            }
        }
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    events: {
    },
    
    setSelectedGuide: function (guideKey) {
        this.selectedGuide = guideKey;
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Wat.TPL.doc, {
                selectedGuide: this.selectedGuide
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.fillDocumentation();

        Wat.T.translate();       
    },
    
    fillDocumentation: function () {    
        $('.bb-doc-text').html(Wat.A.getDocBody(this.selectedGuide));
        
        asciidoc.toc(3);
    },
});