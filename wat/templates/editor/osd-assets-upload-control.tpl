<table class="js-editor-table list os-conf-editor upload-control">
    <tr>
        <td>
                <div class="col-width-48 fright js-asset-name-wrapper">
                    <input type="text" name="asset_name" data-i18n="[placeholder]Name" data-asset-type="<%= assetType %>" data-plugin-id="<%= pluginId %>"/>
                </div>
                <div class="col-width-48 fleft js-asset-file-wrapper">
                    <input type="file" name="asset_file" data-asset-type="<%= assetType %>" data-plugin-id="<%= pluginId %>"/>
                </div>
        </td>
    </tr>
    <tr>
        <td>
                <a class="button2 fright fa fa-upload js-upload-asset center" data-asset-type="<%= assetType %>" data-plugin-id="<%= pluginId %>" data-i18n="Upload">Upload</a>
                <a class="button2 fright fa fa-ban js-hide-upload center" data-asset-type="<%= assetType %>" data-i18n="Cancel">Cancel</a>
        </td>
    </tr>
</table>