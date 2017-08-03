<table class="js-editor-table editor-table list os-conf-editor os-conf-editor--scripts">
    <tr>
        <td class="col-width-50 js-select-mode">
            <div class="editor-title">
                Execution
            </div>
            <div>
                <select class="js-starting-script-mode bb-os-conf-scripts-type-options" data-new-file data-form-field-name="execution_hook">
                    <% $.each(hookOptions, function (hookCode, hookName) { %>
                        <option value="<%= hookCode %>"><%= hookName %></option>
                    <% }); %>
                </select>
            </div>
            <div  class="editor-title col-width-100">
                Scripts
                <a class="button2 button-icon fright fa fa-upload js-toggle-upload-select-mode center" title="Upload" data-i18n="[title]Upload"></a>
            </div>
            <% if (massive) { %>
                <div class="info-header second_row" colspan=2>
                    <span data-i18n class="fa fa-info-circle">This list will be added to the affected OSFs without remove existing items</span><br> 
                </div>
            <% } %>
            <div>
                <table class="bb-os-conf-script-assets js-asset-selector asset-selector list" data-control-id="<%= assetType %>">
                    <tr>
                        <td class="second_row" data-i18n="Loading scripts">Loading scripts</td>
                    </tr>
                </table>
            </div>
        </td>
        <td class="col-width-50 js-upload-mode hidden">
            <a class="button2 button-icon fright fa fa-arrow-circle-left js-toggle-upload-select-mode center" title="Back" data-i18n="[title]Back"></a>
            <div class="editor-title">
                Upload script
            </div>
            <div>
                <div>
                    <input type="file" name="asset_file"/>
                </div>
                <a class="button2 fright fa fa-upload js-upload-script center" data-i18n="Upload script">Upload script</a>
            </div>
        </td>
        <td class="col-width-60">
            <div class="editor-title">
                <span data-i18n="Preview">Preview</span>
            </div>
            <div class="js-data-preview-box data-preview-box data-preview-box--script" data-preview-id="<%= assetType %>"></div>
        </td>
    </tr>
</table>