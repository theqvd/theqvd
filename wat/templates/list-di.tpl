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
                            <th class="max-4-icons">
                                <i class="fa sort-icon" data-i18n="Info"><%= i18n.t('Info') %></i>
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
                        case 'disk_image':
            %>
                            <th class="sortable" data-sortby="disk_image">
                                <i class="fa fa-sort sort-icon" data-i18n="Disk image"><%= i18n.t('Disk image') %></i>
                            </th>
            <%
                            break;
                        case 'version':
            %>
                            <th class="desktop sortable col-width-14" data-sortby="version">
                                <i class="fa fa-sort sort-icon" data-i18n="Version"><%= i18n.t('Version') %></i>
                            </th>
            <%
                            break;
                        case 'osf':
            %>
                            <th class="desktop sortable" data-sortby="osf_name">
                                <i class="fa fa-sort sort-icon" data-i18n="OS Flavour"><%= i18n.t('OS Flavour') %></i>
                            </th>
            <%
                            break;
                        case 'default':
            %>
                            <th class="desktop col-width-12">
                                <i class="fa sort-icon" data-i18n="Default"><%= i18n.t('Default') %></i>
                            </th>
            <%
                            break;
                        case 'head':
            %>
                            <th class="desktop col-width-12" data-sortby="head">
                                <i class="fa sort-icon" data-i18n="Head"><%= i18n.t('Head') %></i>
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
                            case 'info':
                %>
                                <td>
                                    <%
                                    if (model.get('tags')) {
                                    %>
                                        <i class="fa fa-tags" title="&raquo; <%= model.get('tags').replace(/,/g,'<br /><br />&raquo; ') %>"></i>
                                    <%
                                    }
                                    
                                    if (model.get('head')) {
                                    %>
                                        <i class="fa fa-flag-o" data-i18n="[title]Head" title="<%= i18n.t('Head') %>"></i>
                                    <%
                                    }
                                    
                                    if (model.get('default')) {
                                    %>
                                        <i class="fa fa-home" data-i18n="[title]Default" title="<%= i18n.t('Default') %>"></i>
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
                            case 'disk_image':
                %>
                                <td class="not-break">
                                    <a href="#/di/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('disk_image') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'version':
                %>
                                <td class="desktop">
                                    <%= model.get('version') %>
                                </td>
                <%
                                break;
                            case 'osf':
                %>
                                <td class="desktop">
                                    <a href="#/osf/<%= model.get('osf_id') %>">
                                        <%= model.get('osf_name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'default':
                %>
                                <td class="desktop center">
                                    <input type="radio" data-di_id="<%= model.get('id') %>" name="di_default" <%= model.get('default') ? 'checked': '' %> value="0">
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