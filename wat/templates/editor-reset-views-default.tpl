<div class="editor-container">
    <div data-i18n="Select where to perform the resetting of views"></div>
    <table class="editor-table alternate col-width-100">
        <tr>
            <td>
                Section
            </td>
            <td>
                <select name="section_reset">
                    <option value="<%= qvdObj %>"><%= qvdObjName %></option>
                    <option value="">All sections</option>
                </select>
            </td>
        </tr>
        <% if (Wat.C.isSuperadmin()) { %>
            <tr>
                <td>
                    Tenant
                </td>
                <td>
                    <select name="tenant_reset">
                        <option value="<%= tenantId %>"><%= tenantName %></option>
                        <option value="">All tenants</option>
                    </select>
                </td>
            </tr>
        <% } %>
    </table>
</div>