<div class="editor-container">
    <div data-i18n="Select where to perform the resetting of views"></div>
    <table class="editor-table alternate col-width-100">
        <% if (Wat.C.isSuperadmin()) { %>
        <tr>
                <td data-i18n="Tenant">
                </td>
            <td>
                    <%= tenantName %>
                    <input type="hidden" name="tenant_reset" value="<%= tenantId %>" />
                </td>
            </tr>
        <% } %>
        <tr>
            <td data-i18n="Section">
            </td>
            <td>
                <select name="section_reset">
                    <option value="<%= qvdObj %>"><%= qvdObjName %></option>
                    <option value="" data-i18n="All sections"></option>
                </select>
            </td>
        </tr>
    </table>
</div>