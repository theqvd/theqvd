<table class="details details-list col-width-100">
<%
$.each(detailsFields, function (dCategoryCode, dCategory) {
    if (dCategory.onlyWithConditions && !Wat.U.complyConditions(model, dCategory.onlyWithConditions)) {
        return;
    }
    %>
    <tr>
        <th colspan=2>
            <span data-i18n=""><%= dCategory.text %></span>
        </th>
    </tr>
    <%
    if (dCategory.bb) {
        %>
        <tr>
            <td colspan=2>
                <table class="col-width-100">
                    <tr>
                        <td>
                            <span class="<%= dCategory.bb %>"></span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <%
        return;
    }

    $.each(dCategory.fieldList, function (dFieldCode, dField) {
        if (dCategory.onlyWithConditions && !Wat.U.complyConditions(model, dCategory.onlyWithConditions)) {
            return;
        }
        if (dField.onlyIfNotEmpty && !model.get(dField.onlyIfNotEmpty)) {
            return;
        }
        if (dField.onlyMultitenant && !Wat.C.isMultitenant()) {
            return;
        }
        %>
        <tr>
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
});
%>
</table>
