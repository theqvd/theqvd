Wat.Views.DialogView = Wat.Views.MainView.extend({
    el: '.bb-dialog-container',

    initialize: function (params) {
        if (params.el) {
            this.el = params.el;
        }
        
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        this.extendEvents(this.dialogEvents);

        this.render();
    },
    
    render: function () {
        $(this.el).html('<div class="bb-dialog-content content ' + this.cid + '"></div>');
        
        this.el = '.bb-dialog-content';
    },
});