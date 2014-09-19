Wat.Views.SetupRoleDetailsView = Wat.Views.DetailsView.extend({  
    setupCommonTemplateName: 'setup-common',
    setupOption: 'roles',
    secondaryContainer: '.bb-setup',
    qvdObj: 'role',

    initialize: function (params) {
        this.model = new Wat.Models.Role(params);
        
        this.params = params;
        
        this.renderSetupCommon();
    },
    
    renderSetupCommon: function () {

        this.templateSetupCommon = Wat.A.getTemplate(this.setupCommonTemplateName);
        var cornerMenu = Wat.I.getCornerMenu();
        
        // Fill the html with the template and the model
        this.template = _.template(
            this.templateSetupCommon, {
                model: this.model,
                cid: this.cid,
                selectedOption: this.setupOption,
                setupMenu: cornerMenu.setup.subMenu
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');

        // After render the side menu, embed the content of the view in secondary container
        this.embedContent();
    },
    
    embedContent: function () {
        $(this.secondaryContainer).html('<div class="bb-content-secondary"></div>');

        this.el = '.bb-content-secondary';
        Wat.Views.DetailsView.prototype.initialize.apply(this, [this.params]);
    },
    
    openEditElementDialog: function(e) {
        this.dialogConf.title = $.i18n.t('Edit Role') + ": " + this.model.get('name');
        
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
            'nameAsId': true
        };

        Wat.A.fillSelect(params);
        
        Wat.I.chosenElement('[name="di_tag"]', 'single100');
    },
    
    updateElement: function (dialog) {
        var valid = Wat.Views.DetailsView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var di_tag = context.find('select[name="di_tag"]').val(); 
        var blocked = context.find('input[name="blocked"][value=1]').is(':checked');
        
        var filters = {"id": this.id};
        var arguments = {
            "propertyChanges": properties,
            "name": name,
            "di_tag": di_tag,
            "blocked": blocked ? 1 : 0
        };
        
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
                
        this.updateModel(arguments, filters, this.fetchDetails);
    },
    
    bindEditorEvents: function() {
        Wat.Views.DetailsView.prototype.bindEditorEvents.apply(this);
        
        // Toggle controls for new password
        this.bindEvent('change', 'input[name="change_password"]', this.vmEditorBinds.toggleNewPassword);
    },
    
    vmEditorBinds: {
        toggleNewPassword: function () {
            $('.new_password_row').toggle();
        }
    }
});