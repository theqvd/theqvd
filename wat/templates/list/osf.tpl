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
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> max-1-icons cell-check">
                                <input type="checkbox" class="check_all" <%= checkedAttr %>>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop col-width-10" data-sortby="id">
                                <span data-i18n="Id"><%= i18n.t('Id') %></span>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> col-width-100" data-sortby="name">
                                <span data-i18n="Name"><%= i18n.t('Name') %></span>
                            </th>
            <%
                            break;
                        case 'overlay':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop col-width-10" data-sortby="overlay">
                                <span data-i18n="Overlay"><%= i18n.t('Overlay') %></span>
                            </th>
            <%
                            break;
                        case 'memory':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop col-width-10" data-sortby="memory">
                                <span data-i18n="Memory"><%= i18n.t('Memory') %></span>
                            </th>
            <%
                            break;
                        case 'user_storage':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop col-width-13" data-sortby="user_storage">
                                <span data-i18n="User storage"><%= i18n.t('User storage') %></span>
                            </th>
            <%
                            break;
                        case 'dis':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop">
                                <span data-i18n="DIs"><%= i18n.t('DIs') %></span>
                            </th>
            <%
                            break;
                        case 'vms':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop">
                                <span data-i18n="VMs"><%= i18n.t('VMs') %></span>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop" data-sortby="tenant_name">
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
                            <th data-fieldname="<%= name %>" class="<%= sortAttr %> desktop" data-sortby="<%= name %>">
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
                    <span class="no-elements" data-i18n="There are no elements">
                        <%= i18n.t('There are no elements') %>
                    </span>
                </td>
            </tr>
        <%
        }
        _.each(models, function(model) { %>
            <tr class="row-<%= model.get('id') %>" data-id="<%= model.get('id') %>" data-name="<%= model.get('name') %>">
                <% 
                    $.each(columns, function(name, col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(name) {
                            case 'checks':
                                var checkedAttr = $.inArray(parseInt(model.get('id')), selectedItems) > -1 ? 'checked' : '';

                %>
                                <td class="cell-check">
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
                                var cellClass = 'js-name';
                                var cellAttrs = '';
                                if (Wat.C.checkACL('osf.see-details.')) {
                                    cellClass += ' cell-link';
                                    cellAttrs += 'data-i18n="[title]Click for details"';
                                }
                                
                                cellAttrs += ' class="' + cellClass + '"';
                                
                %>
                                <td <%= cellAttrs %>>
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
                                    <%= Wat.C.ifACL('<a href="#/dis/' + Wat.U.transformFiltersToSearchHash({osf_id: model.get('id')}) + '">', 'di.see-main.') %>
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
                                    <%= Wat.C.ifACL('<a href="#/vms/' + Wat.U.transformFiltersToSearchHash({osf_id: model.get('id')}) + '">', 'vm.see-main.') %>
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
                                        if (!col.property) {
                                            print(model.get(name));
                                        }
                                        else if (model.get('properties') && model.get('properties')[col.property]) {
                                            print(model.get('properties')[col.property].value);
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