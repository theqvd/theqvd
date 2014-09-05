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
            %>
                            <th class="max-1-icons">
                                <input type="checkbox" class="check_all">
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
                        case 'id':
            %>
                            <th class="sortable desktop col-width-8" data-sortby="id">
                                <i class="fa fa-sort sort-icon" data-i18n="Id"><%= i18n.t('Id') %></i>
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
                        case 'connected_vms':
            %>
                            <th class="desktop">
                                <i data-i18n="Connected VMs"><%= i18n.t('Connected VMs') %></i>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="sortable desktop" data-sortby="tenant">
                                <i class="fa fa-sort sort-icon" data-i18n="Tenant"><%= i18n.t('Tenant') %></i>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = 'data-i18n="' + name + '"';
                            if (col.noTranslatable === true) {
                                translationAttr = '';
                            }
                    
            %>
                            <th class="sortable desktop" data-sortby="<%= name %>">
                                <i class="fa sort-icon"><%= name %></i>
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
                            case 'checks':
                %>
                                <td>
                                    <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>">
                                </td>
                <%
                                break;
                            case 'info':
                %>
                                <td class="desktop">
                                    <%= info %>
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
                            case 'name':
                %>
                                <td class="js-name">
                                    <a href="#/user/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <span class="text"><%= model.get('name') %></span>
                                    </a>
                                    <div class="mobile info-in-name-cell">
                                        <%= info %>
                                    </div>
                                </td>
                <%
                                break;
                            case 'connected_vms':
                %>
                                <td class="desktop">
                                    <% if (model.get('vms') > 0) { %>
                                    <a href="#/vms/user/<%= model.get('id') %>">
                                        <%= model.get('startedVMs') %>
                                        /
                                        <%= model.get('vms') %>
                                    </a>
                                    <% } else {%>
                                        <%= model.get('startedVMs') %>
                                        /
                                        <%= model.get('vms') %>
                                    <% } %>
                                </td>
                <%
                                break;
                            case 'tenant':
                %>
                                <td class="desktop">
                                    <%= model.get('tenant_name') %>
                                </td>
                <%
                                break;
                            default:
                %>
                                <td class="desktop">
                                    <% 
                                        if (model.get(name) !== undefined) {
                                            print(model.get(name));
                                        }
                                        else if (model.get('properties') !== undefined && model.get('properties')[name] !== undefined) {
                                            print(model.get('properties')[name]);
                                        }
                                    
                                    %>
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