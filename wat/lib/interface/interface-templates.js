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
                
                if (params.qvdObj == 'di') {
                    templates["futureTagsNote"] = {
                        name: 'details/di-future-tags-row-note'
                    };
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
                // If qvd object is editable, get editor template
                if ($.inArray(params.qvdObj, QVD_OBJS_EDITABLE) != -1) {
                    templates['editor_' + params.qvdObj] = {
                        name: 'editor/' + params.qvdObj
                    };
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
                
                // If qvd object is creatable, get creator template
                if ($.inArray(params.qvdObj, QVD_OBJS_CREATABLE) != -1) {
                    templates["editorNew_" + params.qvdObj] = {
                        name: 'creator/' + params.qvdObj
                    };
                }
                
                if (params.qvdObj == 'osf') {
                    templates["editorNew_di"] = {
                        name: 'creator/di'
                    };
                }
                
                templates["list_" + params.qvdObj] = {
                    name: 'list/' + params.qvdObj
                };

                // If qvd object is massive-editable, get massive editor template
                if ($.inArray(params.qvdObj, QVD_OBJS_MASSIVE_EDITABLE) != -1) {
                    templates.editorMassive = {
                        name: 'editor/' + params.qvdObj + '-massive'
                    };
                }
                
                if (QVD_OBJS_EMBEDDED_VIEWS[params.qvdObj]) {
                    $.each(QVD_OBJS_EMBEDDED_VIEWS[params.qvdObj], function (ieObj, embeddedObj) {
                        templates["embedded_" + params.qvdObj + '_' + embeddedObj] = {
                            name: 'list/embedded-' + params.qvdObj + '-' + embeddedObj
                        }
                    });
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
                    },
                    diProgressBar: {
                        name: 'details/di-progress-bar'
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
                        name: 'details/osd'
                    },
                    osConfiguration_hook: {
                        name: 'details/osd-hook'
                    },
                    osConfiguration_os: {
                        name: 'details/osd-os'
                    },
                    osConfiguration_pkg: {
                        name: 'details/osd-pkg'
                    },
                    osConfiguration_shortcut: {
                        name: 'details/osd-shortcut'
                    },
                    osConfiguration_vma: {
                        name: 'details/osd-vma'
                    },
                    osConfiguration_wallpaper: {
                        name: 'details/osd-wallpaper'
                    },
                    osConfigurationEditor: {
                        name: 'editor/osd'
                    },
                    osConfigurationEditorAppearance: {
                        name: 'editor/osd-appearance'
                    },
                    osConfigurationEditorApps: {
                        name: 'editor/osd-applications'
                    },
                    osConfigurationEditorPackages: {
                        name: 'editor/osd-packages'
                    },
                    osConfigurationEditorSettings: {
                        name: 'editor/osd-settings'
                    },
                    osConfigurationEditorShortcuts: {
                        name: 'editor/osd-shortcuts'
                    },
                    osConfigurationEditorShortcutsRows: {
                        name: 'editor/osd-shortcuts-rows'
                    },
                    osConfigurationEditorShortcutsRowsEdit: {
                        name: 'editor/osd-shortcuts-rows-edit'
                    },
                    osConfigurationEditorHooks: {
                        name: 'editor/osd-hooks'
                    },
                    osConfigurationEditorHooksManager: {
                        name: 'editor/osd-hooks-manager'
                    },
                    osConfigurationEditorHooksRows: {
                        name: 'editor/osd-hooks-rows'
                    },
                    osConfigurationEditorHooksRowsEdit: {
                        name: 'editor/osd-hooks-rows-edit'
                    },
                    osConfigurationEditorAssets: {
                        name: 'editor/osd-assets'
                    },
                    osConfigurationEditorAssetsOptions: {
                        name: 'editor/osd-assets-options'
                    },
                    osConfigurationEditorAssetsRows: {
                        name: 'editor/osd-assets-rows'
                    },
                    osConfigurationEditorAssetsUploadControl: {
                        name: 'editor/osd-assets-upload-control'
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