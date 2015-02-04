Wat.Views.DocView = Wat.Views.MainView.extend({
    docTemplateName: 'help-documentation',
    qvdObj: 'documentation',
    availableLanguages: ['es'],
    defaultLanguage: 'en',
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
        this.setSelectedGuide('introduction');
        this.render();
    },
    
    events: {
    },
    
    setSelectedGuide: function (guideKey) {
        this.selectedGuide = guideKey;
    },
    
    render: function () {
        this.templateDoc = Wat.A.getTemplate(this.docTemplateName);
        
        // Fill the html with the template
        this.template = _.template(
            this.templateDoc, {
                selectedGuide: this.selectedGuide
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.fillDocumentation();

        Wat.T.translate();       
    },
    
    fillDocumentation: function () {
        // Load language
        var lan = $.i18n.options.lng;
        
        if ($.inArray(lan, this.availableLanguages) === -1) {
            lan = this.defaultLanguage;
        }
                
        $('.bb-doc-text').html(this.getDocBody(lan));
        
        asciidoc.toc(3);
    },
    
    getDocBody: function (lan) {
        var templateDoc = Wat.A.getTemplate('documentation-' + lan + '-' + this.selectedGuide, false);

        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(templateDoc);
        
        return array_matches[1];
    },
    
    getDocSection: function (lan, guide, sectionId) {
        var templateDoc = Wat.A.getTemplate('documentation-' + lan + '-' + guide, false);

        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(templateDoc);
        var docBody = array_matches[1];
        var guideHeader = $.parseHTML(docBody)[1].outerHTML;
        var guideToc = $.parseHTML(guideHeader)[0].childNodes[3].outerHTML;
        
        var pattern = new RegExp('(<h[1|2|3|4] id="' + sectionId + '"[^>]*>((.|[\n\r])*))', 'im');
        var array_matches2 = pattern.exec(docBody); 
                
        var secTitle = $.parseHTML(array_matches2[1])[0].outerHTML;
        var secBody = $.parseHTML(array_matches2[1])[2].outerHTML;
        
        $('.bb-doc-text').html('<div id="content">' + guideToc + secTitle + secBody + '</div>');
        asciidoc.toc(3);
    },
});