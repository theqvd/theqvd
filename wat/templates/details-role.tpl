<div class="details-header">
    <span class="fa fa-graduation-cap h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list col-width-100">
    <tr">
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td>
            <i class="fa fa-key"></i><span data-i18n>ACLs</span>
        </td>
        <td>
            <%
            var acls = [];
            $.each(model.get('own_acls').positive, function (iAcl, acl) {
                acls.push(acl);
            }); 
            %>
            
            <%= acls.join('<br>') %>
        </td>
    </tr>
    <tr>
        <td>
            <i class="fa fa-sitemap"></i><span data-i18n>Inherited roles</span>
            <div class="second_row">Roles whose ACLs will be inherited</div>
        </td>
        <td>
            <%
                var roles = [];
                $.each(model.get('inherited_roles'), function (iRole, role) {
                    roles.push(role.name);
                }); 
            %>
                    
            <%= roles.join('<br>') %>
        </td>
    </tr>
</table>