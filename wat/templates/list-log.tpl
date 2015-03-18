<table class="list">
    <thead>
        <tr>
            <%                
                var printedColumns = 0;
                $.each(columns, function(name, col) {
                    if (col.display == false) {
                        return;
                    }
                    
                    var sortAttr = '';
                    if (col.sortable == true) {
                        sortAttr = 'sortable';
                    }
                    
                    printedColumns++;

                    switch(name) {
                        case 'see_details':
            %>
                            <th class="<%= sortAttr %> center">
                                <i class="fa fa-search"></i>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="id">
                                <span data-i18n="Id"><%= i18n.t('Id') %></span>
                            </th>
            <%
                            break;
                        case 'action':
            %>
                            <th class="<%= sortAttr %>" data-sortby="type_of_action">
                                <span data-i18n="Action"><%= i18n.t('Action') %></span>
                            </th>
            <%
                            break;
                        case 'qvd_object':
            %>
                            <th class="<%= sortAttr %>" data-sortby="qvd_object">
                                <span data-i18n="Object"><%= i18n.t('Object') %></span>
                            </th>
            <%
                            break;
                        case 'object_name':
            %>
                            <th class="<%= sortAttr %>" data-sortby="object_name">
                                <span data-i18n="Name"><%= i18n.t('Name') %></span>
                            </th>
            <%
                            break;
                        case 'administrator':
            %>
                            <th class="<%= sortAttr %>" data-sortby="admin_name">
                                <span data-i18n="Administrator"><%= i18n.t('Administrator') %></span>
                            </th>
            <%
                            break;
                        case 'datetime':
            %>
                            <th class="<%= sortAttr %>" data-sortby="time">
                                <span data-i18n="Date time"><%= i18n.t('Date time') %></span>
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
                    
                    if (model.get('blocked')) {
                        info += '<i class="fa fa-lock" data-i18n="[title]Blocked" title="' + i18n.t('Blocked') + '"></i>';
                    }
                    $.each(columns, function(name, col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(name) {
                            case 'see_details':
                %>
                                <td class="center">
                                    <%= Wat.C.ifACL('<a href="#/log/' + model.get('object_id') + '" data-i18n="[title]Click for details">', 'log.see-details.') %>
                                    <%= Wat.C.ifACL('<i class="fa fa-search"></i>', 'log.see-details.') %>
                                    <%= Wat.C.ifACL('</a>', 'log.see-details.') %>
                                </td>
                <%
                                break;
                            case 'id':
                %>
                                <td class="desktop">
                                    <%= model.get('id') %>
                                </td>
                <%
                                break;
                            case 'action':
                %>
                                <td class="">
                                        <span class="text"><%= model.get('type_of_action') %></span>
                                </td>
                <%
                                break;
                            case 'qvd_object':
                %>
                                <td class="">
                                        <span class="text"><%= model.get('qvd_object') %></span>
                                </td>
                <%
                                break;
                            case 'object_name':
                %>
                                <td class="">
                                    <% if (model.get('object_name')) { %>
                                        <%= Wat.C.ifACL('<a href="#/log/' + model.get('object_id') + '" data-i18n="[title]Click for details">', 'log.see-details.') %>
                                            <span class="text"><%= model.get('object_name') %></span>
                                        <%= Wat.C.ifACL('</a>', 'log.see-details.') %>
                                    <% 
                                    } 
                                    else { 
                                    %>
                                        <span class="text">-</span>
                                    <% 
                                    } 
                                    %>
                                </td>
                <%
                                break;
                            case 'administrator':
                %>
                                <td class="desktop">
                                    <%= Wat.C.ifACL('<a href="#/admin/' + model.get('admin_id') + '" data-i18n="[title]Click for details">', 'administrator.see-details.') %>
                                        <span class="text"><%= model.get('admin_name') %></span>
                                    <%= Wat.C.ifACL('</a>', 'administrator.see-details.') %>
                                </td>
                <%
                                break;
                            case 'datetime':
                %>
                                <td class="desktop">
                                        <span class="text"><%= model.get('time') %></span>
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