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
                    header: {
                        name: 'common/header'
                    },
                    headerSection: {
                        name: 'common/header-section'
                    },
                    relatedDoc: {
                        name: 'doc/related-links'
                    }
                };
                break;
            case 'settings':
                templates = {
                    settingsRow: {
                        name: 'settings/settings-row'
                    },
                    settingsList: {
                        name: 'settings/settings-list'
                    },
                    settingsOptions: {
                        name: 'settings/settings-options'
                    }
                }
                break;
            case 'desktops':
                templates = {
                    workspacesSelectOption: {
                        name: 'desktops/workspaces-select-option'
                    },
                    dialogClientNotInstalled: {
                        name: 'dialog/client-not-installed'
                    }
                };

                templates["list-grid_desktops"] = {
                    name: 'desktops/desktops-grid'
                };  

                templates["list-list_desktops"] = {
                    name: 'desktops/desktops-list'
                };
                
                templates["list-list_desktops"] = {
                    name: 'desktops/desktops-list'
                };
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
                    settingsEditor: {
                        name: 'settings/settings-editor'
                    }
                }

                templates[params.qvdObj + 'CommonBlock'] = {
                    name: params.qvdObj + '/' + params.qvdObj + '-block'
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