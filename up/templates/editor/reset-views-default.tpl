<div class="editor-container">
    <div data-i18n="Select where to perform the resetting of views"></div>
    <table class="editor-table alternate col-width-100">
        <% if (Up.C.isSuperadmin()) { %>
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
                <input type="radio" name="section_reset" checked value="<%= qvdObj %>"><span for="section_reset"><%= qvdObjName %></span>
                <input type="radio" name="section_reset" value=""><span for="section_reset" data-i18n="All sections"></span>
            </td>
        </tr>
    </table>
</div>