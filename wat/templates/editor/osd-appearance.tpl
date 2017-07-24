<table class="js-editor-table editor-table list os-conf-editor os-conf-editor--appearance <%= cid %>">
    <tr>
        <td class="col-width-40 js-select-mode select-mode">
            <div>
                <a class="button2 button-icon fright fa fa-upload js-toggle-upload-select-mode center" title="Upload" data-i18n="[title]Upload"></a>
                <div class="editor-title">
                    Walpaper
                </div>
            </div>
            <div>
                <table class="bb-os-conf-wallpaper-assets js-asset-selector asset-selector list" data-control-id="<%= assetType %>">
                    <tr>
                        <td class="second_row" data-i18n="Loading scripts">Loading scripts</td>
                    </tr>
                </table>
            </div>
        </td>
        <td class="col-width-40 js-upload-mode upload-mode hidden">
            <div>
                <a class="button2 button-icon fright fa fa-arrow-circle-left js-toggle-upload-select-mode center" title="Back" data-i18n="[title]Back"></a>
                <div class="editor-title">
                    Upload wallpaper
                </div>
            </div>
            <div>
                <div>
                    <input type="text" name="wallpaper_name" data-i18n="[placeholder]Name"/>
                </div>
                <div>
                    <input type="file" name="wallpaper_file"/>
                </div>
                <a class="button2 fright fa fa-upload js-upload-wallpaper center" data-i18n="Upload wallpaper">Upload wallpaper</a>
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