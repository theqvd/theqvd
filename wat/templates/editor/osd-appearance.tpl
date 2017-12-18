<div class="<%= cid %>">
    <table class="js-editor-table list js-osf-conf-editor os-conf-editor os-conf-editor--appearance">
        <tr>
            <td class="col-width-60 js-select-mode select-mode">
                <div class="editor-title" data-i18n="Wallpaper">Wallpaper</div>
                <div class="asset-selector-wrapper">
                    <select name="asset_selector_wallpaper" class="bb-os-conf-wallpaper-assets bb-os-conf-wallpaper-type-options js-asset-selector asset-selector list" data-asset-type="<%= assetType %>">
                        <option data-i18n="Loading wallpapers">Loading wallpapers</option>
                    </select>
                </div>
                <div>
                    <a href="javascript:" class="fa fa-file-o js-go-to-assets-management fright" data-asset-type="wallpaper" data-i18n="Manage wallpapers"></a>
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
</div>