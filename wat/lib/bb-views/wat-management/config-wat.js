Wat.Views.ConfigWatView = Wat.Views.DetailsView.extend({
    qvdObj: 'configwat',
    editorViewClass: Wat.Views.ConfigWatEditorView,
    
    initialize: function () {
        // If user have not access to main section, redirect to home
        if (!Wat.C.checkACL('config.wat.')) {
            Wat.Router.watRouter.trigger('route:defaultRoute');
            return;
        }
        
        var params = {};
        this.model = new Wat.Models.ConfigWat(params);
        Wat.Views.DetailsView.prototype.initialize.apply(this, [params]);
    },
    
    setBreadCrumbs: function () {
        this.breadcrumbs = {
            'screen': 'Home',
            'link': '#',
            'next': {
                'screen': 'WAT Management',
                'next': {
                    'screen': 'WAT Config'
                }
            }
        };
    },
    
    setViewACL: function () {
        this.viewACL = 'config.wat.';
    },
    
    renderSide: function () {
        // No side rendered
        if (this.checkSide({'fake.acl': '.js-side-component1'}) === false) {
            return;
        }
    }
});