<div class="editor-container <%= cid %> js-editor-container-<%= editorMode %>">
    <table class="editor-table alternate">
         <%
         if (editorMode == "massive_edit") {
         %>
            <tbody>
                <tr>
                    <td colspan=2></td>
                        <div class="info-header nopadding">
                            <span data-i18n class="fa fa-info-circle">Some fields are not available to be edited in massive edition</span><br> 
                        </div>
                    </td>
                </tr>
            </tbody>
         <%
         }
         %>
        <%
            // If the user is superadmin, show tenants select in creation form
            if (classifiedByTenant && editorMode == 'create' && isSuperadmin) {
        %>
                <tbody class="tenant-selector">
                    <tr>
                        <td data-i18n="Tenant"></td>
                        <td>
                            <select class="" name="tenant_id" id="tenant_editor"></select>
                        </td>
                    </tr>
                </tbody>
        <%
            }
        %>
        
        <tbody class="bb-editor"></tbody>
        <tbody class="bb-custom-properties custom-properties"></tbody>
    </table>
</div>