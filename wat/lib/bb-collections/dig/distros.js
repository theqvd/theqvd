Wat.Collections.Distros = Backbone.Collection.extend({
    actionPrefix: 'distro',
    apiCode: 'dig',
    
    parse: function(response) {
        return this.mock();
    },
    
    mock: function () {
        var os_distros = [
            {
                id: 1,
                name: 'Ubuntu',
                version: '16.04',
                icon: 'https://lh6.ggpht.com/RZeFXe1KB7fk9w6t7C8qM6rX6pyZIT6SrezUkTqTawVOKCw_ZRa2wQa3-9a_lO5gGU7e=w300',
                wallpaper: 23,
                vma_allow_sound: 0,
                vma_allow_printing: 0,
                vma_allow_sharing: 0,
                config_params: {
                    wallpaper: {
                        description: 'Wallpaper',
                        type: '__asset_list[type="wallpapers"]__',
                        list_options: null
                    },
                    vma_allow_sound: {
                        description: 'Allow sound',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_printing: {
                        description: 'Allow printing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_sharing: {
                        description: 'Allow folders and USB sharing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    }
                },
                scripts: [],
                shortcuts: []
            },
            {
                id: 2,
                name: 'SLES',
                version: '12 SP3',
                icon: 'https://www.iconfinder.com/data/icons/flat-round-system/512/opensuse-128.png',
                wallpaper: 23,
                vma_allow_sound: 0,
                vma_allow_printing: 0,
                vma_allow_sharing: 0,
                config_params: {
                    wallpaper: {
                        description: 'Wallpaper',
                        type: '__asset_list[type="wallpapers"]__',
                        list_options: null
                    },
                    vma_allow_sound: {
                        description: 'Allow sound',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_printing: {
                        description: 'Allow printing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_sharing: {
                        description: 'Allow folders and USB sharing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    }
                },
                scripts: [],
                shortcuts: []
            },
            {
                id: 3,
                name: 'Red Hat',
                version: '8',
                icon: 'https://cdn1.iconfinder.com/data/icons/nuove/128x128/apps/redhat.png',
                wallpaper: 23,
                vma_allow_sound: 0,
                vma_allow_printing: 0,
                vma_allow_sharing: 0,
                config_params: {
                    wallpaper: {
                        description: 'Wallpaper',
                        type: '__asset_list[type="wallpapers"]__',
                        list_options: null
                    },
                    vma_allow_sound: {
                        description: 'Allow sound',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_printing: {
                        description: 'Allow printing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    },
                    vma_allow_sharing: {
                        description: 'Allow folders and USB sharing',
                        type: 'list',
                        list_options: {
                            0: 'No',
                            1: 'Yes'
                        }
                    }
                },
                scripts: [],
                shortcuts: []
            }
        ];
        
        return os_distros;
    },
    
    url: function () {
        var url = Wat.C.getApiUrl() + 'proxy/' + this.apiCode + '/osd';
        
        return url;
    }
});