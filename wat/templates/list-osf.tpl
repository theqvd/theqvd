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
                        case 'checks':
                            var checkedAttr = selectedAll ? 'checked' : '';
            %>
                            <th class="<%= sortAttr %> max-1-icons">
                                <input type="checkbox" class="check_all" <%= checkedAttr %>>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="<%= sortAttr %> desktop col-width-10" data-sortby="id">
                                <span data-i18n="Id"><%= i18n.t('Id') %></span>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="<%= sortAttr %> col-width-100" data-sortby="name">
                                <span data-i18n="Name"><%= i18n.t('Name') %></span>
                            </th>
            <%
                            break;
                        case 'overlay':
            %>
                            <th class="<%= sortAttr %> desktop col-width-10" data-sortby="overlay">
                                <span data-i18n="Overlay"><%= i18n.t('Overlay') %></span>
                            </th>
            <%
                            break;
                        case 'memory':
            %>
                            <th class="<%= sortAttr %> desktop col-width-10" data-sortby="memory">
                                <span data-i18n="Memory"><%= i18n.t('Memory') %></span>
                            </th>
            <%
                            break;
                        case 'user_storage':
            %>
                            <th class="<%= sortAttr %> desktop col-width-13" data-sortby="user_storage">
                                <span data-i18n="User storage"><%= i18n.t('User storage') %></span>
                            </th>
            <%
                            break;
                        case 'dis':
            %>
                            <th class="<%= sortAttr %> desktop">
                                <span data-i18n="DIs"><%= i18n.t('DIs') %></span>
                            </th>
            <%
                            break;
                        case 'vms':
            %>
                            <th class="<%= sortAttr %> desktop">
                                <span data-i18n="VMs"><%= i18n.t('VMs') %></span>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="tenant_name">
                                <span data-i18n="Tenant"><%= i18n.t('Tenant') %></span>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = '';
                            var colText = col.text;
                            
                            if (col.noTranslatable !== true) {
                                translationAttr = 'data-i18n="' + col.text + '"';
                                colText = $.i18n.t(col.text);
                            }
                    
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="<%= name %>">
                                <span <%= translationAttr %>><%= colText %></span>
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
                    $.each(columns, function(name, col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(name) {
                            case 'checks':
                                var checkedAttr = $.inArray(parseInt(model.get('id')), selectedItems) > -1 ? 'checked' : '';

                %>
                                <td>
                                    <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>" <%= checkedAttr %>>
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
                                    <%= Wat.C.ifACL('<a href="#/osf/' + model.get('id') + '" data-i18n="[title]Click for details">', 'osf.see-details.') %>
                                    <%= Wat.C.ifACL('<i class="fa fa-search"></i>', 'osf.see-details.') %>
                                        <span class="text"><%= model.get('name') %></span>
                                    <%= Wat.C.ifACL('</a>', 'osf.see-details.') %>
                                </td>
                <%
                                break;
                            case 'overlay':
                %>
                                <td class="desktop center">
                                    <%= model.get('overlay') ? '<span class="fa fa-check"></span>' : '<span class="fa fa-remove"></span>' %>
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
                                    <% if (model.get('number_of_dis') > 0) { %>
                                    <%= Wat.C.ifACL('<a href="#/dis/osf/' + model.get('id') + '">', 'di.see-main.') %>
                                        <span data-wsupdate="number_of_dis" data-id="<%= model.get('id') %>"><%= model.get('number_of_dis') %></span>
                                    <%= Wat.C.ifACL('</a>', 'di.see-main.') %>
                                    <% } else {
                                    %>
                                        <span data-wsupdate="number_of_dis" data-id="<%= model.get('id') %>"><%= model.get('number_of_dis') %></span>
                                    <% } %>
                                </td>
                <%
                                break;
                            case 'vms':
                %>
                                <td class="desktop">
                                    <% if (model.get('number_of_vms') > 0) { %>
                                    <%= Wat.C.ifACL('<a href="#/vms/osf/' + model.get('id') + '">', 'vm.see-main.') %>
                                        <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
                                    <%= Wat.C.ifACL('</a>', 'vm.see-main.') %>
                                    <% } else {
                                    %>
                                        <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
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
                                <td class="desktop" data-wsupdate="<%= name %>" data-id="<%= model.get('id') %>">
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