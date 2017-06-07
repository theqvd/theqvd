Wat.Views.OSFListView = Wat.Views.ListView.extend({
    qvdObj: 'osf',
    liveFields: ['number_of_vms', 'number_of_dis'],

    initialize: function (params) {
        this.collection = new Wat.Collections.OSFs(params);
        
        // Retrieve distros list
        this.distros = new Wat.Collections.Distros({});
        this.distros.fetch();
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    // This events will be added to view events
    listEvents: {},
    
    openNewElementDialog: function (e) {
        this.model = new Wat.Models.OSF();
        this.dialogConf.title = $.i18n.t('New OS Flavour');
        
        Wat.Views.ListView.prototype.openNewElementDialog.apply(this, [e]);
        
        Wat.I.chosenElement('select[name="os_distro_select"]','single100');
        
        //Fill distros select
        $.each (this.distros.models, function (iDistro, distro) {
            var opt = document.createElement("OPTION");
            $(opt).val(distro.get('id')).html(distro.get('name') + '-' + distro.get('version'));
            $('select[name="os_distro_select"').append(opt);
        });
        $('select[name="os_distro_select"').trigger('chosen:updated');
    },
    
    createElement: function () {
        var valid = Wat.Views.ListView.prototype.createElement.apply(this);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
                
        var context = $('.' + this.cid + '.editor-container');

        var name = context.find('input[name="name"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        args = {
            name: name,
            memory: DEFAULT_OSF_MEMORY
        };
        
        if (memory && Wat.C.checkACL('osf.create.memory')) {
            args['memory'] = memory;
        }
        
        if (Wat.C.checkACL('osf.create.user-storage')) {
            args['user_storage'] = user_storage;
        }
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.create.properties')) {
            args["__properties__"] = properties.set;
        }
        
        var name = context.find('input[name="name"]').val();
        if (name) {
            args["name"] = name;
        }
        
        var description = context.find('textarea[name="description"]').val();
        if (description) {
            args["description"] = description;
        }
                 
        if (Wat.C.isSuperadmin()) {
            var tenant_id = context.find('select[name="tenant_id"]').val();
            args['tenant_id'] = tenant_id;
        }
        
        var distro_id = $('select[name="os_distro_select"]').val();
        
        // If distro is setted, create an OSD on DIG
        if (distro_id != OSF_DISTRO_COMMON_ID) {
            var that = this;
            this.OSDmodel.save({}, {
                success: function () {
                    args['osd_id'] = that.OSDmodel.get('id');
                    
                    that.createModel(args, that.fetchList);
                }
            });
            return;
        }
        
        this.createModel(args, this.fetchList);
    },
    
    updateMassiveElement: function (dialog, id) {
        var valid = Wat.Views.ListView.prototype.updateElement.apply(this, [dialog]);
        
        if (!valid) {
            return;
        }
        
        // Properties to create, update and delete obtained from parent view
        var properties = this.properties;
        
        var arguments = {};
        
        if (!$.isEmptyObject(properties.set) && Wat.C.checkACL('osf.update-massive.properties')) {
            arguments["__properties_changes__"] = properties;
        }
        
        var context = $('.' + this.cid + '.editor-container');
        
        var description = context.find('textarea[name="description"]').val();
        var memory = context.find('input[name="memory"]').val();
        var user_storage = context.find('input[name="user_storage"]').val();
        
        var filters = {"id": id};
        
        
        if (Wat.I.isMassiveFieldChanging("description") && Wat.C.checkACL(this.qvdObj + '.update-massive.description')) {
            arguments["description"] = description;
        }
        
        if (Wat.I.isMassiveFieldChanging("memory") && Wat.C.checkACL('osf.update-massive.memory')) {
            arguments["memory"] = memory;
        }
        
        if (Wat.I.isMassiveFieldChanging("user_storage") && Wat.C.checkACL('osf.update-massive.user-storage')) {
            arguments["user_storage"] = user_storage;
        }
        
        this.resetSelectedItems();
        
        var auxModel = new Wat.Models.OSF();
        this.updateModel(arguments, filters, this.fetchList, auxModel);
    }
});