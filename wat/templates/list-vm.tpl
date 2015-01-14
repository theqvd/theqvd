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
                            <th>
                                <i class="fa fa-info-circle normal" data-i18n="[title]Info" title="<%= i18n.t('Info') %>"></i>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="sortable desktop col-width-8" data-sortby="id">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="sortable" data-sortby="name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'host':
            %>
                            <th class="sortable desktop" data-sortby="host_id">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'user':
            %>
                            <th class="sortable desktop" data-sortby="user_name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'osf/tag':
            %>
                            <th class="sortable desktop" data-sortby="osf_name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'tag':
            %>
                            <th class="sortable desktop col-width-20" data-sortby="di_tag">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="sortable desktop" data-sortby="tenant_name">
                                <i class="fa fa-sort sort-icon"></i>
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
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
                                <td>
                                    <%
                                    if (!infoRestrictions || infoRestrictions.state) {
                                    %>
                                        <%
                                        if (model.get('state') == 'stopped') {
                                        %>
                                            <i class="fa fa-stop" title="<%= i18n.t('Stopped') %>" data-i18n="[title]Stopped" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                        <%
                                        }
                                        else if (model.get('state') == 'running'){
                                        %>
                                            <i class="fa fa-play" data-i18n="[title]Running" title="<%= i18n.t('Running') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                        <%
                                        }
                                        else {
                                        %>
                                            <i class="fa fa-spinner fa-spin" title="<%= model.get('state') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                        <%
                                        }
                                        %>
                                    <%
                                    }
                                    %>
                                    
                                    <%
                                    var userStateHiddenClass = 'hidden';
                                    if (model.get('user_state') == 'connected' && (!infoRestrictions || infoRestrictions.user_state)) {
                                        userStateHiddenClass = '';
                                    }
                                    %>
                                        <i class="fa fa-user <%= userStateHiddenClass %>" title="<%= i18n.t('Connected') %>" data-i18n="[title]Connected" data-wsupdate="user_state" data-id="<%= model.get('id') %>"></i>
                                    <%
                                    
                                    if (model.get('blocked') && (!infoRestrictions || infoRestrictions.block)) {
                                    %>
                                        <i class="fa fa-lock" data-i18n="[title]Blocked" title="<%= i18n.t('Blocked') %>"></i>
                                    <%
                                    }
                                    
                                    if ((model.get('expiration_soft') || model.get('expiration_hard')) && (!infoRestrictions || infoRestrictions.expiration)) {
                                    %>
                                        <i class="fa fa-clock-o icon-info" data-i18n="[title]This virtual machine will expire" title="<%= i18n.t('This virtual machine will expire') %>"></i>
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
                                    <%= Wat.C.ifACL('<a href="#/vm/' + model.get('id') + '" data-i18n="[title]Click for details">', 'vm.see-details.') %>
                                    <%= Wat.C.ifACL('<i class="fa fa-search"></i>', 'vm.see-details.') %>
                                        <span class="text"><%= model.get('name') %></span>
                                    <%= Wat.C.ifACL('</a>', 'vm.see-details.') %>
                                </td>
                <%
                                break;
                            case 'host':
                %>
                                <td class="desktop" data-wsupdate="host" data-id="<%= model.get('id') %>">
                                    <%= Wat.C.ifACL('<a href="#/host/' + model.get('host_id') + '">', 'host.see-details.') %>
                                        <%= model.get('host_name') %>
                                    <%= Wat.C.ifACL('</a>', 'host.see-details.') %>
                                </td>
                <%
                                break;
                            case 'user':
                %>
                                <td class="desktop">
                                    <%= Wat.C.ifACL('<a href="#/user/' + model.get('user_id') + '">', 'user.see-details.') %>
                                        <%= model.get('user_name') %>
                                    <%= Wat.C.ifACL('</a>', 'user.see-details.') %>
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
                            case 'osf/tag':
                %>
                                <td class="desktop">
                                    <%= Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '">', 'osf.see-details.') %>
                                        <%= model.get('osf_name') %>
                                    <%= Wat.C.ifACL('</a>', 'osf.see-details.') %>
                                    
                                    <div class="second_row">
                                        <%= model.get('di_tag') %>
                                    </div>
                                </td>
                <%
                                break;
                            case 'tag':
                %>
                                <td class="desktop">
                                    <%= model.get('di_tag') %>
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
                            case 'ip':
                %>
                                <td class="desktop">
                                    <span class="" data-wsupdate="<%= name %>" data-id="<%= model.get('id') %>"><%= model.get(name) %></span>
                                    <% if (Wat.C.checkACL('vm.see.next-boot-ip') && model.get('next_boot_ip') && model.get('next_boot_ip') != model.get('ip')) { %>
                                    <div class="second_row"><span data-i18n="Next"></span>: <%= model.get('next_boot_ip') %></div>
                                    <% } %>
                                </td>
                <%
                                break;
                            case 'di_name':
                %>
                                <td class="desktop">
                                    <%= Wat.C.ifACL('<a href="#/di/' + model.get('di_id') + '" data-i18n="[title]Click for details">', 'di.see-details.') %>
                                        <%= model.get('di_name') %>
                                    <%= Wat.C.ifACL('</a>', 'di.see-details.') %>
                                </td>
                <%
                                break;
                            case 'di_version':
                %>
                                <td class="desktop">
                                    <%= Wat.C.ifACL('<a href="#/di/' + model.get('di_id') + '" data-i18n="[title]Click for details">', 'di.see-details.') %>
                                        <%= model.get('di_version') %>
                                    <%= Wat.C.ifACL('</a>', 'di.see-details.') %>
                                </td>
                <%
                                break;
                            default:
                %>
                                <td class="desktop" data-wsupdate="<%= name %>" data-id="<%= model.get('id') %>">
                                    <%= model.get(name) %>
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