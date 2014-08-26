<table class="list">
    <thead>
        <tr>
            <% 
                var printedColumns = 0;
                _.each(columns, function(col) {
                    if (col.display == false) {
                        return;
                    }
                    
                    printedColumns++;
                    
                    switch(col.name) {
                        case 'checks':
            %>
                            <th class="max-1-icons">
                                <input type="checkbox" class="check_all">
                            </th>
            <%
                            break;
                        case 'info':
            %>
                            <th class="max-2-icons">
                                <i class="fa sort-icon" data-i18n="Info"><%= i18n.t('Info') %></i>
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
                        case 'state':
            %>
                            <th class="desktop sortable" data-sortby="state" data-i18n="State">
                                <i class="fa fa-sort sort-icon" data-i18n="State"><%= i18n.t('State') %></i>
                            </th>
            <%
                            break;
                        case 'address':
            %>
                            <th class="desktop sortable" data-sortby="address">
                                <i class="fa fa-sort sort-icon" data-i18n="IP address"><%= i18n.t('IP address') %></i>
                            </th>
            <%
                            break;
                        case 'vms_connected':
            %>
                            <th class="desktop col-width-15" data-sortby="vms_connected">
                                <i class="fa sort-icon" data-i18n="Running VMs"><%= i18n.t('Running VMs') %></i>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = 'data-i18n="' + col.name + '"';
                            if (col.noTranslatable === true) {
                                translationAttr = '';
                            }
                    
            %>
                            <th class="sortable desktop" data-sortby="<%= col.name %>">
                                <i class="fa sort-icon"><%= col.name %></i>
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
                    _.each(columns, function(col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(col.name) {
                            case 'checks':
                %>
                                <td>
                                    <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>">
                                </td>
                <%
                                break;
                            case 'info':
                %>
                                <td>
                                    <% 
                                    if (model.get('state') == 'stopped') {
                                    %>
                                        <i class="fa fa-pause icon-pause" data-i18n="[title]Stopped" title="<%= i18n.t('Stopped') %>"></i>
                                    <%
                                    }
                                    else {
                                    %>
                                        <i class="fa fa-play icon-play" data-i18n="[title]Running" title="<%= i18n.t('Running') %>"></i>
                                    <%
                                    }
                                    
                                    
                                    if (model.get('blocked')) {
                                    %>
                                        <i class="fa fa-lock" data-i18n="[title]Blocked" title="<%= i18n.t('Blocked') %>"></i>
                                    <%
                                    }
                                    %>
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
                                    <a href="#/node/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <span class="text"><%= model.get('name') %></span>
                                    </a>
                                </td>
                <%
                                break;
                            case 'state':
                %>
                                <td class="desktop">
                                    <% 
                                        switch(model.get('state')) {
                                            case "running":
                                    %>
                                                <span data-i18n>Running</span>
                                    <%
                                                break;
                                            case "stopped":
                                    %>
                                                <span data-i18n>Stopped</span>
                                    <%
                                                break;
                                        }
                                    %>
                                </td>
                <%
                                break;
                            case 'address':
                %>
                                <td class="desktop">
                                    <%= model.get('address') %>
                                </td>
                <%
                                break;
                            case 'vms_connected':
                %>
                                <td class="desktop">
                                    <%= model.get('vms_connected') %>
                                </td>
                <%
                                break;
                            default:
                %>
                                <td class="desktop">
                                    <% 
                                        if (model.get(col.name) !== undefined) {
                                            print(model.get(col.name));
                                        }
                                        else if (model.get('properties') !== undefined && model.get('properties')[col.name] !== undefined) {
                                            print(model.get('properties')[col.name]);
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