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
        
        this.setBreadCrumbs();

        this.templateDetailsCommon = Wat.A.getTemplate('details-common');
        this.templateDetails = Wat.A.getTemplate(this.detailsTemplateName);
        this.template404 = Wat.A.getTemplate('404');

        this.fetchDetails();
        
        // Extend the common events
        this.extendEvents(this.eventsDetails);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = Wat.I.getDetailsBreadCrumbs(this.qvdObj);
    },
    
    afterRender: function () {
        // If this view have Side component, render it after render
        if (this.renderSide) {
            this.renderSide();
        }
    },
    
    fetchDetails: function (that) {
        var that = that || this;
        that.model.fetch({      
            complete: function () {
                that.render();
            }
        });
    },
    
    eventsDetails: {
        'click .js-button-edit': 'openEditElementDialog'
    },
     
    openEditElementDialog: function (e) {
        var that = this;
        
        this.dialogConf.buttons = {
            Cancel: function () {
                $(this).dialog('close');
            },
            Update: function () {
                that.dialog = $(this);
                that.updateElement();
            }
        };
        
        this.dialogConf.button1Class = 'fa fa-ban';
        this.dialogConf.button2Class = 'fa fa-save';
        
        this.dialogConf.fillCallback = this.fillEditor;
        
        this.editorElement (e);
    },

    render: function () {    
        if (this.breadcrumbs.next.next.screen === undefined) {
            this.template = _.template(
                this.template404, {
                }
            );

            $(this.el).html(this.template);
            
            this.breadcrumbs.next.next.screen = '-';
            this.printBreadcrumbs(this.breadcrumbs, '');
        }
        else { 
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
        }
        Wat.T.translate();
    }
});
