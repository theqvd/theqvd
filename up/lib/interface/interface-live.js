Up.I.L = {
    spies: {},
    spyMouseOver: function (selector, leaveCallback) {
        // Only create spy when it is not defined yet
        if (typeof this.spies[selector] == 'undefined') {
            this.spies[selector] = setInterval(function() {
                // If mouse is not over hoverable div, trigger mouseleave event as hack to avoid fails on native HTML event
                if ($(selector).length && !$(selector + ':hover').length) {
                    $.each($(selector), function (iElement, element) {
                        leaveCallback({target: $(element)});
                    });
                }
            }, 500);
        }
    },
    
    clearSpies: function () {
        $.each(this.spies, function (iSpy, spy) {
            clearInterval(spy);
        });
        
        this.spies = {};
    }
}
