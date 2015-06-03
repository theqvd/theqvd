Wat.Views.DetailsView = Wat.Views.MainView.extend({
    elementId: 0,
    detailsContainer: '.bb-details',
    
    viewKind: 'details',
    
    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
                
        // Extend the common events
        this.extendEvents(this.eventsDetails);
        
        this.addDetailsTemplates();
        
        Wat.A.getTemplates(this.templates, this.fetchDetails, this); 
    },
    
    addDetailsTemplates: function () {
        var templates = {
            details: {
                name: 'details/' + this.qvdObj
            },
            warn404: {
                name: 'error/404'
            },
            changePassword: {
                name: 'editor/change-password'
            }
        }
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    fetchDetails: function (that) {
        var that = that || this;
        that.model.fetch({      
            success: function () {
                that.render();
            }
        });
    },
    
    eventsDetails: {
    },

    render: function () {
        // If only id is stored in model means that it wasnt found
        if (this.notFound == undefined) {
            this.notFound = Object.keys(this.model.attributes).length <= 1;
        }
        
        if (this.notFound) {
            this.template = _.template(
                Wat.TPL.warn404, {
                }
            );

            $(this.el).html(this.template);
        }
        else {             
            // Fill the html with the template and the model
            this.template = _.template(
                Wat.TPL.details, {
                    model: this.model,
                    cid: this.cid
                }
            );

            $(this.el).html(this.template);
        }
        
        // Open websockets for live fields
        if (this.liveFields) {
            Wat.WS.openDetailsWebsockets(this.qvdObj, this.model, this.liveFields, this.cid);
        }
        
        Wat.T.translateAndShow();
    },
    
});
