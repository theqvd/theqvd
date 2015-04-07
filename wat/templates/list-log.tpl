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
                            <th class="<%= sortAttr %> desktop" data-sortby="qvd_object">
                                <span data-i18n="Object type"><%= i18n.t('Object type') %></span>
                            </th>
            <%
                            break;
                        case 'object_name':
            %>
                            <th class="<%= sortAttr %>" data-sortby="object_name">
                                <span data-i18n="Object"><%= i18n.t('Object') %></span>
                            </th>
            <%
                            break;
                        case 'administrator':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="admin_name">
                                <span data-i18n="Administrator"><%= i18n.t('Administrator') %></span>
                            </th>
            <%
                            break;
                        case 'datetime':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="time">
                                <span data-i18n="Passed time"><%= i18n.t('Passed time') %></span>
                            </th>
            <%
                            break;
                        case 'source':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="time">
                                <span data-i18n="Source"><%= i18n.t('Source') %></span>
                            </th>
            <%
                            break;
                        case 'address':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="ip">
                                <span data-i18n="Address"><%= i18n.t('Address') %></span>
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
                                    <%= Wat.C.ifACL('<a href="#/log/' + model.get('id') + '" data-i18n="[title]Click for details">', 'log.see-details.') %>
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
                                        <%
                                        if (model.get('status') != STATUS_SUCCESS) {
                                        %>
                                            <i class="fa fa-warning" data-i18n="[title]<%= ALL_STATUS[model.get('status')] %>" title="<%= $.i18n.t(ALL_STATUS[model.get('status')]) %>"></i>
                                        <%
                                        }
                                        %>

                                        <span class="text" data-i18n="<%= LOG_TYPE_ACTIONS[model.get('type_of_action')] %>"><%= i18n.t(LOG_TYPE_ACTIONS[model.get('type_of_action')]) %></span>
                                </td>
                <%
                                break;
                            case 'qvd_object':
                %>
                                <td class="">
                                        <span class="text" data-i18n="<%= LOG_TYPE_OBJECTS[model.get('qvd_object')] %>"><%= i18n.t(LOG_TYPE_OBJECTS[model.get('type_of_action')]) %></span>
                                </td>
                <%
                                break;
                            case 'object_name':
                %>
                                <td class="">
                                    <i class="<%= LOG_TYPE_OBJECTS_ICONS[model.get('qvd_object')] %>" data-i18n="[title]<%= LOG_TYPE_OBJECTS[model.get('qvd_object')] %>" title="<%=  i18n.t(LOG_TYPE_OBJECTS[model.get('qvd_object')]) %>"></i>
                                    <% if (model.get('object_name')) { %>
                                        <%= 
                                        model.get('object_deleted') ? '' : Wat.C.ifACL('<a href="#/' + model.get('qvd_object') + '/' + model.get('object_id') + '" data-i18n="[title]Click for details" title="' + i18n.t('Click for details') + '">', 'log.see-details.') 
                                        %>
                                            <span class="text"><%= model.get('object_name') %></span>
                                        <%= 
                                        model.get('object_deleted') ? '' : Wat.C.ifACL('</a>', 'log.see-details.') 
                                        %>
                                    <% 
                                    } 
                                    else { 
                                        var objectName = '';

                                        switch (model.get('qvd_object')) {
                                            case 'login':
                                                %>
                                                <%= 
                                                model.get('admin_deleted') ? '' : Wat.C.ifACL('<a href="#/administrator/' + model.get('admin_id') + '" data-i18n="[title]Click for details" title="' + i18n.t('Click for details') + '">', 'administrator.see-details.') 
                                                %>
                                                <span class="text"><%= model.get('admin_name') %></span>
                                                <%= 
                                                model.get('admin_deleted') ? '' : Wat.C.ifACL('</a>', 'administrator.see-details.') 
                                                %>
                                                <%
                                                break;
                                            case 'config':
                                                objectName = JSON.parse(model.get('arguments')).key;
                                                %>
                                                <span class="text"><%= objectName %></span>
                                                <%
                                                break;
                                            case 'admin_view':
                                                %>
                                                <span class="text" data-i18n="<%= model.get('viewTypeName') %>"><%= model.get('viewTypeName') %></span>: <span class="text" data-i18n="<%= model.get('fieldName') %>"><%= model.get('fieldName') %></span> (<span class="text" data-i18n="<%= model.get('qvdObjectName') %>"><%= model.get('qvdObjectName') %></span>)
                                                <%
                                                break;
                                        }
                                    } 
                                    %>
                                </td>
                <%
                                break;
                            case 'administrator':
                %>
                                <td class="desktop">
                                    <%
                                        var showAdminLink = (Wat.C.isSuperadmin() || !model.get('superadmin')) && !model.get('admin_deleted'); 
                                    %>
                                    <%= !showAdminLink ? '' : Wat.C.ifACL('<a href="#/administrator/' + model.get('admin_id') + '" data-i18n="[title]Click for details" title="' + i18n.t('Click for details') + '">', 'administrator.see-details.') %>
                                        <span class="text"><%= model.get('admin_name') %></span>
                                    <%= !showAdminLink ? '' : Wat.C.ifACL('</a>', 'administrator.see-details.') %>
                                </td>
                <%
                                break;
                            case 'datetime':
                %>
                                <td class="desktop">
                                        <span class="text"><%= model.get('antiquityHTML') %></span>
                                </td>
                <%
                                break;
                            case 'source':
                %>
                                <td class="desktop">
                                        <span class="text"><%= model.get('source') %></span>
                                </td>
                <%
                                break;
                            case 'address':
                %>
                                <td class="desktop">
                                        <span class="text"><%= model.get('ip') %></span>
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