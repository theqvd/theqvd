<table>
    <tr>
        <td data-i18n>Default</td>
        <td>
            <%
            if (model.get('default')) {
            %>
                <div class="second_row" data-i18n>
                    To change this value, set another Disk image of the same OSF as default
                </div>
            <%
            }
            else {
            %>
                <input type="checkbox" name="default" value="1">
            <%
            }
            %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Tags</td>
        <td>
            <input type="text" class="" name="tags" value="<%= model.get('tags') %>">
        </td>
    </tr>
 </table>