<div class="<%= cid %>">
    <% if (editorCategories) { %>
        <ul class="editor-tabs js-editor-tabs">
            <% 
            $.each(editorCategories, function (iCat, cat) { 
                if (cat.isEnabled != undefined && !cat.isEnabled()) {
                    return;
                }
                if (cat.acls != undefined && !Wat.C.checkACL(cat.acls, cat.aclsLogic)) {
                    return;
                }
            %>
                <li data-tab="<%= cat.code %>" data-i18n="<%= cat.text %>"><%= cat.text %></li>
            <% }); %>
        </ul>
    <% } %>
    <div class="editor-container <%= cid %> js-editor-container js-editor-container-<%= editorMode %>" data-qvd-obj="<%= qvdObj %>">
        <table class="editor-table js-editor-table <%= editorMode == "massive_edit" ? 'massive-editor-table js-massive-editor-table' : '' %> alternate">
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
                        <tr data-tab-field="general">
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
            <tbody class="bb-editor-extra js-editor-extra"></tbody>
            <tbody class="bb-custom-properties custom-properties"></tbody>
            <% if (editorCategories) { %>
                <tbody>
                    <tr>
                        <td colspan=2>
                            <a class="button2 fa fa-angle-right fright js-next-tab" data-i18n="More settings">More settings</a>
                        </td>
                    </tr>
                </tbody>
            <% } %>
        </table>
    </div>
</div>
