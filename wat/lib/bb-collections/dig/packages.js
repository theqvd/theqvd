Wat.Collections.Packages = Wat.Collections.DIG.extend({
    model: Wat.Models.Package,
    filters: {},
    
    initialize: function (params) {
        params = params || {};
        
        this.offset = params.offset;
        this.block = params.block;
    },
    
    parse: function(rawResponse) {
        this.elementsTotal = rawResponse.total || 0;

        return rawResponse.packages;
    },
    
    url: function () {
        var url = this.baseUrl() + '/osd/' + Wat.CurrentView.OSDmodel.id + '/pkg';
        
        url+= '?offset=' + this.offset + '&limit=' + this.block + '&sort=name,asc';
        
        if (this.filters.search) {
            url+= '&name=' + this.filters.search;
        }
        
        if (this.filters.installed) {
            url+= '&installed=true';
        }
        
        return url;
    },
});