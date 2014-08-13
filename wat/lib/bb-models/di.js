Wat.Models.DI = Wat.Models.Model.extend({
    action: "di_get_details",
    
    defaults: {
        name: 'New Disk image'
    },
    
    parse: function (response) {
        // If parse is done in details view, we get head and default tags 
        // to independent attributes
        if (this.detailsView) {
            var tags = [];
            var tagHead = false;
            var tagDefault = false;

            $(response.result.rows[0].tags).each( function (index, tag) {
                if (tag.tag == 'head') {
                    tagHead = true;
                }
                else if (tag.tag == 'default') {
                    tagDefault = true;
                }
                else if (tag.tag != response.result.rows[0].version) {
                    tags.push(tag.tag);
                }
            });
            
            response.result.rows[0].tags = tags.join(',');
            response.result.rows[0].default = tagDefault ? 1 : 0;
            response.result.rows[0].head = tagHead ? 1 : 0;
        }
        
        return Wat.Models.Model.prototype.parse.apply(this, [response]);
    }

});