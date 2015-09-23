Wat.I.C = {
    // List of the sass files excluding 'lib/_variables_custom.scss' because it will be customized
    sassFiles: [
        'style.scss',
        'lib/_mixins.scss',
        'lib/_place_holders.scss',
        'lib/_variables.scss',
        'components/_buttons.scss',
        'components/_documentation.scss',
        'components/_filters.scss',
        'components/_fonts.scss',
        'components/_forced.scss',
        'components/_forms.scss',
        'components/_general.scss',
        'components/_icons.scss',
        'components/_layout-details.scss',
        'components/_layout-editor.scss',
        'components/_layout-home.scss',
        'components/_layout-list.scss',
        'components/_layout-login.scss',
        'components/_layout-roles.scss',
        'components/_layout-setup.scss',
        'components/_layout.scss',
        'components/_navigation.scss',
        'components/_pagination.scss',
        'components/_reset.scss',
        'components/_tables.scss',
        'components/_thirds.scss',
    ],
    
    prefixSassFiles: 'style/',
    customVarFilename: 'lib/_variables_custom.scss',
    
    status: 'stopped',
    
    // Initialize customizer widget
    initCustomizer: function () {
        var that = this;
        
        $('.js-customizer-wrapper').show();
        
        if (this.status != 'stopped') {
            return;
        }
        
        this.status = 'starting';
        
        $('.js-customizer-wrapper').buildMbExtruder({
            position:"left",
            width:270,
            extruderOpacity:.9,
            hidePanelsOnClose:true,
            accordionPanels:true,
            onExtOpen:function(){
                if ($('.bb-customizer').html() == '') {
                    // Fill customizer tool layer with content
                    $('.bb-customizer').html(Wat.TPL.viewCustomizerTool);
                    Wat.T.translate();
                    Wat.I.chosenConfiguration();
                    Wat.I.chosenElement('select.js-customize-select', 'single100');
                    
                    that.events();
                    $('select.js-customize-select').trigger('change');
                    
                    // Instanciate colorpickers
                    $('.colorpicker').colorpicker();
                    
                    $('.ext_wrapper .footer').remove();
                }
            },
            onExtContentLoad:function(){},
            onExtClose:function(){}
        });

        $('.js-customizer-wrapper').find('object').removeAttr('fill');
        if ($(window).scrollTop() > 0) {
            $('.js-customizer-wrapper').css('top', '40px');
        }
        else {
            $('.js-customizer-wrapper').css('top', '60px');
        }
        
        $('.js-customizer-wrapper').show();
        
        this.loadSassFiles();
    },
    
    hideCustomizer: function () {
        $('.js-customizer-wrapper').hide();
    },
    
    loadSassFiles: function () {
        var that = this;
        
        Sass.setWorkerUrl('lib/thirds/sass.js/sass.worker.js');
        this.sass = new Sass();
        
        var sassFiles = this.sassFiles;
        var prefix = this.prefixSassFiles;
        var i = 0;
        
        var writeSassFile = function (filename) {
            $.ajax({
                url: encodeURI(prefix + filename),
                method: 'GET',
                async: true,
                contentType: 'text',
                cache: false,
                success: function (content) {
                    that.sass.writeFile(filename, content, function callback(success) {
                        i++;
                        if (sassFiles[i]) {
                            writeSassFile (sassFiles[i])
                        }
                    });
                },
                error: function (e) {
                    console.error(e);
                    i++;
                    
                    if (sassFiles[i]) {
                        writeSassFile (sassFiles[i])
                    }
                }
            });
        }
        
        // Wait one second for security
        setTimeout(function () {
            writeSassFile(sassFiles[i]);
        }, 1000);
    },
    
    events: function () {
        $('.js-preview-custom-btn').on('click', this.preview);
        $('.js-export-custom-btn').on('click', this.export);
        $('.js-restore-custom-btn').on('click', this.restore);
        $('.js-customize-select').on('change', this.selectChange);
    },
    
    selectChange: function (e) {
        $('.js-customize-section').hide();
        
        var selectedSectionName = $(e.target).val();
        $('.js-customize-section[name="' + selectedSectionName + '"]').show();
    },
    
    preview: function () {          
        $('.js-customizer-wrapper').closeMbExtruder();
        Wat.I.loadingBlock($.i18n.t('Generating preview') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        
        var content = Wat.I.C.getCustomVarContent();
                
        var filename = Wat.I.C.customVarFilename;
        
        Wat.I.C.sass.writeFile(filename, content, function callback(success) {
            if (success) {
                Wat.I.C.sass.compileFile('/style.scss', function (result) {
                    if (result.status == 0) {
                        $('style[name="custom-preview-css"]').html(result.text);
                        Wat.CurrentView.render();
                        Wat.I.loadingUnblock();
                        $('.js-customizer-wrapper').openMbExtruder();
                    }
                    else {
                        Wat.I.loadingUnblock();
                        $('.js-customizer-wrapper').openMbExtruder();
                        Wat.I.showMessage({messageType: 'error', message: result.message});
                    }
                });
            }
        });
    },
    
    export: function () {
        $('.js-customizer-wrapper').closeMbExtruder();
        Wat.I.loadingBlock($.i18n.t('Generating CSS file. When downloading were finished, replace custom_style.css on server to make changes permanent.') + '<br><br>' + $.i18n.t('Do not close or refresh the window'));
        
        var content = Wat.I.C.getCustomVarContent();
                
        var filename = Wat.I.C.customVarFilename;
        
        Wat.I.C.sass.writeFile(filename, content, function callback(success) {
            console.log(success);
            if (success) {
                Wat.I.C.sass.compileFile('/style.scss', function (result) {
                    console.log(result);
                    if (result.status == 0) {
                        var blob = new Blob([result.text], {type: "text/plain;charset=utf-8"});
                        Wat.I.loadingUnblock();
                        $('.js-customizer-wrapper').openMbExtruder();
                        
                        saveAs(blob, "custom_style.css");
                    }
                    else {
                        Wat.I.loadingUnblock();
                        $('.js-customizer-wrapper').openMbExtruder();
                        Wat.I.showMessage({messageType: 'error', message: result.message});
                        Wat.I.C.sass.listFiles(function callback(list) {
                          console.info(list);
                        });
                        
                    }
                });
            }
        });
    },
    
    restore: function () {
        $('style[name="custom-preview-css"]').html('');
        
        $.each($('.js-custom-field'), function (iCF, customField) {
            $(customField).val($(customField).attr('data-original-value'));
            $(customField).trigger('keyup');
        });
        
        Wat.CurrentView.render();
    },
    
    getCustomVarContent: function () {
        var customVarColMapping = {
            'button_bg': 'cpButton1Bg',
            'button_text': 'cpButton1Text',
            'button2_bg': 'cpButton2Bg',
            'button2_text': 'cpButton2Text',
            
            'header_bg': 'cpHeaderBg',
            
            'footer_bg': 'cpFooterBg',
            'footer_text': 'cpFooterText',
            
            'col_links_text': 'cpLink',
            
            'login_bg': 'cpLoginBoxBg',
            'login_text': 'cpLoginBoxText',
            
            'graph_color_a': 'cpGraphColorA',
            'graph_color_b': 'cpGraphColorB',
            
            'menu_bg': 'cpMenuBg',
            'menu_text': 'cpMenuText',
            'menu_border': 'cpMenuBorder',
            'menu_hover_bg': 'cpMenuHoverBg',
            'menu_hover_text': 'cpMenuHoverText',
            'menu_selected_bg': 'cpMenuSelectedBg',
            'menu_selected_text': 'cpMenuSelectedText',

            'menu_header_text': 'cpMenuHeaderText',
            'menu_header_selected_text': 'cpMenuHeaderSelectedText',

            'submenu_bg': 'cpSubmenuBg',
            'submenu_text': 'cpSubmenuText',
            'submenu_border': 'cpSubmenuBorder',
            'submenu_hover_bg': 'cpSubmenuHoverBg',
            'submenu_hover_text': 'cpSubmenuHoverText',
            
            'table_header_bg': 'cpTableThBg',
            'table_header_text': 'cpTableThText',
            'table_sorted_header_bg': 'cpTableSortedThBg',
            'table_sorted_header_text': 'cpTableSortedThText',
        };  
        
        var customVarImgMapping = {
            'header_logo': 'cpHeaderLogo',
            'login_logo': 'cpLoginLogo',
        };
        
        var content = "";
        
        var configStyle = {};

        $.each(customVarColMapping, function (variableName, inputName) {
            content += "$" + variableName + ": " + $('input[name="' + inputName + '"]').val() + ";";
            
            configStyle[variableName] = $('input[name="' + inputName + '"]').val();
        });
        
        $.each(customVarImgMapping, function (variableName, inputName) {
            content += "$" + variableName + ": '" + $('input[name="' + inputName + '"]').val() + "';";

            configStyle[variableName] = $('input[name="' + inputName + '"]').val();
        });
        
        // JSON format is for future feature
        var configStyleJSON = JSON.stringify(configStyle);
        
        return content;
    }
}
