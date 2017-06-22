Wat.Collections.Plugins = Wat.Collections.DIG.extend({
    //model: Wat.Models.Plugin,
    
    initialize: function (attrs, opts) {
        Wat.Collections.DIG.prototype.initialize.apply(this, [attrs]);
        
        this.urlRoot = Wat.C.getApiUrl() + 'proxy/' + this.apiCode + '/osd/' + this.osdId;
    },
    
    parse: function (response) {
        return $.extend({}, response, this.mock(response));
    },
    
    mock: function () {
        var data = {};
        
        switch (this.id) {
            case 'execution_hooks':
                data = [
                    {
                        script: {
                            value: 10,
                            settings: {
                                execution_hook: 'first_connection'
                            }
                        }
                    },
                    {
                        script: {
                            value: 11,
                            settings: {
                                execution_hook: 'vma.on_state.connected'
                            }
                        }
                    },
                    {
                        script: {
                            value: 12,
                            settings: {
                                execution_hook: 'vma.on_state.expire'
                            }
                        }
                    }
                ]
                break;
            case 'desktop':
                data = [
                    {
                        wallpaper: {
                            value: 2,
                            settings: {
                            }
                        }
                    }
                ]
                break;
            case 'shortcuts':
                data = [
                    {
                        shortcut: {
                            id: 12,
                            name: 'QVD Website',
                            command: 'firefox',
                            icon_url: 'https://www.mozilla.org/media/img/styleguide/identity/firefox/guidelines-logo.7ea045a4e288.png',
                            icon_id: 45
                        }
                    }
                ]
                break;
        }
        
        return data;
    }
});