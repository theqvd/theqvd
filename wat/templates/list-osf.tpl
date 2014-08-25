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
                        case 'id':
            %>
                            <th class="sortable desktop col-width-10" data-sortby="id">
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
                        case 'overlay':
            %>
                            <th class="desktop sortable col-width-10" data-sortby="overlay">
                                <i class="fa fa-sort sort-icon" data-i18n="Overlay"><%= i18n.t('Overlay') %></i>
                            </th>
            <%
                            break;
                        case 'memory':
            %>
                            <th class="desktop sortable col-width-10" data-sortby="memory">
                                <i class="fa fa-sort sort-icon" data-i18n="Memory"><%= i18n.t('Memory') %></i>
                            </th>
            <%
                            break;
                        case 'user_storage':
            %>
                            <th class="desktop sortable col-width-13" data-sortby="user_storage">
                                <i class="fa fa-sort sort-icon" data-i18n="User storage"><%= i18n.t('User storage') %></i>
                            </th>
            <%
                            break;
                        case 'dis':
            %>
                            <th class="desktop col-width-8">
                                <i class="fa sort-icon" data-i18n="DIs"><%= i18n.t('DIs') %></i>
                            </th>
            <%
                            break;
                        case 'vms':
            %>
                            <th class="desktop col-width-8">
                                <i class="fa sort-icon" data-i18n="VMs"><%= i18n.t('VMs') %></i>
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
            <tr>
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
                            case 'id':
                %>
                                <td class="desktop">
                                    <%= model.get('id') %>
                                </td>
                <%
                                break;
                            case 'name':
                %>
                                <td>
                                    <a href="#/osf/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'overlay':
                %>
                                <td class="desktop">
                                    <%= model.get('overlay') %>
                                </td>
                <%
                                break;
                            case 'memory':
                %>
                                <td class="desktop">
                                    <%= model.get('memory') %> MB
                                </td>
                <%
                                break;
                            case 'user_storage':
                %>
                                <td class="desktop">
                                    <%
                                    if (!model.get('user_storage')) {
                                    %>
                                        <span data-i18n="No">
                                            <%= i18n.t('No') %>
                                        </span>
                                    <%
                                    }
                                    else {
                                        print(model.get('user_storage')  + " MB");
                                    }
                                    %>
                                </td>
                <%
                                break;
                            case 'dis':
                %>
                                <td class="desktop">
                                    <%= model.get('dis') %>
                                </td>
                <%
                                break;
                            case 'vms':
                %>
                                <td class="desktop">
                                    <%= model.get('vms') %>
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