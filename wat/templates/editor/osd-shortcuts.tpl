<div class="<%= cid %>">
    <% if (massive) { %>
            <div class="info-header second_row" colspan=2>
                <span data-i18n class="fa fa-info-circle">This list will be added to the affected OSFs without remove existing items</span><br> 
            </div>
    <% } %>

    <div class="asset-switch-buttonset js-asset-switch-buttonset">
        <a class="button fleft fa fa-plus-circle js-button-open-shortcut-configuration js-select-mode" style="margin-right: 10px;" data-i18n="New shortcut">New shortcut</a>
        <a class="button fleft fa fa-upload js-show-upload js-upload-mode" style="margin-right: 10px;" data-i18n="Upload icon">Upload icon</a>
        <div class="fright col-width-40">
            <select class="js-change-mode col-width-40">
                <option value="selection" data-i18n="Manage shortcuts">Manage shortcuts</option>
                <option value="manage" data-i18n="Manage icons">Manage icons</option>
            </select>
        </div>
    </div>
    
    <div class="js-osf-conf-editor-control">
        <div class="js-os-conf-shortcuts-rows-editor--new hidden">
            <span data-i18n="New shortcut">New shortcut</span>
        </div>
        <div class="js-os-conf-shortcuts-rows-editor--edit hidden">
            <span data-i18n="Edit shortcut">Edit shortcut</span>: <span class="js-shortcut-name-edition"></span>
        </div>
        <table class="list js-os-conf-shortcuts-rows-editor hidden js-list-shortcuts os-conf-editor">
            <tr>
                <td>
                    <table class="col-width-100" style="table-layout: fixed;">
                        <tbody class="<%= cid %> bb-os-conf-shortcuts-rows-editor"></tbody>
                    </table>
                </td>
            </tr>
        </table>
    </div>

    <table class="list js-list-shortcuts os-conf-editor js-osf-conf-editor js-select-mode" style="table-layout: fixed;">
        <tbody class="bb-os-conf-shortcuts-rows select-mode"></tbody>
    </table>
    
    <table class="list js-list-shortcuts os-conf-editor js-osf-conf-editor js-upload-mode" style="table-layout: fixed;">
        <tbody>
            <tr>
                <td class="upload-mode hidden">
                    <div>
                        <a class="button2 fright fa fa-trash js-delete-selected-asset center" data-i18n="Delete selected" style="margin-bottom: 5px;">Delete selected</a>
                    </div>
                    <div style="height: 200px; width: 100%; overflow-y: auto;">
                        <table class="bb-os-conf-icon-assets list" data-control-id="icon">
                            <tr>
                                <td class="second_row" data-i18n="Loading icons">Loading icons</td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
    

    <div class="js-upload-control hidden">
        <span data-i18n="Upload icon">Upload icon</span>
    </div>
    <div class="bb-upload-control"></div>
</div>