// Templates utilities
Wat.I.T = {
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
                    editorCommon: {
                        name: 'editor/common'
                    },
                    editorCommonProperties: {
                        name: 'editor/common-properties'
                    },
                    relatedDoc: {
                        name: 'doc/related-links'
                    },
                    viewCustomize: {
                        name: 'view/customize'
                    },
                    viewCustomizerTool: {
                        name: 'config/customizer-tool'
                    },
                    viewFormCustomize: {
                        name: 'view/customize-form'
                    }
                };
                break;
            case 'home':
                templates = {
                    home: {
                        name: 'home/home'
                    },
                    homeVMsExpire: {
                        name: 'home/vms-expire'
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
            case 'details':
                templates = {
                    detailsCommon: {
                        name: 'details/common'
                    },
                    detailsCommonProperties: {
                        name: 'details/common-properties'
                    },
                    details: {
                        name: 'details/' + params.qvdObj
                    },
                    detailsSide: {
                        name: 'details/' + params.qvdObj + '-side'
                    },
                    warn404: {
                        name: 'error/404'
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
            case 'commonEditors':
                templates['editor_' + params.qvdObj] = {
                    name: 'editor/' + params.qvdObj
                };
                break;
            case 'list':
                templates = {
                    listCommonList: {
                        name: 'list/common'
                    },
                    listCommonBlock: {
                        name: 'list/common-block'
                    },
                    selectChecks: {
                        name: 'dialog/select-checks'
                    },
                    sortingRow: {
                        name: 'list/sorting-row'
                    }
                }

                templates["editorNew_" + params.qvdObj] = {
                    name: 'creator/' + params.qvdObj
                };        

                templates["list_" + params.qvdObj] = {
                    name: 'list/' + params.qvdObj
                };

                // If qvd object is massive-editable, get massive editor template
                if ($.inArray(params.qvdObj, QVD_OBJS_MASSIVE_EDITABLE) != -1) {
                    templates.editorMassive = {
                        name: 'editor/' + params.qvdObj + '-massive'
                    };
                }
                break; 
            case 'about':
                templates = {
                    about: {
                        name: 'doc/about'
                    }
                }
                break;
            case 'commonDI':
                templates = {
                    editorAffectedVM: {
                        name: 'editor/affected-vms'
                    },
                    editorAffectedVMList: {
                        name: 'editor/affected-vms-list'
                    }
                };
                break;
            case 'profile':
                templates = {
                    profile: {
                        name: 'profile/profile'
                    }
                }
                
                templates['editor_' + params.qvdObj] = {
                    name: 'editor/' + params.qvdObj
                };
                break;
            case 'qvdConfig':
                templates = {
                    editorNew_config: {
                        name: 'creator/conf-token'
                    },
                    qvdConfig: {
                        name: 'config/qvd'
                    },
                    qvdConfigTokens: {
                        name: 'config/qvd-tokens'
                    }
                };
                break;
            case 'viewsDefault':                     
                templates = {
                    resetViewsDefault: {
                        name: 'editor/reset-views-default'
                    }
                }
                break;
            case 'viewsMine':
                templates = {
                    resetViewsMine: {
                        name: 'editor/reset-views-mine'
                    }
                }
                break;
            case 'detailsAdministrator':
                templates = {
                    inheritanceToolsRoles: {
                        name: 'details/role-inheritance-tools-roles'
                    },
                    aclsAdmins: {
                        name: 'details/administrator-acls-tree'
                    },
                }
                break;
            case 'properties':
                templates = {
                    property: {
                        name: 'list/property'
                    },
                    listProperty: {
                        name: 'list/property-list'
                    },
                    editorNew_property: {
                        name: 'creator/property'
                    },
                    editor_property: {
                        name: 'editor/property'
                    }
                }
                break;
            case 'detailsRole':
                templates = {
                    inheritanceToolsRoles: {
                        name: 'details/role-inheritance-tools-roles'
                    },
                    inheritanceToolsTemplates: {
                        name: 'details/role-inheritance-tools-templates'
                    },
                    inheritanceList: {
                        name: 'details/role-inheritance-list'
                    },
                    aclsRoles: {
                        name: 'details/role-acls-tree'
                    }
                }
                break;
            case 'tenantDetails':
                templates = {
                    deleteTenantDialog: {
                        name: 'dialog/delete-tenant'
                    },
                    deleteTenantDialogElements: {
                        name: 'dialog/delete-tenant-elements'
                    },
                    deleteTenantDialogEmpty: {
                        name: 'dialog/delete-tenant-empty'
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