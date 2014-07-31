var UserDetailsView = DetailsView.extend({
    config: {
        'new_item_text': 'tButton.new_user'
    },
    
    detailsTemplateName: 'details-user',
    
    breadcrumbs: {
        'screen': 'home',
        'link': '#/home',
        'next': {
            'screen': 'users_list',
            'link': '#/users',
            'next': {
                'screen': 'user_details'
            }
        }
    },

    initialize: function (params) {
        this.model = new User();
        DetailsView.prototype.initialize.apply(this, [params]);
        
        // Render Virtual Machines list on side
        var params = {};
        params.whatRender = 'list';
        params.listContainer = '.bb-details-side';
        params.forceListColumns = {name: true, info: true, checks: true};
        
        var sideView = new VMListView(params);     
    }
});