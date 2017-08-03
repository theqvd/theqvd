<div class="<%= cid %>">
    <div class="asset-switch-buttonset">
        <a class="button2 fright fa fa-cog js-show-manage-mode center js-select-mode" data-i18n="Manage wallpapers">Manage wallpapers</a>
        <a class="button2 fright fa fa-image js-show-select-mode center hidden js-upload-mode" data-i18n="Wallpaper selection">Wallpaper selection</a>
    </div>
    <table class="js-editor-table editor-table list os-conf-editor os-conf-editor--appearance">
        <tr class="js-upload-control upload-control hidden">
            <td class="col-width-100" colspan=2>
                <div class="col-width-49 fleft">
                    <input type="text" name="asset_name" data-i18n="[placeholder]Name"/>
                </div>
                <div class="col-width-49 fright">
                    <input type="file" name="asset_file"/>
                </div>
                <div class="col-width-100">
                    <a class="button2 fright fa fa-upload js-upload-asset center" data-i18n="Upload">Upload</a>
                    <a class="button2 fright fa fa-ban js-show-upload center" data-i18n="Cancel">Cancel</a>
                </div>
            </td>
        </tr>
        <tr>
            <td class="col-width-50 js-select-mode select-mode">
                <div class="editor-title" data-i18n="Wallpaper">Wallpaper</div>
                <div class="asset-selector-wrapper">
                    <select class="bb-os-conf-wallpaper-assets bb-os-conf-wallpaper-type-options js-asset-selector asset-selector list" data-control-id="<%= assetType %>">
                        <option data-i18n="Loading wallpapers">Loading wallpapers</option>
                    </select>
                </div>
            </td>
            <td class="col-width-50 js-upload-mode upload-mode hidden">
                <div>
                    <a class="button2 fright button-icon fa fa-trash js-delete-selected-asset center" title="Delete" data-i18n="[title]Delete"></a>
                    <a class="button2 fright button-icon fa fa-upload js-show-upload center" title="Upload" data-i18n="[title]Upload"></a>
                </div>
                <div style="height: 200px; width: 100%; overflow-y: auto;">
                    <table class="bb-os-conf-wallpaper-assets list" data-control-id="<%= assetType %>">
                        <tr>
                            <td class="second_row" data-i18n="Loading wallpapers">Loading wallpapers</td>
                        </tr>
                    </table>
                </div>
            </td>
            <td class="col-width-50 js-preview preview">
                <div class="editor-title">
                    <span data-i18n="Preview">Preview</span>
                </div>
                <div class="js-data-preview-box data-preview-box" data-preview-id="<%= assetType %>" class="data-preview"></div>
                <div class="js-data-preview-message data-preview-message hidden fa fa-cogs"> Loading preview...</div>
            </td>
        </tr>
    </table>
</div>