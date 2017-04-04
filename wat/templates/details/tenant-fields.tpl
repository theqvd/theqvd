<%
switch (dFieldCode) {
    case 'roles':
            $.each(model.get('roles'), function (iRole, role) {
        %>
            <div data-role-id="<%= iRole %>">
                <%= Wat.C.ifACL('<a href="#/role/' + iRole + '">', 'role.see-details.') %>
                <span class="text"><%= role %></span>
                <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
            </div>
        <%
            }); 

        %>  
        <%
            if (Object.keys(model.get('roles')).length == 0) {
        %>
                <span data-i18n="No elements found"></span>
        <%
            }
        break;
    case 'language':
        %>
        <span data-i18n="<%= WAT_LANGUAGE_TENANT_OPTIONS[model.get('language')] %>"></span>
        <%
        switch (model.get('language')) {
            case  'auto':
        %>
                <div class="second_row" data-i18n="Language will be detected from the browser"></div>
        <%
                break;
        }
        break;
    case 'blocksize':
        print(model.get('block'))
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