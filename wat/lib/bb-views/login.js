Wat.Views.LoginView = Wat.Views.MainView.extend({
    loginTemplateName: 'login',
    qvdObj: 'login',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Wat.B.bindLoginEvents();
        
        this.render();
    },
    
    events: {
    },
    
    render: function () {
        this.templateLogin = Wat.A.getTemplate(this.loginTemplateName);
        
        // Fill the html with the template
        this.template = _.template(
            this.templateLogin, {
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translate();        
    }
});