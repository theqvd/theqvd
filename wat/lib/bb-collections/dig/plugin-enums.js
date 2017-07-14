Wat.Collections.PluginEnums = Wat.Collections.DIG.extend({
    //model: Wat.Models.Plugin,
    
    initialize: function (attrs, opts) {
        this.location = attrs.location;
        
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
    },
    
    parse: function (response) {
        return this.mock(response);
    },
    
    mock: function (response) {
        response[0].icon = 'https://lh6.ggpht.com/RZeFXe1KB7fk9w6t7C8qM6rX6pyZIT6SrezUkTqTawVOKCw_ZRa2wQa3-9a_lO5gGU7e=w300';
        response[1].icon = 'https://seeklogo.com/images/C/centos-logo-494F57D973-seeklogo.com.png';
        
        return response;
    },
    
    url: function () {
        var url = this.baseUrl() + this.location;
        
        return url;
    }
});