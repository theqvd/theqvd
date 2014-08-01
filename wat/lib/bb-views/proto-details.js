var DetailsView = MainView.extend({
    elementId: 0,
    detailsContainer: '.bb-details',
    editorContainer: '.bb-editor',

    /*
    ** params:
    **  id (numeric): Id of the element which details will be shown
    */
    
    initialize: function (params) {
        MainView.prototype.initialize.apply(this);

        this.elementId = params.id;
        
        this.templateDetailsCommon = this.getTemplate('details-common');
        this.templateDetails = this.getTemplate(this.detailsTemplateName);
        this.templateEditorCommon = this.getTemplate('editor-common');
        this.templateEditor = this.getTemplate(this.editorTemplateName);

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
        console.log('editElement2');
    },
    editElement: function () {
        var that = this;
        
        var dialogWidth = $('.dialog-container-template').width();
        var dialogHeigth = $('.dialog-container-template').height();
        var dialogWidth = 600;
        var dialogHeigth = 400;
        var dialogTitle = "edit_user";
        
        $('.js-dialog-container').dialog({
            width: dialogWidth,
            height: dialogHeigth,
            title: dialogTitle,
            resizable: false,
            dialogClass: 'no-close',
            modal: true,
            buttons: {
                cancel: function () {
                    $(this).dialog('close');
                },
                update: function () {
                    
                }
            },
            open: function() {        
                translateElementContain($('.ui-dialog-title'));
                $('.ui-dialog-title').html($('.ui-dialog-title').html() + ': ' + that.model.get('name'));
                
                // Disable scroll on body to improve user experience with dialog scroll
                $('body').css('overflow-y', 'hidden');
                
                // Buttons style
                var buttons = $(".ui-dialog-buttonset .ui-button");
                var buttonsText = $(".ui-dialog-buttonset .ui-button .ui-button-text");
                var cancelButton = buttonsText[0];
                var updateButton = buttonsText[1];
                
                translateElementContain($(cancelButton));
                translateElementContain($(updateButton));
                
                $(buttons).attr("class", "");
                $(buttons).addClass("button");
                $(cancelButton).addClass('fa fa-ban');
                $(updateButton).addClass('fa fa-save');
                
                that.template = _.template(
                            that.templateEditorCommon, {
                                model: that.model
                            }
                        );
                
                $(this).html(that.template);
                
                that.template = _.template(
                            that.templateEditor, {
                                model: that.model
                            }
                        );
                
                $(that.editorContainer).html(that.template);
                
                
                translateElement($(this).find('[data-i18n]'));
                
                $('.bb-editor-content-test').clone(true, true).appendTo('.dialog-container');
            },
            
            close: function () {
                // Re-enable scroll on body disabled when open dialog
                $('body').css('overflow-y', 'auto');
            }
        });                
    },
    
    bindEditorEvents: function () {        
        var that = this;

        // Delete custom property
        $(document).on('click', '.delete-property-button', function() {
            that.deleteProperty($(this));
        });
        // Add custom property
        $(document).on('click', '.add-property-button', function() {
            that.addProperty();
        });         
        // Hide property help when write on text input
        $(document).on('focus', '.custom-properties>tr>td input', function() {
            that.hidePropertyHelp($(this));
        });         
        // Active focus on property input when click on help message becaus it is over it
        $(document).on('click', '.property-help', function() {
            that.focusPropertyField($(this));
        });
    },
    
    addProperty: function () {
        var newRow = $('.template-property').clone();
        newRow.attr('class', 'new-property');
        newRow.insertBefore('.template-property');
    },
    
    deleteProperty: function (e) {
        // Remove two levels above the button (tr)
        e.parent().parent().remove();
    },
    
    hidePropertyHelp: function (e) {
        e.parent().find('.property-help').hide();
    },
    
    focusPropertyField: function (e) {
        e.parent().find('input').focus();
    }
});
