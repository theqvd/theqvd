// Templates utilities
Up.I.T = {
    getTemplateList: function (code, params) {
        var templates = {};

        switch(code) {
            case 'starting':        
                templates = {
                    main: {
                        name: 'common/main'
                    },
                    menu: {
                        name: 'common/menu'
                    },
                    relatedDoc: {
                        name: 'doc/related-links'
                    },
                    viewCustomizerTool: {
                        name: 'config/customizer-tool'
                    }
                };
                break;
            case 'settings':
                templates = {
                    settings: {
                        name: 'config/settings'
                    },
                    settingsRow: {
                        name: 'config/settings-row'
                    },
                    settingsList: {
                        name: 'config/settings-list'
                    },
                    settingsDetails: {
                        name: 'config/settings-details'
                    }
                }
                break;
            case 'downloads':
                templates = {
                    downloads: {
                        name: 'downloads/downloads'
                    }
                }
                break;
            case 'info':
                templates = {
                    infoConnection: {
                        name: 'info/connection'
                    }
                }
                break;
            case 'help':
                templates = {
                    help: {
                        name: 'help/help'
                    }
                }
                break;
            case 'login':
                templates = {
                    login: {
                        name: 'login/login'
                    },
                    errorRefresh: {
                        name: 'error/refresh'
                    }
                }
                break;
            case 'doc':
                templates = {
                    docSection: {
                        name: 'doc/doc'
                    },
                    docSearch: {
                        name: 'doc/doc-search'
                    },
                    docSearchResult: {
                        name: 'doc/doc-search-result'
                    }
                }
                break;
            case 'docSection':
                templates = {
                    docSection: {
                        name: 'doc/guides/' + params.lan + '/' + params.guide,
                        cache: false
                    }
                }
                break;
            case 'confirm':
                templates = {
                    confirmTemplate: {
                        name: params.templateName,
                        cache: false
                    }
                }
                break;
            case 'list':
                templates = {
                    listCommonList: {
                        name: 'list/common'
                    },
                    listCommonBlock: {
                        name: 'list/common-block'
                    },
                    settingsDetails: {
                        name: 'config/settings-details'
                    }
                }
                break; 
            case 'about':
                templates = {
                    about: {
                        name: 'doc/about'
                    }
                }
                break;
            case 'profile':
                templates = {
                    profile: {
                        name: 'profile/profile'
                    }
                }
                break;
            default:
                // Empty object will be returned
                break;
        }
        
        return templates;
    }
}