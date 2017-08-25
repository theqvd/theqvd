Wat.Views.OSDPackagesEditorView = Wat.Views.OSDEditorView.extend({
    qvdObj: 'osf',
    
    initialize: function (params) {
        this.params = params;
    
        Wat.Views.DialogView.prototype.initialize.apply(this, [params]);
    },
    
    dialogEvents: {
    },
    
    render: function () {
        var template = _.template(
            Wat.TPL.osConfigurationEditorPackages, {
                massive: this.massive,
                cid: this.cid
            }
        );
        
        $('.bb-os-conf-packages').html(template);
        
        this.renderPackages();
    },
    
    renderPackages: function() {
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-packages-wrapper';
        params.forceListActionButton = null;

        params.forceSelectedActions = {};
        params.offset = 1;
        params.block = 8;
        Wat.CurrentView.embeddedViews = Wat.CurrentView.embeddedViews || {};
        
        Wat.CurrentView.embeddedViews.package = new Wat.Views.PackageListView(params);
        
        $.each (Wat.CurrentView.embeddedViews.package.events, function (actionSelector, func) {
            actionSelector = actionSelector.split(' ');
            var action = actionSelector.shift();
            var selector = actionSelector.join(' ');
            e = {
                target: $(selector)
            };
            Wat.B.bindEvent(action, selector, $.proxy(Wat.CurrentView.embeddedViews.package[func], Wat.CurrentView.embeddedViews.package), e);
        });
    },
});