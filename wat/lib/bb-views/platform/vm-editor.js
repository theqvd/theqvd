Wat.Views.VMEditorView = Wat.Views.EditorView.extend({
    qvdObj: 'vm',
    
    initialize: function(params) {
        this.extendEvents(this.editorEvents);
        
        Wat.Views.EditorView.prototype.initialize.apply(this, [params]);
    },
    
    editorEvents: {
        'change select[name="osf_id"]': 'fillDITags'
    },
    
    renderCreate: function (target, that) {
        if (Wat.CurrentView.qvdObj == 'user') {
            this.model = new Wat.Models.VM();
        }
        else {
            Wat.CurrentView.model = new Wat.Models.VM();
        }
        
        $('.ui-dialog-titlebar').html($.i18n.t('New Virtual machine'));
        
        Wat.Views.EditorView.prototype.renderCreate.apply(this, [target, that]);
        
        // If main view is user view, we are creating a virtual machine from user details view.
        // User and tenant (if exists) controls will be removed
        if (Wat.CurrentView.qvdObj == 'user') {
            $('[name="user_id"]').parent().parent().remove();

            var userHidden = document.createElement('input');
            userHidden.type = "hidden";
            userHidden.name = "user_id";
            userHidden.value = Wat.CurrentView.model.get('id');
            $('.editor-container').append(userHidden);

            if ($('[name="tenant_id"]').length > 0) {
                $('[name="tenant_id"]').parent().parent().remove();

                var tenantHidden = document.createElement('input');
                tenantHidden.type = "hidden";
                tenantHidden.name = "tenant_id";
                tenantHidden.value = Wat.CurrentView.model.get('tenant_id');
                $('.editor-container').append(tenantHidden);

                // Store tenantId to be used on OSF filter
                var tenantId = tenantHidden.value;
            }
        }
        else if ($('[name="tenant_id"]').length > 0) {
            // When tenant id is present attach change events. User, osf and di will be filled once the events were triggered
            Wat.B.bindEvent('change', 'select[name="tenant_id"]', Wat.B.editorBinds.filterTenantOSFs);
            Wat.B.bindEvent('change', '[name="tenant_id"]', Wat.B.editorBinds.filterTenantUsers);
            Wat.I.chosenElement('[name="user_id"]', 'advanced100');
            Wat.I.chosenElement('[name="osf_id"]', 'advanced100');
            Wat.I.chosenElement('[name="di_tag"]', 'advanced100');
            return;
        }
        else {
            // Fill Users select on virtual machines creation form. 
            // This filling has sense when the view is the VM view and tenant filter is not present
            var params = {
                'actionAuto': 'user',
                'selectedId': '',
                'controlName': 'user_id',
                'chosenType': 'advanced100'
            };

            Wat.A.fillSelect(params, function () {}); 
        }

        // Fill OSF select on virtual machines creation form
        var params = {
            'actionAuto': 'osf',
            'selectedId': '',
            'controlName': 'osf_id',
            'chosenType': 'advanced100'
        };

        // If tenant is defined, use it on OSF filter
        if (tenantId) {
            params.filters = {
                tenant_id: tenantId
            };
        }

        Wat.I.chosenElement('[name="di_tag"]', 'advanced100');

        $('[name="osf_id"] option').remove();

        Wat.A.fillSelect(params, function () {
            // Fill DI Tags select on virtual machines creation form after fill OSF combo
            var params = {
                'actionAuto': 'tag',
                'selectedId': 'default',
                'controlName': 'di_tag',
                'filters': {
                    'osf_id': $('[name="osf_id"]').val()
                },
                'nameAsId': true,
                'chosenType': 'advanced100'
            };

            Wat.A.fillSelect(params); 
        });
    },
    
    renderUpdate: function (target, that) {
        Wat.Views.EditorView.prototype.renderUpdate.apply(this, [target, that]);
        
        $('.ui-dialog-titlebar').html($.i18n.t('Edit Virtual machine') + ": " + this.model.get('name'));
        
        // Virtual machine form include a date time picker control, so we need enable it
        Wat.I.enableDataPickers();
                
        var params = {
            'actionAuto': 'tag',
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
    
    createElement: function () {
        var properties = this.parseProperties('create');
                
        var context = $('.' + this.cid + '.editor-container');

        var user_id = context.find('[name="user_id"]').val();
        var osf_id = context.find('select[name="osf_id"]').val();
        
        var arguments = {
            "user_id": user_id,
            "osf_id": osf_id
        };
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('vm.create.properties')) {
            arguments["__properties__"] = properties.set;
        }
        
        var di_tag = context.find('select[name="di_tag"]').val();
        
        if (di_tag && Wat.C.checkACL('vm.create.di-tag')) {
            arguments.di_tag = di_tag;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            arguments["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            arguments["description"] = description;
        }
        
        var vmView = Wat.U.getViewFromQvdObj('vm');
        
        vmView.createModel(arguments, vmView.fetchList);
    },
    
    updateElement: function (dialog) {
        // If current view is list, use selected ID as update element ID
        if (Wat.CurrentView.viewKind == 'list') {
            Wat.CurrentView.id = Wat.CurrentView.selectedItems[0];
        }
        
        var properties = this.parseProperties('update');
        
        var context = $('.' + this.cid + '.editor-container');
        
        var name = context.find('input[name="name"]').val();
        var di_tag = context.find('select[name="di_tag"]').val(); 
        var description = context.find('textarea[name="description"]').val();

        var filters = {"id": Wat.CurrentView.id};
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('vm.update.properties')) {
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
            var expiration_soft = context.find('input[name="expiration_soft"]').val();
            var expiration_hard = context.find('input[name="expiration_hard"]').val();
            
            if (expiration_soft != undefined) {
                arguments['expiration_soft'] = Wat.U.stringDateToDatabase(expiration_soft);
            }
            if (expiration_hard != undefined) {
                arguments['expiration_hard'] = Wat.U.stringDateToDatabase(expiration_hard);
            }
        }
        
        if (Wat.C.checkACL('vm.update.description')) {
            arguments["description"] = description;
        }
                
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.fetchAny);
    },
    
    updateMassiveElement: function (dialog, id) {
        var properties = this.parseProperties('update');
        
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('vm.update.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var di_tag = context.find('select[name="di_tag"]').val(); 
        
        var filters = {"id": id};
        
        if (Wat.I.isMassiveFieldChanging("description") && Wat.C.checkACL('vm.update.description')) {
            arguments["description"] = description;
        }
        
        if (Wat.I.isMassiveFieldChanging("di_tag") && Wat.C.checkACL('vm.update.di-tag')) {
            arguments["di_tag"] = di_tag;
        }
        
        if (Wat.C.checkACL('vm.update.expiration')) {
            var expiration_soft = context.find('input[name="expiration_soft"]').val();
            var expiration_hard = context.find('input[name="expiration_hard"]').val();

            if (expiration_soft != undefined && Wat.I.isMassiveFieldChanging("expiration_soft")) {
                arguments['expiration_soft'] = expiration_soft;
            }

            if (expiration_hard != undefined && Wat.I.isMassiveFieldChanging("expiration_hard")) {
                arguments['expiration_hard'] = expiration_hard;
            }
        }
        
        Wat.CurrentView.resetSelectedItems();
        
        var auxModel = new Wat.Models.VM();
        Wat.CurrentView.updateModel(arguments, filters, Wat.CurrentView.fetchList, auxModel);
    },
    
    // Fill the select combo with the available tags in the disk images of an OSF
    fillDITags: function (event) {
        var that = event.data;

        $('[name="di_tag"]').find('option').remove();

        // Fill DI Tags select on virtual machines creation form
        var params = {
            'actionAuto': 'tag',
            'selectedId': '',
            'controlName': 'di_tag',
            'filters': {
                'osf_id': $('[name="osf_id"]').val()
            },
            'nameAsId': true,
            'chosenType': 'advanced100',
            'orderFirst': ['head', 'default']
        };

        Wat.A.fillSelect(params);
    },
});