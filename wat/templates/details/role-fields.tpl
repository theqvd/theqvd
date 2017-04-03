<%
switch (dFieldCode) {
    case 'roles':
        %>
            <div class="bb-role-inherited-list"></div>
        <%
        break;
    case 'templates':
        %>
            <div class="bb-template-inherited-list template-inherited-list"></div>
        <%
        break;
    default:
        var commonField = _.template(
            Wat.TPL.detailsFieldsCommon, {
                dFieldCode: dFieldCode,
                model: model
            }
        );
        print(commonField);
        break;
}
%>