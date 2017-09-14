<div class="<%= cid %>">
    <div class="asset-switch-buttonset js-asset-switch-buttonset">
        <a class="button fleft fa fa-plus-circle js-button-open-hook-configuration js-select-mode" style="margin-right: 10px;" data-i18n="New hook">New hook</a>
        <a class="button fleft fa fa-upload js-show-upload js-upload-mode" style="margin-right: 10px;" data-i18n="Upload script">Upload script</a>
        <div class="fright col-width-40">
            <select class="js-change-mode col-width-40">
                <option value="selection" data-i18n="Manage hooks">Manage hooks</option>
                <option value="manage" data-i18n="Manage scripts">Manage scripts</option>
            </select>
        </div>
    </div>
    
    <div class="js-osf-conf-editor-control">
        <div class="js-os-conf-hooks-rows-editor--new hidden">
            <span data-i18n="New hook">New hook</span>
        </div>
        <div class="js-os-conf-hooks-rows-editor--edit hidden">
            <span data-i18n="Edit hook">Edit hook</span>: <span class="js-hook-name-edition"></span>
        </div>
        <table class="list js-os-conf-hooks-rows-editor hidden js-list-hooks os-conf-editor">
            <tr>
                <td>
                    <table class="col-width-100" style="table-layout: fixed;">
                        <tbody class="<%= cid %> bb-os-conf-hooks-rows-editor"></tbody>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    
    <table class="list js-list-hooks os-conf-editor js-osf-conf-editor js-select-mode" style="table-layout: fixed;">
        <tbody class="bb-os-conf-hooks-rows select-mode"></tbody>
    </table>
    
    <table class="list js-list-hooks os-conf-editor js-osf-conf-editor js-upload-mode" style="table-layout: fixed;">
        <tbody>
            <tr>
                <td class="col-width-60 upload-mode hidden">
                    <div>
                        <a class="button2 fright fa fa-trash js-delete-selected-asset center" data-i18n="Delete selected" style="margin-bottom: 5px;">Delete selected</a>
                    </div>
                    <div style="height: 200px; width: 100%; overflow-y: auto;">
                        <table class="bb-os-conf-script-assets list" data-control-id="<%= assetType %>">
                            <tr>
                                <td class="second_row" data-i18n="Loading scripts">Loading scripts</td>
                            </tr>
                        </table>
                    </div>
                </td>
                <td class="col-width-40 js-preview preview">
                    <div class="editor-title">
                        <span data-i18n="Preview">Preview</span>
                    </div>
                    <div class="js-data-preview-box data-preview-box data-preview-box--script" data-preview-id="<%= assetType %>" class="data-preview"></div>
                    <div class="js-data-preview-message data-preview-message hidden fa fa-cogs"> Loading preview...</div>
                </td>
            </tr>
        </tbody>
    </table>
    
    <div class="js-upload-control hidden">
        <span data-i18n="Upload script">Upload script</span>
    </div>
    <div class="bb-upload-control"></div>
</div>