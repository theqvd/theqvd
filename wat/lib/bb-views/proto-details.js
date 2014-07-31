var DetailsView = MainView.extend({
    elementId: 0,
    detailsContainer: '.bb-details',

    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
        
        this.templateDetailsCommon = this.getTemplate('details-common');
        this.templateDetails = this.getTemplate(this.detailsTemplateName);

        var that = this;
        this.model.fetch({      
            complete: function () {
                that.render();
            }
        });
    },
    
    events: {
        'click .js-button-edit': 'editElement'
    },

    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateDetailsCommon, {
                model: this.model
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.template = _.template(
            this.templateDetails, {
                model: this.model
            }
        );
        
        $(this.detailsContainer).html(this.template);
    },
    
    editElement: function () {
        console.log($('.dialog-container-template').width());
        $('.js-dialog-container').dialog({
            width: $('.dialog-container-template').width(),
            height: $('.dialog-container-template').height(),
            modal: true,
        });
    }
});
