<table>
    <% if (Wat.C.isSuperadmin()) { %>
        <tr>
            <td data-i18n="Tenant"></td>
            <td>
                <span><%= $('select[name="tenant_id"] option:selected').html() %></span>
            </td>
        </tr>
    <% } %>
    <tr>
        <td data-i18n="Key"></td>
        <td>
            <input type="text" name="key" value="" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Value"></td>
        <td>
            <input type="text" name="value" value="">
        </td>
    </tr>
</table>