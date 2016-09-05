<fieldset class="template-inherited-list">
    <table class="col-width-100">
        <tbody>
            <%
                var inheritedTemplates = 0;
                $.each(templates, function (iRole, template) {
                    if (!template.inherited) {
                        return;
                    }
                    
                    inheritedTemplates++;
                    %>
                        <tr>
                            <td class="col-width-10">
                                <a class="button2 button-icon js-delete-template-button fa fa-times" data-id="<%= template.id %>" data-name="<%= template.name %>" data-inherit-type="templates" data-i18n="[title]Delete"></a>
                            </td>
                            <td class="left col-width-90">
                                <%= template.name %>
                            </td>
                        </tr>
                    <%
                });
                
                if (inheritedTemplates == 0) {
                    %>
                        <tr>
                            <td><span class="second_row" data-i18n="No elements found"></span></td>
                        </tr>
                    <%
                }
            %>
        </tbody>
    </table>
</fieldset>
<table class="col-width-100">
    <tbody class="js-assign-template-control assign-template-control">
        <tr>
            <td class="col-width-10">
                <a class="button button-icon fa fa-plus-circle js-assign-template-button" data-i18n="[title]Assign"></a>
            </td>
            <td class="col-width-90">
                <select name="template_to_be_assigned">
                    <%
                    $.each(templates, function (iRole, template) {
                        if (template.inherited) {
                            return;
                        }
                    %>
                        <option value="<%= template.id %>">
                            <%= template.name %>
                        </option>
                    <%
                    });
                    %>
                </select>
            </td>
        </tr>
    </tbody>
</table>
