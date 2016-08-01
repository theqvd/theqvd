<table class="details details-list col-width-50">
    <tr>
        <td><i class="<%= CLASS_ICON_LANGUAGE %>"></i><span data-i18n="Language"></span></td>
        <td>
            <select name="language">
                <% 
                $.each(UP_LANGUAGE_OPTIONS, function (lanCode, lanName) {
                %>
                    <option value="<%= lanCode %>"><%= lanName %></option>
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