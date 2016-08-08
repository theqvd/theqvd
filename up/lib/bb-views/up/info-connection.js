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
                os: this.model.get('os'),
                browser: this.model.get('browser'),
                device: this.model.get('device'),
                location: this.model.get('location'),
                lastConnection: this.model.get('datetime'),
                message: this.model.get('message')
            }
        );
        
        $(this.el).html(this.template);  
        
        Up.T.translateAndShow();
    },
});