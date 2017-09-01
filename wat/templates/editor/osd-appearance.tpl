<div class="<%= cid %>">
    <div class="asset-switch-buttonset js-asset-switch-buttonset">
        <a class="button fleft fa fa-upload js-show-upload js-upload-mode" style="margin-right: 10px;" data-i18n="Upload wallpaper">Upload wallpaper</a>
        <div class="fright col-width-40">
            <select class="js-change-mode col-width-40">
                <option value="selection" data-i18n="Wallpaper selection">Wallpaper selection</option>
                <option value="manage" data-i18n="Manage wallpapers">Manage wallpapers</option>
            </select>
        </div>
    </div>
    
    <table class="js-editor-table list js-osf-conf-editor os-conf-editor os-conf-editor--appearance">
        <tr>
            <td class="col-width-60 js-select-mode select-mode">
                <div class="editor-title" data-i18n="Wallpaper">Wallpaper</div>
                <div class="asset-selector-wrapper">
                    <select class="bb-os-conf-wallpaper-assets bb-os-conf-wallpaper-type-options js-asset-selector asset-selector list" data-control-id="<%= assetType %>">
                        <option data-i18n="Loading wallpapers">Loading wallpapers</option>
                    </select>
                </div>
            </td>
            <td class="col-width-60 js-upload-mode upload-mode hidden">
                <div>
                    <a class="button2 fright fa fa-trash js-delete-selected-asset center" data-i18n="Delete selected" style="margin-bottom: 5px;">Delete selected</a>
                </div>
                <div style="height: 200px; width: 100%; overflow-y: auto;">
                    <table class="bb-os-conf-wallpaper-assets list" data-control-id="<%= assetType %>">
                        <tr>
                            <td class="second_row" data-i18n="Loading wallpapers">Loading wallpapers</td>
                        </tr>
                    </table>
                </div>
            </td>
            <td class="col-width-40 js-preview preview">
                <div class="editor-title">
                    <span data-i18n="Preview">Preview</span>
                </div>
                <div class="js-data-preview-box data-preview-box" data-preview-id="<%= assetType %>" class="data-preview"></div>
                <div class="js-data-preview-message data-preview-message hidden fa fa-cogs"> Loading preview...</div>
            </td>
        </tr>
    </table>
    
    <div class="js-upload-control hidden">
        <span data-i18n="Upload wallpaper">Upload wallpaper</span>
    </div>
    <div class="bb-upload-control"></div>
</div>