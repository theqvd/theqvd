Up.Views.InfoView = Up.Views.MainView.extend({
    qvdObj: 'info',
    
    relatedDoc: {
    },
    
    initialize: function (params) {
        $('.js-platform-menu').hide();
        
        Up.Views.MainView.prototype.initialize.apply(this, [params]);
        
        var templates = Up.I.T.getTemplateList('info');
        
        Up.A.getTemplates(templates, this.fetchAndRender, this); 
        
    },
    
    fetchAndRender: function (that) {  
        that.model = new Up.Models.Connection();

        that.model.fetch({      
            complete: function (e) {
                that.render();
            }
        });
    },
    
    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            Up.TPL.infoConnection, {
                cid: this.cid,
                model: this.model
            }
        );
        
        $(this.el).html(this.template);  
        
        Up.T.translateAndShow();
    },
});