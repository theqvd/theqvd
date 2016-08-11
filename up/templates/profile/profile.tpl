<div class="<%= cid %> section-container">
    <table class="details">
        <tr>
            <th><span data-i18n="Parameter"></th>
            <th><span data-i18n="Value"></th>
        <tr>
            <td><i class="<%= CLASS_ICON_USER %>"></i><span data-i18n="Username"></span></td>
            <td>
                <%= model.get('username') %>
            </td>
        </tr>
        <tr>
            <td><i class="<%= CLASS_ICON_LANGUAGE %>"></i><span data-i18n="Language"></span></td>
            <td>
                <select name="language" class="js-form-field">
                    <%
                    $.each(UP_LANGUAGE_OPTIONS, function (lanCode, lanName) {
                    %>
                        <option value="<%= lanCode %>" data-i18n="<%= lanName %>" <%= lanCode == model.get('language') ? 'selected' : '' %>><%= lanName %></option>
                    <%
                    }) 
                    %>
                </select>
            </td>
        </tr>
            <tr>
                <td colspan=2><a class="button js-save-profile-btn fa fa-save fright" data-i18n="Save"></a></td>
            </tr>
    </table>
</div>