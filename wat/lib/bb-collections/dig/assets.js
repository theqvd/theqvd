Wat.Collections.Assets = Wat.Collections.DIG.extend({
    //model: Wat.Models.Asset,
    
    parse: function (response) {
        response = this.mock();
        
        // Mock filter
        var filteredResponse = [];
        if (this.filter) {
            var filter = this.filter;
            $.each (response, function (i, v) {
                if (filter.type == v.type) {
                    filteredResponse.push(v);
                }
            });
        }
        return filteredResponse;
    },
    
    initialize: function (attrs, opts) {
        opts = opts || {};
        
        this.filter = opts.filter;
        
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
    },
    
    mock: function () {
        var assets =  [
            {
                id: 1,
                url: 'http://www.planwallpaper.com/static/images/general-night-golden-gate-bridge-hd-wallpapers-golden-gate-bridge-wallpaper.jpg',
                name: 'Golden gate',
                type: 'wallpaper'
            },
            {
                id: 2,
                url: 'http://www.planwallpaper.com/static/images/555837.jpg',
                name: 'Big hero',
                type: 'wallpaper'
            },
            {
                id: 3,
                url: 'http://www.planwallpaper.com/static/images/wallpapers-7020-7277-hd-wallpapers.jpg',
                name: 'Cookie monster',
                type: 'wallpaper'
            },
            {
                id: 4,
                url: 'http://www.planwallpaper.com/static/images/6768666-1080p-wallpapers.jpg',
                name: 'Ball',
                type: 'wallpaper'
            },
            {
                id: 5,
                url: 'http://icons.iconarchive.com/icons/custom-icon-design/flatastic-11/256/Application-icon.png',
                name: 'Generic application',
                type: 'icon'
            },
            {
                id: 6,
                url: 'https://lh6.ggpht.com/RZeFXe1KB7fk9w6t7C8qM6rX6pyZIT6SrezUkTqTawVOKCw_ZRa2wQa3-9a_lO5gGU7e=w300',
                name: 'Ubuntu',
                type: 'icon'
            },
            {
                id: 7,
                url: 'https://www.iconfinder.com/data/icons/flat-round-system/512/opensuse-128.png',
                name: 'SLES',
                type: 'icon'
            },
            {
                id: 8,
                url: 'https://cdn1.iconfinder.com/data/icons/nuove/128x128/apps/redhat.png',
                name: 'Red Hat',
                type: 'icon'
            },
            {
                id: 9,
                url: 'https://www.mozilla.org/media/img/styleguide/identity/firefox/guidelines-logo.7ea045a4e288.png',
                name: 'Firefox',
                type: 'icon'
            },
            {
                id: 10,
                url: 'http://example.com/configure_anything.sh',
                name: 'configure_anything.sh',
                type: 'script'
            },
            {
                id: 11,
                url: 'http://example.com/log_connection.sh',
                name: 'log_connection.sh',
                type: 'script'
            },
            {
                id: 12,
                url: 'http://example.com/close_connection.sh',
                name: 'close_connection.sh',
                type: 'script'
            }
        ];
        
        return assets;
    },
    
    url: function () {
        var url = this.baseUrl() + '/asset';
        var url = this.baseUrl() + '/osd';
        
        return url;
    }
});