Wat.Views.DIListView = Wat.Views.ListView.extend({
    qvdObj: 'di',
    liveFields: ['percentage', 'elapsed_time', 'state', 'status_message', 'osf_id'],
    relatedDoc: {
        image_update: "Images update guide"
    },
    
    initialize: function (params) {
        this.collection = new Wat.Collections.DIs(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    renderList: function (params) {
        Wat.Views.ListView.prototype.renderList.apply(this, [params]);
        
        this.renderInfo();
        this.renderProgressBars();
        
        this.execModelFunctions();
        
        Wat.T.translate();
    },
    
    execModelFunctions: function () {
        var that = this;
        
        $.each($('[data-model-function]'), function (i, element) {
            var f = $(element).attr('data-model-function');
            var id = parseInt($(element).attr('data-id'));
            var model = that.collection.where({id: id})[0]
            
            that[f](element, model);
        });
    },
    
    listEvents: {
        'change input[data-name="di_default"]': 'setDefault',
        'click .js-more-tags': 'showExtraTags',
        'change .js-selected-actions-select': 'applySelectedAction',
        'click .js-unshrink-btn': 'unshrinkRows',
        'click input.check_all[data-embedded-view="di"]': 'checkAll',
        'click input.check-it[data-embedded-view="di"]': 'checkOne',
    },
    
    showExtraTags: function (e) {
        var di_id = $(e.target).attr('data-di_id');
        $('.extra-tags-' + di_id).show();
        $(e.target).hide();
    },
    
    setDefault: function (e) {
        var di_id = $(e.target).attr('data-di_id');
        
        var filters = {"id": di_id};
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            },
        };
        
        var auxModel = new Wat.Models.DI();
            
        this.tagChanges = arguments['__tags_changes__'];
        
        this.updateModel(arguments, filters, this.checkMachinesChanges, auxModel);
    },
    
    applyDefault: function (that) {
        // Came from list view
        var id = that.applyFilters.id[0];
        var checkMachinesChanges = that.checkMachinesChanges;
        that.model = that.collection.where({id: id})[0];
        
        var arguments = {
            "__tags_changes__": {
                'create': ['default'],
            }
        }
        
        that.tagChanges = arguments['__tags_changes__'];

        that.updateModel(arguments, {id: id}, checkMachinesChanges);
    },
    
    applyPublish: function (that) {
        // Came from list view
        var id = that.applyFilters.id[0];
        
        that.model = new Wat.Models.DI();
        
        that.model.setEndpoint('di/publish');
        that.model.setExtraUrlArguments('&id=' + id);
        
        var messages = {
            'success': 'Successfully updated',
            'error': 'Error updating'
        };
        
        that.saveModel({}, {}, messages, function () {
            // Uncheck all DI checks
            $('.js-check-it:checked').prop('checked',true).trigger('click');
        });
    },
    
    renderEmbeddedBlockList: function () {
        this.renderEmbeddedList();
    },
    
    renderEmbeddedList: function () {
        var that = this;
        
        var osfId = $('.dis-subrow').attr('data-dis-row');
        var osdId = $('.dis-subrow').attr('data-osd-id');
        
        // Creation is enabled for old OSFs and dig OSFs if dig is enabled
        var enabledCreation = !osdId || Wat.C.isOsfDigEnabled(osfId);
        
        this.template = _.template(
            Wat.TPL.embedded_osf_di, {
                cid: this.cid,
                models: this.collection.models,
                selectedActions: Wat.C.purgeConfigData(Wat.I.selectedActions.di),
                osfId: osfId,
                enabledCreation: enabledCreation,
                shrinkFactor: 3
            }
        );
        
        $('.dis-subrow .bb-list').html(this.template);
        
        this.execModelFunctions();
        
        this.renderInfo();
        this.renderProgressBars();
        
        Wat.T.translateAndShow();
        
        // Open websockets for live fields
        if (this.liveFields) {
            Wat.WS.openListWebsockets(this.qvdObj, this.collection, this.liveFields, this.cid);
        }
    },
    
    // Render tags of a model and set it on the title attribute of an element
    renderTags: function (element, model) {
        $(element).attr('title', '&raquo; ' + model.get('tags').replace(/,/g,'<br /><br />&raquo; '));
    },
    
    // Render future tags of a model and set it on the title attribute of an element
    renderFutureTags: function (element, model) {
        if (model.get('tags')) {
            var tags = '&raquo; ' + model.get('tags').replace(/,/g,'<br /><br />&raquo; ');
            tags = $.i18n.t('Tags') + ':<br /><br />' + tags;
        }
        else {
            var tags = $.i18n.t('Tags') + ': ' + $.i18n.t('No');
        }
        
        var def = model.get('default') ? $.i18n.t('Yes') : $.i18n.t('No');
        
        var futureTags = $.i18n.t('Settings after publication') + ': <br /><br /> default: ' + def + '<br /><br />' + tags;
        
        $(element).attr('title', futureTags);
    },
    
    applySelectedAction: function (e) {
        // Apply action
        Wat.Views.ListView.prototype.applySelectedAction.apply(this, [e]);
        
        // Reset combo after apply action
        $(e.target).val('').trigger('chosen:updated');
    },
    
    // Show hidden rows on shrinked lists
    unshrinkRows: function () {
        $('tr.js-rows-unshrink-row').remove();
        $('tr.js-shrinked-row').show();
    },
    
    renderInfo: function () {
        var that = this;
        
        $.each(this.collection.models, function (i, model) {
            var hiddenIfPublished = '';
            var hiddenIfReadyOrPublished = '';
            var hiddenIfNotPublished = '';
            switch (model.get('state')) {
                case 'published':
                    hiddenIfPublished = 'hidden';
                    hiddenIfReadyOrPublished = 'hidden';
                    break;
                case 'ready':
                    hiddenIfReadyOrPublished = 'hidden';
                    hiddenIfNotPublished = 'hidden';
                    break;
                default:
                    hiddenIfNotPublished = 'hidden';
                    break;
            }
            
            var template = _.template(
                Wat.TPL['diInfoIcons'], {
                    model: model,
                    infoRestrictions: that.infoRestrictions,
                    statesList: Wat.I.detailsFields.di.general.fieldList.state.options,
                    hiddenIfPublished: hiddenIfPublished,
                    hiddenIfReadyOrPublished: hiddenIfReadyOrPublished,
                    hiddenIfNotPublished: hiddenIfNotPublished
                }
            );

            $('.bb-di-info[data-id="' + model.get('id') + '"]').html(template);
        });
    }
});
