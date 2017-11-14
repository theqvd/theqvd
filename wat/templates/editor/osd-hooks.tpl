<div class="<%= cid %>">
    <div class="asset-switch-buttonset js-asset-switch-buttonset">
        <a class="button fleft fa fa-plus-circle js-button-open-hook-configuration js-select-mode" style="margin-right: 10px;" data-i18n="New hook">New hook</a>
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
</div>