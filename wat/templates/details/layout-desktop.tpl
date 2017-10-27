<div class="menu secondary-menu setup-side">
    <ul>
        <%
        $.each(detailsFields, function (dCategoryCode, dCategory) {
            if (dCategory.onlyMobile) {
                return;
            }
            if (dCategory.onlyWithConditions && !Wat.U.complyConditions(model, dCategory.onlyWithConditions)) {
                return;
            }
        %>
            <li class="lateral-menu-option js-details-option <%= dCategory.default ? 'lateral-menu-option--selected' : '' %>" data-details-target="<%= dCategoryCode %>">
                <span data-i18n=""><%= dCategory.text %></span>
            </li>
        <%
        });
        %>
    </ul>
</div>

<%
$.each(detailsFields, function (dCategoryCode, dCategory) {
    if (dCategory.onlyMobile) {
        return;
    }
    if (dCategory.onlyWithConditions && !Wat.U.complyConditions(model, dCategory.onlyWithConditions)) {
        return;
    }
    if (dCategory.bb) {
        %>
        <table class="col-width-83 <%= dCategory.default ? '' : 'hidden' %>" data-details-block="<%= dCategoryCode %>">
            <tr>
                <td>
                    <span class="<%= dCategory.bb %>"></span>
                </td>
            </tr>
        </table>
        <%
        return;
    }
    %>
        <table class="details details-list col-width-83 <%= dCategory.default ? '' : 'hidden' %>" data-details-block="<%= dCategoryCode %>">
            <%
            $.each(dCategory.fieldList, function (dFieldCode, dField) {
                if (dField.onlyIfNotEmpty && !model.get(dField.onlyIfNotEmpty)) {
                    return;
                }
                if (dField.onlyMultitenant && !Wat.C.isMultitenant()) {
                    return;
                }
                %>
                <tr data-field-code="<%= dFieldCode %>">
                    <td><i class="<%= dField.icon %>"></i><span data-i18n="<%= dField.text %>"></span></td>
                    <td>
                    <%= 
                        _.template(
                            Wat.TPL.detailsFields, {
                                dFieldCode: dFieldCode,
                                model: model
                            }
                        )
                    %>
                    </td>
                </tr>
                <%
            });
            
            // Properties will be located at general section
            if (dCategoryCode == 'general') {
                %>
                <tbody class="bb-properties"></tbody>
                <%
            }
            %>
        </table>
    <%
});
%>