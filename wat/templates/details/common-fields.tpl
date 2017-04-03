<%
switch (dFieldCode) {
    case 'tenant':
            if (model.get('tenant_id') == "-1") {
                %>
                <span data-i18n="None (Shared)"></span>
                <%
            }
            else {
            %>
                <%= Wat.C.ifACL('<a href="#/tenant/' + model.get('tenant_id') + '">', 'tenant.see-details.') %>
                <%= model.get('tenant_name') %>
                <%= Wat.C.ifACL('</a>', 'tenant.see-details.') %>
            <%
            }
        break;
    case 'id':
        print(model.get('id'));
        break;
    case 'description':
        if (model.get('description')) { 
            print(model.get('description').replace(/\n/g, '<br>'));
        }
        else {
        %>
            <span class="second_row">-</span>
        <%
        }
        break;
    case 'block':
        if (model.get('blocked')) {
        %>
            <span data-i18n="Blocked"></span>
        <%
        }
        else {
        %>
            <span data-i18n="Unblocked"></span>
        <%
        }
        break;
    case 'creation_admin':
        print(model.get('creation_admin_name'))
        break;
    case 'creation_date':
        print(model.get('creation_date'))
        break;
}
%>