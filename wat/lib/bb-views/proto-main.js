var MainView = Backbone.View.extend({
    el: '.bb-content',
    editorContainer: '.bb-editor',
    config: {},
    breadcrumbs: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
        
        this.templateEditorCommon = this.getTemplate('editor-common');
        this.templateEditor = this.getTemplate(this.editorTemplateName);
        
        // Binding events manually because backbone doesnt allow bind events to dialogs loaded dinamically
        this.bindEditorEvents();
        
        // Add to the view events the parent class of this view to avoid collisions with other views events
        this.restrictEventScope();

        var that = this;
        this.render = _.wrap(this.render, function(render) { 
            that.beforeRender(); 
            render(); 
            that.afterRender(); 
            return that; 
        }); 
    },
    
    beforeRender: function () {
    },
    
    afterRender: function () {
    },
  
    restrictEventScope: function () {
        var that = this;
        var newEvents = {};
        $.each(this.events, function(key, value) {
            var newKey = key.replace(' ', ' .' + that.cid + ' ');
            newEvents[newKey] = value;
        });
        this.events = newEvents;
    },
    
    printBreadcrumbs: function (bc, bcHTML) {
        if (bc.link != undefined) {
            bcHTML += '<a href="' + bc.link + '" data-i18n>' + bc.screen + '</a>';
        }
        else {
            bcHTML += '<span data-i18n>' + bc.screen + '</span>';
        }

        if (bc.next != undefined) {
            bcHTML += ' <i class="fa fa-angle-double-right"></i> ';
            this.printBreadcrumbs (bc.next, bcHTML);
        }
        else {
            $('#breadcrumbs').html(bcHTML);
        }
    },
    
    cache: {
        stringsCache : {},
        getCached : function (col, dictionary) {
            if (dictionary != undefined && dictionary[col] !== undefined) {
                return dictionary[col];
            }
            else {
                return '';
            }
        },
        cached : false
    },
    
    activeCache: function (cache) {
        $.each($('.cacheable'), function(index, element) {
            var key = $(element).attr('data-i18n');
            var value = $(element).html();
            // Remove HTML tags from value to clean icons
            var cleanValue = value.replace(/(<([^>]+)>)/ig,"");
            cache.stringsCache[key] = cleanValue;
        });
        
        cache.cached = true;
    },
    
    
    getTemplate: function(templateName) {
        if ($('#template_' + templateName).html() == undefined) {
            var tmplDir = 'templates';
            var tmplUrl = tmplDir + '/' + templateName + '.tpl';
            var tmplString = '';

            $.ajax({
                url: tmplUrl,
                method: 'GET',
                async: false,
                contentType: 'text',
                success: function (data) {
                    tmplString = data;
                }
            });

            $('head').append('<script id="template_' + templateName + '" type="text/template">' + tmplString + '<\/script>');
        }

        return $('#template_' + templateName).html();
    },
    
    editorDialogTitle: function () {
        return '';
    },
    
    // Editor
    editElement: function () {
        var that = this;
        
        var dialogTitle = this.editorDialogTitle();
        
        $('.js-dialog-container').dialog({
            title: dialogTitle,
            resizable: false,
            dialogClass: 'no-close',
            collision: 'fit',
            modal: true,
            buttons: {
                Cancel: function () {
                    $(this).dialog('close');
                },
                Update: function () {
                    
                }
            },
            open: function() {     
                
                // Disable scroll on body to improve user experience with dialog scroll
                //$('body').css('overflow-y', 'hidden');
                
                // Buttons style
                var buttons = $(".ui-dialog-buttonset .ui-button");
                var buttonsText = $(".ui-dialog-buttonset .ui-button .ui-button-text");
                var cancelButton = buttonsText[0];
                var updateButton = buttonsText[1];
                
                that.translateElementContain($(cancelButton));
                that.translateElementContain($(updateButton));
                
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
                
                
                that.translateElement($(this).find('[data-i18n]'));
                
                $('.bb-editor-content-test').clone(true, true).appendTo('.dialog-container');
            },
            
            close: function () {
                // Re-enable scroll on body disabled when open dialog
                //$('body').css('overflow-y', 'auto');
            }
        });                
    },
    
    // Generic function to bind events receiving the event, the selector and the callback function to be called when event is triggered
    bindEvent: function (event, selector, callback) {
        // First unbind event to avoid duplicated bindings
        $(document).off(event, selector);
        $(document).on(event, selector, callback);
    },
    
    // Events binded in classic way to works in special places like jQueryUI dialog where Backbone events doesnt work
    bindEditorEvents: function () { 
        var cidClass = '.' + this.cid + ' ';

        // Delete custom property
        this.bindEvent('click', '.delete-property-button', this.editorBinds.deleteProperty);
        
        // Add custom property
        this.bindEvent('click', '.add-property-button', this.editorBinds.addProperty);        
        
        // Hide property help when write on text input
        this.bindEvent('focus', '.custom-properties>tr>td input', this.editorBinds.hidePropertyHelp);
        
        // Active focus on property input when click on help message becaus it is over it
        this.bindEvent('click', '.property-help', this.editorBinds.focusPropertyField);
    },
    
    // Object with the callbacks of the events binded on editor
    editorBinds: {
        addProperty: function () {
            var newRow = $('.template-property').clone();
            newRow.attr('class', 'new-property');
            newRow.insertBefore('.template-property');
        },

        deleteProperty: function () {
            // Remove two levels above the button (tr)
            $(this).parent().parent().remove();
        },

        hidePropertyHelp: function () {
            $(this).parent().find('.property-help').hide();
        },

        focusPropertyField: function () {
            $(this).parent().find('input').focus();
        }
    },
    
    // Translation configuration and actions to be done when language file is loaded
    translate: function() {
        $.i18n.init({
            //resGetPath: 'lib/languages/__lng__.json',
            resGetPath: 'lib/languages/en.json',
            useLocalStorage: false,
            debug: false,
            fallbackLng: 'en',
        }, function() {            
            // Translate all the elements with attribute 'data-i18n'
            $('[data-i18n]').i18n();

            // Other chains
            $('.footer').html(i18n.t('QVD Web Administration Tool, by %s',  $('.footer').attr('data-link')));

            // Translatable buttons
            $.each($('.js-traductable_button'), function(index, button) {
                var translation = i18n.t(i18n.t($(button).html().trim()));
                $(button).html(translation);
            });

            // Convert the filter selects to library chosen style
            var chosenOptions = {};
            chosenOptions.no_results_text = i18n.t('No results match');
            chosenOptions.search_contains = true;

            var chosenOptionsSingle = jQuery.extend({}, chosenOptions);
            chosenOptionsSingle.disable_search = true;
            chosenOptionsSingle.width = "200px";

            var chosenOptionsSingle100 = jQuery.extend({}, chosenOptionsSingle);
            chosenOptionsSingle100.width = "100%"; 

            var chosenOptionsAdvanced100 = jQuery.extend({}, chosenOptions);
            chosenOptionsAdvanced100.width = "100%";

            $('.filter-control select.chosen-advanced').chosen(chosenOptionsAdvanced100);
            $('.filter-control select.chosen-single').chosen(chosenOptionsSingle100);
            $('select.chosen-single').chosen(chosenOptionsSingle);

            // After all the translations do custom actions that need to have the content translated
            addSortIcons(currentView);

            // When all is translated and loaded, hide loading spinner and show content
            showAll();
        });
    },
    
    // Translate the content of an element passing the selector
    translateElementContain: function(selector) {
        var translated = i18n.t($(selector).html());
        $(selector).html(translated);
    },

    // Translate an element with i18n standard function
    translateElement: function(element) {
       element.i18n();
    }
});
