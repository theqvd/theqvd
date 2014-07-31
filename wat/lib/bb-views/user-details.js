var UserDetailsView = DetailsView.extend({
    config: {
        'new_item_text': 'tButton.new_user'
    },
    
    detailsTemplateName: 'details-user',
    detailsSideTemplateName: 'details-user-side',
    sideContainer: '.bb-details-side',
    
    breadcrumbs: {
        'screen': 'home',
        'link': '#/home',
        'next': {
            'screen': 'users_list',
            'link': '#/users',
            'next': {
                'screen': ''
            }
        }
    },

    initialize: function (params) {
        this.model = new User();
        DetailsView.prototype.initialize.apply(this, [params]);
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-details-side1';
        params.forceListColumns = {checks: true, info: true, name: true};
        params.forceSelectedActions = {disconnect: true};
        params.forceListActionButton = null;
        
        var sideView = new VMListView(params);     
    },
    
    render: function () {
        // Add name of the model to breadcrumbs
        this.breadcrumbs.next.next.screen = this.model.get('name');
        
        DetailsView.prototype.render.apply(this);
        
        this.templateDetailsSide = this.getTemplate(this.detailsSideTemplateName);
        
        this.template = _.template(
            this.templateDetailsSide, {
                model: this.model
            }
        );
        
        $(this.sideContainer).html(this.template);
    }
});