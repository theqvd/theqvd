Wat.Views.LoginView = Wat.Views.MainView.extend({
    qvdObj: 'login',

    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        Wat.B.bindLoginEvents();
                
        Wat.C.language = 'auto';
        Wat.T.initTranslate();

        this.render();
    },
    
    events: {
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Wat.TPL.login, {
            }
        );
        
        $(this.el).html(this.template);
        
        Wat.T.translate();        
    }
});