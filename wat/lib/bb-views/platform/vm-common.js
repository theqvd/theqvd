// Common lib for VM views (list and details)
Wat.Common.BySection.vm = {
    // This initialize function will be executed one time and deleted
    initializeCommon: function (that) {
        var templates = Wat.I.T.getTemplateList('commonVMS');
        
        this.templates = $.extend({}, this.templates, templates);
    },
    
    updateElement: function (dialog) {
        var that = that || this;
        
        // If current view is list, use selected ID as update element ID
        if (that.viewKind == 'list') {
            that.id = that.selectedItems[0];
        }
                
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(that, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = that.properties;
        
        var context = $('.' + that.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var di_tag = context.find('select[name="di_tag"]').val(); 
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": that.id};
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('user.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('vm.update.name')) {
            arguments['name'] = name;
        }     
        
        if (Wat.C.checkACL('vm.update.di-tag')) {
            arguments['di_tag'] = di_tag;
        }
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL(this.qvdObj + 'vm.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        if (Wat.C.checkACL('vm.update.expiration')) {
            // If expire is checked
            if (context.find('input.js-expire').is(':checked')) {
                var expiration_soft = context.find('input[name="expiration_soft"]').val();
                var expiration_hard = context.find('input[name="expiration_hard"]').val();

                if (expiration_soft != undefined) {
                    arguments['expiration_soft'] = expiration_soft;
                }

                if (expiration_hard != undefined) {
                    arguments['expiration_hard'] = expiration_hard;
                }
            }
            else {
                // Delete the expiration if exist
                arguments['expiration_soft'] = '';
                arguments['expiration_hard'] = '';
            }
        }
        
        if (Wat.C.checkACL('vm.update.description')) {
            arguments["description"] = description;
        }
                
        that.updateModel(arguments, filters, that.fetchAny);
    },
    
    openEditElementDialog: function(e) {
        if (this.viewKind == 'list') {
            this.model = this.collection.where({id: this.selectedItems[0]})[0];
        }   
                
        this.dialogConf.title = $.i18n.t('Edit Virtual machine') + ": " + this.model.get('name');
        
        Wat.Views.DetailsView.prototype.openEditElementDialog.apply(this, [e]);
        
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
                
        var params = {
            'action': 'tag_tiny_list',
            'selectedId': this.model.get('di_tag'),
            'controlName': 'di_tag',
            'filters': {
                'osf_id': this.model.get('osf_id')
            },
            'nameAsId': true,
            'chosenType': 'single100'
        };

        Wat.A.fillSelect(params);
    },
    
    spyVM: function () {
        var that = this;
        
        var dialogConf = {
            title: $.i18n.t('Spy'),
            buttons : {
                "Full screen": function () { 
                    $('.ui-dialog').addClass('ui-dialog--fullscreen');   
                    $(".ui-dialog-buttonset button span.fa-expand").parent().hide();
                    $(".ui-dialog-buttonset button span.fa-compress").parent().show();
                    $('.ui-dialog-titlebar').hide();
                    UI.toggleFullscreen();

                    UI.onresize();
                },
                "Normal screen": function () {
                    $('.ui-dialog').removeClass('ui-dialog--fullscreen');
                    $(".ui-dialog-buttonset button span.fa-expand").parent().show();
                    $(".ui-dialog-buttonset button span.fa-compress").parent().hide();
                    $('.ui-dialog-titlebar').show();
                    UI.toggleFullscreen();
                    
                    UI.onresize();
                },
                "Close": function () {       
                    console.log($('.ui-dialog.ui-dialog--fullscreen'));
                    if($('.ui-dialog.ui-dialog--fullscreen').length > 0) {
                        UI.toggleFullscreen();
                    }
                    
                    $('#disconnectButton').trigger('click');

                    Wat.I.closeDialog($(this));
                },
            },
            button1Class : 'fa fa-expand',
            button2Class : 'fa fa-compress',
            button3Class : 'fa fa-ban',
            
            fillCallback : function (target) {
                // Add common parts of editor to dialog
                var template = _.template(
                    Wat.TPL.spyVM, {
                    }
                );

                var noVNCIncludes = '<script src="lib/thirds/noVNC/include/util.js"></script><script src="lib/thirds/noVNC/include/ui.js"></script>';
                
                target.html(template + noVNCIncludes); 
                
                UI.onresize = function () {
                    var dialogWidth = parseInt($('.dialog-container').css('width').replace('px',''));
                    var dialogHeight = parseInt($('.dialog-container').css('height').replace('px',''));
                    
                    var w = dialogWidth;
                    /*
                    if (w > 1024) {
                        w = 1024;
                    }
                    */
                    
                    var h = parseInt(2*(w/3));
                    
                    var maxHeight = window.innerHeight * 0.97;
                    if (h > maxHeight) {
                        h = maxHeight;
                        w = h * 1.5;
                    }
                    
                    var display = UI.rfb.get_display();
                    var scaleRatio = display.autoscale(w,h,false);
                    UI.rfb.get_mouse().set_scale(scaleRatio);
                    $('.noVNC_container').css('visibility', 'visible');
                };
                
                UI.updateDocumentTitle = function(rfb, name) {
                    $('.ui-dialog-titlebar').html($('.ui-dialog-titlebar').html() + ' - ' + name);
                };
                
                // Hide normal screen button from the begining
                $(".ui-dialog-buttonset button span.fa-compress").parent().hide();
                
                setTimeout(function () {
                    $('#noVNC_connect_button').trigger('click');
                }, 1000);
            }
        }

        that.dialog = Wat.I.dialog(dialogConf);  
    }
}