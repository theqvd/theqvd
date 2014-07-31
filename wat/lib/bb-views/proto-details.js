var DetailsView = MainView.extend({
    elementId: 0,
    
    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
        
        this.templateListCommon = this.getTemplate('details-common');
        this.detailsTemplate = this.getTemplate(this.detailsTemplateName);

        var that = this;
        this.model.fetch({      
            complete: function () {
                that.render();
            }
        });
    },
    
    events: {
        
    },

    render: function () {
        // Fill the html with the template and the collection
        this.template = _.template(
            this.templateListCommon, {
                model: this.model,
                config: this.config
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
    }
});
