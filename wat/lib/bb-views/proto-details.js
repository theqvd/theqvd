Wat.Views.DetailsView = Wat.Views.MainView.extend({
    elementId: 0,
    detailsContainer: '.bb-details',
    
    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
        
        this.templateDetailsCommon = Wat.A.getTemplate('details-common');
        this.templateDetails = Wat.A.getTemplate(this.detailsTemplateName);

        this.fetchDetails();
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
    },
    
    fetchDetails: function () {
        var that = this;
        this.model.fetch({      
            complete: function () {
                that.render();
            }
        });
    },
    
    eventsDetails: {
        'click .js-button-edit': 'editElement'
    },
     
    editElement: function (e) {
        var that = this;
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Update: function () {
                that.updateElement($(this));
                that.showMessage();
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-save';
        
        this.editorElement (e);
    },

    render: function () {
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateDetailsCommon, {
                model: this.model,
                cid: this.cid
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
        
        Wat.T.translate();
    }
});
