<table class="list">
    <thead>
        <tr>
            <%    
                var printedColumns = 0;
                $.each(columns, function(name, col) {
                    if (col.display == false) {
                        return;
                    }
                    
                    printedColumns++;
                    
                    switch(name) {
                        case 'checks':
                            var checkedAttr = selectedAll ? 'checked' : '';
            %>
                            <th class="max-1-icons">
                                <input type="checkbox" class="check_all" <%= checkedAttr %>>
                            </th>
            <%
                            break;
                        case 'info':
            %>
                            <th class="desktop max-1-icons">
                                <i class="fa fa-info-circle normal" data-i18n="[title]Info" title="<%= i18n.t('Info') %>"></i>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="sortable" data-sortby="name">
                                <i class="fa fa-sort sort-icon" data-i18n="Name"><%= i18n.t('Name') %></i>
                            </th>
            <%
                            break;
                        case 'roles':
            %>
                            <th>
                                <%= i18n.t('Role') %>
                            </th>
            <%
                            break;
                        case 'name_roles':
            %>
                            <th class="sortable" data-sortby="name">
                                <i class="fa fa-sort sort-icon" data-i18n="Name"><%= i18n.t('Name') %></i>
                            </th>
            <%
                            break;
                    }
                });
            %>
        </tr>
    </thead>
    <tbody>
        <% 
        if (models.length == 0) {
        %>  
            <tr>
                <td colspan="<%= printedColumns %>">
                    <span class="no-elements" data-i18n="There are not elements">
                        <%= i18n.t('There are not elements') %>
                    </span>
                </td>
            </tr>
        <%
        }
        _.each(models, function(model) { %>
            <tr class="row-<%= model.get('id') %>">
                <% 
                    var info = '';
                    
                    $.each(columns, function(name, col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(name) {
                            case 'checks':
                                var checkedAttr = $.inArray(parseInt(model.get('id')), selectedItems) > -1 ? 'checked' : '';

                %>
                                <td>
                                <%
                                    if ($.inArray(filters.id, Object.keys(model.get('roles'))) == -1) {
                                %>
                                    <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('name') %>" <%= checkedAttr %>>
                                <%
                                    }
                                %>
                                </td>
                <%
                                break;
                            case 'info':
                %>
                                <td class="desktop">
                                    <%
                                    if (model.get('disabled')) {
                                    %>
                                        <i class="fa fa-ban" data-i18n="[title]Disabled" title="<%= i18n.t('Disabled') %>"></i>
                                    <%
                                    }
                                    %>
                                </td>
                <%
                                break;
                            case 'name':
                %>
                                <td class="js-name">
                                    <span class="text"><%= model.get('name') %></span>
                                </td>
                <%
                                break;
                            case 'roles':
                %>
                                <td class="desktop">
                                    <%
                                        $.each(model.get('roles'), function (iRole, role) {
                                    %>
                                            <div>
                                                <%= Wat.C.ifACL('<a href="#/role/' + iRole + '">', 'role.see-details.') %>
                                                    <span class="text"><%= role %></span>
                                                <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
                                            </div>
                                    <%
                                        }); 
                                    %>  
                                </td>
                <%
                                break;
                            case 'name_roles':
                %>
                                <td class="desktop">
                                    <div class="text"><%= model.get('name') %></div>
                                    <div class="second_row">
                                    <span data-i18n="Roles"></span>: 
                                    <%
                                        var firstPrinted = false;
                                        $.each(model.get('roles'), function (iRole, role) {
                                            if (firstPrinted) {
                                                print(' | ');
                                            }
                                            else {
                                                firstPrinted = true;
                                            }
                                    %>
                                            <span>
                                                <%= Wat.C.ifACL('<a href="#/role/' + iRole + '">', 'role.see-details.') %>
                                                    <span class="text"><%= role %></span>
                                                <%= Wat.C.ifACL('</a>', 'role.see-details.') %>
                                            </span>
                                            
                                    <%
                                        }); 
                                    %>  
                                    </div>
                                </td>
                <%
                                break;
                        }
                    });
                %>
            </tr>
        <% }); %>
    </tbody>
</table>