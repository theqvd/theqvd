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
                            <th class="desktop max-4-icons">
                                <i class="fa fa-info-circle normal" data-i18n="[title]Info" title="<%= i18n.t('Info') %>"></i>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="sortable desktop col-width-10" data-sortby="id">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="Id"><%= i18n.t('Id') %></span>
                            </th>
            <%
                            break;
                        case 'disk_image':
            %>
                            <th class="sortable" data-sortby="disk_image">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="Disk image"><%= i18n.t('Disk image') %></span>
                            </th>
            <%
                            break;
                        case 'version':
            %>
                            <th class="desktop sortable col-width-14" data-sortby="version">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="Version"><%= i18n.t('Version') %></span>
                            </th>
            <%
                            break;
                        case 'osf':
            %>
                            <th class="desktop sortable" data-sortby="osf_name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="OS Flavour"><%= i18n.t('OS Flavour') %></span>
                            </th>
            <%
                            break;
                        case 'default':
            %>
                            <th class="desktop max-1-icons">
                                <i class="fa fa-home"></i>
                            </th>
            <%
                            break;
                        case 'head':
            %>
                            <th class="desktop col-width-12" data-sortby="head">
                                <i class="fa sort-icon" data-i18n="Head"><%= i18n.t('Head') %></i>
                                <span data-i18n="Head"><%= i18n.t('Head') %></i>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="sortable desktop" data-sortby="tenant_name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="Tenant"><%= i18n.t('Tenant') %></span>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = 'data-i18n="' + col.text + '"';
                            if (col.noTranslatable === true) {
                                translationAttr = '';
                            }
                    
            %>
                            <th class="sortable desktop" data-sortby="<%= name %>">
                                <i class="fa sort-icon"></i>
                                <span <%= translationAttr %>><%= col.text %></span>
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
                            case 'info':
                %>
                                <td class="desktop">
                                    <%
                                    
                                    if (model.get('tags') && (!infoRestrictions || infoRestrictions.tags)) {
                                    %>
                                        <i class="fa fa-tags" title="&raquo; <%= model.get('tags').replace(/,/g,'<br /><br />&raquo; ') %>"></i>
                                    <%
                                    }
                                    
                                    if (model.get('head') && (!infoRestrictions || infoRestrictions.head)) {
                                    %>
                                        <i class="fa fa-flag-o" data-i18n="[title]Head" title="<%= i18n.t('Head') %>"></i>
                                    <%
                                    }
                                    
                                    if (model.get('default') && (!infoRestrictions || infoRestrictions.default)) {
                                    %>
                                        <i class="fa fa-home" data-i18n="[title]Default" title="<%= i18n.t('Default') %>"></i>
                                    <%
                                    }
                                    
                                    if (model.get('blocked') && (!infoRestrictions || infoRestrictions.block)) {
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
                                <td class="not-break js-name">
                                    <%= Wat.C.ifACL('<a href="#/di/' + model.get('id') + '" data-i18n="[title]Click for details">', 'di.see-details.') %>
                                    <%= Wat.C.ifACL('<i class="fa fa-search"></i>', 'di.see-details.') %>
                                        <span class="text"><%= model.get('disk_image') %></span>
                                    <%= Wat.C.ifACL('</a>', 'di.see-details.') %>
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
                                    <%= Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '">', 'osf.see-details.') %>
                                        <%= model.get('osf_name') %>
                                    <%= Wat.C.ifACL('</a>', 'osf.see-details.') %>
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
                            case 'head':
                %>
                                <td class="desktop center">
                                    <% if (model.get('head')) { %>
                                        <i class="fa fa-flag-o" data-i18n="[title]Head" title="Head"></i>
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