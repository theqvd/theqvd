<div class="details-header">
    <span class="<%= CLASS_ICON_LOG %> h1"><%= model.get('time').replace('T', ' ') + ' - ' + i18n.t(LOG_TYPE_ACTIONS[model.get('type_of_action')]) + ' - ' + i18n.t(LOG_TYPE_OBJECTS[model.get('qvd_object')]) %></span>
</div>


    <table class="details details-list col-width-100">
    <% 
    if (Wat.C.checkACL('log.see-details.')) { 
    %>
        <tr>
            <td><i class="fa fa-male"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>  
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Administrator"></span></td>
            <td>
                <%
                    var showAdminLink = (Wat.C.isSuperadmin() || !model.get('superadmin')) && !model.get('admin_deleted'); 
                %>
                <%= 
                !showAdminLink ? '' : Wat.C.ifACL('<a href="#/administrator/' + model.get('admin_id') + '" data-i18n="[title]Click for details" title="' + i18n.t('Click for details') + '">', 'administrator.see-details.') 
                %>
                    <span class="text"><%= model.get('admin_name') %></span>
                <%= 
                !showAdminLink ? '' : Wat.C.ifACL('</a>', 'administrator.see-details.') 
                %>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-bolt"></i><span data-i18n="Action type"></span></td>
            <td>
                <span><%= i18n.t(LOG_TYPE_ACTIONS[model.get('type_of_action')]) %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-bolt"></i><span data-i18n="Action"></span></td>
            <td>
                <span><%= model.get('action') %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-stethoscope"></i><span data-i18n="Response"></span></td>
            <td>
                <%= $.i18n.t(ALL_STATUS[model.get('status')]) %>
            </td>
        </tr>  
        <% if (model.get('action') != 'login') { %>
        <tr>
            <td><i class="fa fa-cube"></i><span data-i18n="Object type"></span></td>
            <td>
                <i class="<%= LOG_TYPE_OBJECTS_ICONS[model.get('qvd_object')] %>"></i><span data-i18n="<%= LOG_TYPE_OBJECTS[model.get('qvd_object')] %>"><%=  i18n.t(LOG_TYPE_OBJECTS[model.get('qvd_object')]) %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-cube"></i><span data-i18n="Object name"></span></td>
            <td>
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
        </tr>
        <% } %>
        <tr>
            <td><i class="fa fa-clock-o"></i><span data-i18n="Date time"></span></td>
            <td>
                <span><%= model.get('time').replace('T', ' ') %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-clock-o"></i><span data-i18n="Elapsed time"></span></td>
            <td>
                <span><%= model.get('antiquityHTML') %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-arrow-circle-o-right"></i><span data-i18n="Source"></span></td>
            <td>
                <span><%= model.get('source') %></span>
            </td>
        </tr>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
            <td>
                <span><%= model.get('ip') %></span>
            </td>
        </tr>
        <% if (Wat.C.isSuperadmin() && model.attributes.tenant_id != undefined) { %>
        <tr>
            <td><i class="<%= CLASS_ICON_TENANTS %>"></i><span data-i18n="Tenant"></span></td>
            <td>
                <span><%= model.get('tenant_name') %></span>
            </td>
        </tr>
        <% } %>
        <% 
        var argumentsObj = JSON.parse(model.get('arguments'));
        if (!$.isEmptyObject(argumentsObj)) {
        %>
            <tr>
                <td colspan=2 data-i18n="Call arguments"><%= i18n.t('Call arguments') %> </td>
            </td>
        <%
        }
        $.each(argumentsObj, function (argName, argValue) { 
        %>
            <tr>
                <td><i class="fa fa-asterisk"></i><span></span><%= argName %></td>
                <td>
                    <% if (typeof argValue == 'object') { %>
                    <span><%= JSON.stringify(argValue) %></span>
                    <% } else { %>
                    <span><%= argValue %></span>
                    <% } %>
                </td>
            </tr>
        <% 
        }); 
        %>
    <% 
    } 
    %>
    </table>
