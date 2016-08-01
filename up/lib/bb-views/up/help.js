Up.Views.HelpView = Up.Views.MainView.extend({
    qvdObj: 'help',
    
    relatedDoc: {
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();

        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        $('.menu-option').removeClass('menu-option--current');
        $('[data-target="help"]').addClass('menu-option--current');

        var templates = Up.I.T.getTemplateList('help');
        
        Up.A.getTemplates(templates, this.render, this); 
        
    },
    
    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Up.TPL.help, {
                cid: this.cid
            }
        );
        
        $(this.el).html(this.template); 
        
        Up.I.addOddEvenRowClass(this.el);

        Up.T.translateAndShow();
    },
});