Wat.Models.DI = Wat.Models.Model.extend({
    actionPrefix: 'di',
    
    defaults: {
        name: 'New Disk image',
        blocked: 0
    },
    
    parse: function (response) {
        // If parse is done in details view, we get head and default tags 
        // to independent attributes
        if (this.detailsView && response.status != 0) {
            Wat.I.showMessage({message: "ERROR #" + response.status + ": " + response.message, messageType: "error"});
            return {};
        }
        
        if (response.result) {
            var model = response.result.rows[0];
        }
        else {
            var model = response;
        }
        
        if (model != undefined) {
            var tags = [];
            var tagHead = false;
            var tagDefault = false;
            
            $(model.tags).each( function (index, tag) {
                if (tag.tag == 'head') {
                    tagHead = true;
                }
                else if (tag.tag == 'default') {
                    tagDefault = true;
                }
                else if (tag.tag != model.version) {
                    tags.push(tag.tag);
                }
            });

            model.tags = tags.join(',');
            model.default = tagDefault ? 1 : 0;
            model.head = tagHead ? 1 : 0;
        }
        
        return Wat.Models.Model.prototype.parse.apply(this, [response]);
    }

});