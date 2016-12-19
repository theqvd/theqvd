<table>
    <tr>
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input id="name" type="text" name="name" value="" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <tr>
        <td data-i18n="Password" class="mandatory-label"></td>
        <td>
            <input type="password" name="password" value="" data-required data-equal="password">
        </td>
    </tr>
    <tr>
        <td data-i18n="Re-type password" class="mandatory-label"></td>
        <td>
            <input type="password" name="password2" value="" data-required data-equal="password">
        </td>
    </tr>
    <% 
    if (Wat.C.checkACL('administrator.create.language')) { 
    %>
    <tr>
        <td data-i18n="Language"></td>
        <td>
            <select class="" name="language">
                <%
                    $.each(WAT_LANGUAGE_ADMIN_OPTIONS, function (lanCode, lanText) {
                        var selected = '';
                        if (lanCode == 'default') {
                            selected = 'selected="selected"';
                        }
                %>
                        <option <%= selected %> value="<%= lanCode %>" data-i18n="<%= lanText %>"></option>
                <%
                    });
                %>
            </select>
        </td>
    </tr>
    <% 
    } 
    %>
    <% if(Wat.C.checkACL('administrator.update.assign-role')) { %>
        <tr>
            <td data-i18n="Assign roles"></td>
            <td>
                <div class="bb-assign-roles assign-roles"></div>
            </td>
        </tr>
    <% } %>
 </table>
