Wat.Collections.Packages = Wat.Collections.Collection.extend({
    model: Wat.Models.Package,
    
    parse: function(rawResponse) {
        var that = this;
        var startIndex = (this.offset - 1) * this.block;
        var endIndex = startIndex + this.block - 1;
        var page = [];

        if (this.filters.search) {
            var response = [];
            
            $.each(rawResponse, function (index, p) {
                if (!p) {
                    return;
                }

                if (p.package.indexOf(that.filters.search) !== -1) {
                    response.push(p);
                }
            });
        }
        else {
            var response = rawResponse;
        }
            
        for(i=startIndex;i<=endIndex;i++) {
            if (!response[i]) {
                continue;
            }
            page.push(response[i]);
        }
        
        this.elementsTotal = response.length;
        
        return page;
    },
    
    sync: function(method, model, options) {
        var that = this;
        
        var params = _.extend({
            type: 'GET',
            dataType: 'json',
            url: 'packages.json',
            processData: false
        }, options);
        
        params.error = Wat.A.processResponseError;

        return $.ajax(params);
    }
});