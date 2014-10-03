<div class="details-header">
    <span class="fa fa-graduation-cap h1" data-i18n><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list col-width-100">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-calculator"></i><span data-i18n>Total effective ACLs</span></td>
        <td>
            <span class="js-total-acls">0</span>
        </td>
    </tr>
</table>

<div class="details-header">
    <span class="fa fa-key h2" data-i18n>ACLs management</span>
</div>
<div class="details-header center">
    <span class="fa fa-sitemap h2" data-i18n>Inherit roles</span>
</div>

<table class="list details-list acls-management col-width-100">  
    <tr>
        <th colspan="2">
            <span data-i18n>Roles whose ACLs will be inherited</span>
        </th>
    </tr>   
    <tr>
        <td colspan="2">
            <table class="roles-inherit-table">
                <tr>
                    <td>
                        <span data-i18n>Select a role to be inerithed</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <select name="role"></select>
                        <a class="button add-role-button js-add-role-button fa fa-sitemap" href="javascript:" data-i18n>Inherit</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span data-i18n>Inherited roles</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <%
                            $.each(model.get('roles'), function (iRole, role) {
                        %>
                                <div class="inherited-role-wrapper">
                                    <table class="list inherited-role-table">
                                        <tr>
                                            <th>
                                                <a href="#/setup/role/<%= iRole %>" data-i18n="[title]Click for details">
                                                    <span class="text"><%= role.name %></span>
                                                </a>
                                            </th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="role-acls-wrapper">
                                            <%
                                                if(role.acls.length > 0) {
                                            %>
                                                    <table class="list inherited-role-table">
                                            <%
                                                    $.each(role.acls, function (iACL, acl) {
                                            %>
                                                        <tr>
                                                            <td>
                                                                <span class="text"><%= acl %></span>
                                                            </td>
                                                        </tr>
                                            <%
                                                    });
                                            %>
                                                    </table>
                                            <%
                                                }
                                                else {
                                            %>
                                                    <span class="text" data-i18n>Empty</span>
                                            <%
                                                }
                                            %>  
                                                </div>                                    
                                                <a class="button2 button-under-floating-box delete-role-button js-delete-role-button fa fa-trash-o" href="javascript:" data-id="<%= iRole %>" data-i18n>Delete</a>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                    
                        <%
                            }); 
                        %>  
                    </td>
                </tr>
            </table>
        </tr>
    <tr>
        <td><i class="fa fa-calculator"></i><span data-i18n>Inherited ACLs</span></td>
        <td>
            <span class="js-inherited-acls roles-acls-calculated">0</span>
        </td>
    </tr>
</table>

<div class="details-header center">
    <span class="fa fa-filter h2" data-i18n>Filter ACLs</span>
</div>

<table class="list details-list acls-management col-width-100">
    <tr>
        <th colspan="2">
            <span data-i18n>ACLs that will be ignored from inherit roles</span>
        </th>
    </tr>
    <tr>
        <td>
            <select multiple>
                <option></option>
                <option></option>
                <option></option>
                <option></option>
            </select>
        </td>
        <td>
            <%
                $.each(model.get('acls').negative, function (iACL, acl) {
            %>
                    <div>
                        <i class="delete-role-button js-delete-role-button fa fa-trash-o" data-id="<%= iACL %>" data-name="<%= acl %>"></i>
                        <span class="text"><%= acl %></span>
                    </div>
            <%
                }); 
            %>  
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-calculator"></i><span data-i18n>Filtered ACLs</span></td>
        <td>
            <span class="js-filtered-acls roles-acls-calculated">0</span>
        </td>
    </tr>
</table>

<div class="details-header center">
    <span class="fa fa-plus-circle h2" data-i18n>Add ACLs</span>
</div>

<table class="list details-list acls-management col-width-100">
    <tr>
        <th colspan="2">
            <span data-i18n>ACLs added to the role besides the inheritance</span>
        </th>
    </tr>
    <tr>
        <td>
            <select multiple>
                <option></option>
                <option></option>
                <option></option>
                <option></option>
            </select>
        </td>
        <td>
            <%
                $.each(model.get('acls').positive, function (iACL, acl) {
            %>
                    <div>
                        <i class="delete-role-button js-delete-role-button fa fa-trash-o" data-id="<%= iACL %>" data-name="<%= acl %>"></i>
                        <span class="text"><%= acl %></span>
                    </div>
            <%
                }); 
            %>  
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-calculator"></i><span data-i18n>Added ACLs</span></td>
        <td>
            <span class="js-added-acls roles-acls-calculated">0</span>
        </td>
    </tr>
</table>