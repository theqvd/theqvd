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
                    footer: {
                        name: 'common/footer'
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
                    },
                    errorRefresh: {
                        name: 'error/refresh'
                    },
                    warn404: {
                        name: 'error/404'
                    },
                    formErrors: {
                        name: 'dialog/form-errors'
                    }
                };
                break;
            case 'conflict':
                templates = {
                    deleteDependency: {
                        name: 'dialog/conflict-delete-dependency'
                    },
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
                    }
                }
                break;
            case 'details':
                templates = {
                    detailsCommon: {
                        name: 'details/common'
                    },
                    detailsFieldsCommon: {
                        name: 'details/common-fields'
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
                    detailsFields: {
                        name: 'details/' + params.qvdObj + '-fields'
                    },
                    layoutDesktop: {
                        name: 'details/layout-desktop'
                    },
                    layoutMobile: {
                        name: 'details/layout-mobile'
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
                    },
                    selectedOptionsMenu: {
                        name: 'list/selected-options-menu'
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
            case 'commonAdministrator':
                templates = {
                    inheritanceToolsRoles: {
                        name: 'details/role-inheritance-tools-roles'
                    }
                }
                break;
            case 'detailsAdministrator':
                templates = {
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
            case 'commonRole':
                templates = {
                    inheritanceToolsRoles: {
                        name: 'details/role-inheritance-tools-roles'
                    },
                    inheritanceToolsTemplates: {
                        name: 'details/role-inheritance-tools-templates'
                    },
                    inheritanceToolsTemplatesMatrix: {
                        name: 'details/role-inheritance-tools-templates-matrix'
                    }
                }
                break;
            case 'detailsRole':
                templates = {
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
            case 'spyVM':
                templates = {
                    spyVM: {
                        name: 'common/vms-spy'
                    }
                }
                break;
            case 'vmDetails':
                templates = {
                    vmDetailsExpiration: {
                        name: 'details/vm-expiration'
                    },
                }
                break;
            case 'vmList':
                templates = {
                    vmListExpiration: {
                        name: 'list/vm-expiration'
                    },
                }
                break;
            case 'osDetails':
                templates = {
                    osConfiguration: {
                        name: 'details/osf-os-configuration'
                    },
                    osConfigurationEditor: {
                        name: 'editor/osf-os-configuration'
                    },
                    osConfigurationEditorAppearance: {
                        name: 'editor/osf-os-configuration-appearance'
                    },
                    osConfigurationEditorApps: {
                        name: 'editor/osf-os-configuration-applications'
                    },
                    osConfigurationEditorPackages: {
                        name: 'editor/osf-os-configuration-packages'
                    },
                    osConfigurationEditorSettings: {
                        name: 'editor/osf-os-configuration-settings'
                    },
                    osConfigurationEditorShortcuts: {
                        name: 'editor/osf-os-configuration-shortcuts'
                    },
                    osConfigurationEditorShortcutsRows: {
                        name: 'editor/osf-os-configuration-shortcuts-rows'
                    },
                    osConfigurationEditorScripts: {
                        name: 'editor/osf-os-configuration-scripts'
                    },
                    osConfigurationEditorScriptsManager: {
                        name: 'editor/osf-os-configuration-scripts-manager'
                    },
                    osConfigurationEditorScriptsRows: {
                        name: 'editor/osf-os-configuration-scripts-rows'
                    },
                    osConfigurationEditorAssetOptions: {
                        name: 'editor/osf-os-configuration-asset-options'
                    },
                    packageBlockWrapper: {
                        name: 'list/package-block-wrapper'
                    }
                }
                break;
            case 'importOSsettings':
                templates = {
                    importableOSFDI: {
                        name: 'list/importable-osf-di'
                    }
                }
            default:
                // Empty object will be returned
                break;
        }
        
        return templates;
    }
}