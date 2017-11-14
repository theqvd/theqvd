<div class="<%= cid %>">
    <div class="asset-switch-buttonset js-asset-switch-buttonset">
        <a class="button fright fa fa-upload js-show-upload js-upload-mode" data-asset-type="icon" data-plugin-id="shortcut" style="margin-right: 10px;" data-i18n="Upload icon">Upload icon</a>
        <a class="button fright fa fa-upload js-show-upload js-upload-mode hidden" data-asset-type="wallpaper" data-plugin-id="wallpaper" style="margin-right: 10px;" data-i18n="Upload wallpaper">Upload wallpaper</a>
        <a class="button fright fa fa-upload js-show-upload js-upload-mode hidden" data-asset-type="script" data-plugin-id="hook" style="margin-right: 10px;" data-i18n="Upload script">Upload script</a>
        <div class="fleft col-width-40">
            <select class="js-change-mode col-width-40">
                <option value="icon" data-i18n="Icons" selected="selected">Icons</option>
                <option value="wallpaper" data-i18n="Wallpapers">Wallpapers</option>
                <option value="script" data-i18n="Scripts">Scripts</option>
            </select>
        </div>
    </div>
    
    <table class="list js-list-shortcuts os-conf-editor js-osf-conf-editor js-upload-mode" data-asset-type="icon" data-plugin-id="shortcut" style="table-layout: fixed;">
        <tbody>
            <tr>
                <td class="upload-mode hidden">
                    <div style="height: 200px; width: 100%; overflow-y: auto;">
                        <table class="bb-os-conf-icon-assets list" data-asset-type="icon">
                            <tr>
                                <td class="second_row" data-i18n="Loading icons">Loading icons</td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
    
    <div class="js-upload-control hidden" data-asset-type="icon">
        <span data-i18n="Upload icon">Upload icon</span>
    </div>
    <div class="bb-upload-control js-upload-control" data-asset-type="icon"></div>
    
    <table class="js-editor-table list js-osf-conf-editor os-conf-editor js-upload-mode hidden" data-asset-type="wallpaper" data-plugin-id="wallpaper">
        <tr>
            <td class="col-width-60">
                <div style="height: 200px; width: 100%; overflow-y: auto;">
                    <table class="bb-os-conf-wallpaper-assets list" data-asset-type="wallpaper">
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
                <div class="js-data-preview-box data-preview-box" data-preview-id="wallpaper" class="data-preview"></div>
                <div class="js-data-preview-message data-preview-message hidden fa fa-cogs"> Loading preview...</div>
            </td>
        </tr>
    </table>
    
    <div class="js-upload-control hidden" data-asset-type="wallpaper">
        <span data-i18n="Upload wallpaper">Upload wallpaper</span>
    </div>
    <div class="bb-upload-control js-upload-control" data-asset-type="wallpaper"></div>
    
    <table class="list js-list-hooks os-conf-editor js-osf-conf-editor js-upload-mode hidden" data-asset-type="script" data-plugin-id="hook" style="table-layout: fixed;">
        <tbody>
            <tr>
                <td class="col-width-60 upload-mode hidden">
                    <div style="height: 200px; width: 100%; overflow-y: auto;">
                        <table class="bb-os-conf-script-assets list" data-asset-type="script">
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
                    <div class="js-data-preview-box data-preview-box data-preview-box--script" data-preview-id="script" class="data-preview"></div>
                    <div class="js-data-preview-message data-preview-message hidden fa fa-cogs"> Loading preview...</div>
                </td>
            </tr>
        </tbody>
    </table>
    
    <div class="js-upload-control hidden" data-asset-type="script">
        <span data-i18n="Upload script">Upload script</span>
    </div>
    <div class="bb-upload-control js-upload-control" data-asset-type="script"></div>
</div>