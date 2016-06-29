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
                            <th class="<%= sortAttr %> max-1-icons cell-check">
                                <input type="checkbox" class="check_all" <%= checkedAttr %>>
                            </th>
            <%
                            break;
                        case 'info':
            %>
                            <th class="<%= sortAttr %>">
                                <i class="fa fa-info-circle normal" data-i18n="[title]Info" title="<%= i18n.t('Info') %>"></i>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="id">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="<%= sortAttr %> col-width-100" data-sortby="name">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'host':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="host_id">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'user':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="user_name">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'osf/tag':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="osf_name">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'tag':
            %>
                            <th class="<%= sortAttr %> desktop col-width-20" data-sortby="di_tag">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="<%= sortAttr %> desktop" data-sortby="tenant_name">
                                <span data-i18n="<%= col.text %>"><%= col.text %></span>
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
                    <span class="no-elements" data-i18n="There are no elements">
                        <%= i18n.t('There are no elements') %>
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
                                <td class="cell-check">
                                    <input type="checkbox" class="check-it js-check-it" data-id="<%= model.get('id') %>" <%= checkedAttr %>>
                                </td>
                <%
                                break;
                            case 'info':
                %>
                                <td class="js-cell-info">
                                    <%
                                    if (!infoRestrictions || infoRestrictions.state) {
                                        switch (model.get('state')) {
                                            case 'stopped':
                                                %>
                                                    <i class="<%= CLASS_ICON_STATUS_STOPPED %>" title="<%= i18n.t('Stopped') %>" data-i18n="[title]Stopped" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                                <%
                                                break;
                                            case 'running':
                                                %>
                                                    <i class="<%= CLASS_ICON_STATUS_RUNNING %>" title="<%= i18n.t('Running') %>" data-i18n="[title]Running" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>

                                                    <%
                                                    if (model.get('di_id') != model.get('di_id_in_use')) {
                                                    %>
                                                        <i class="fa fa-warning warning" title="" data-id="<%= model.get('id') %>" data-i18n="[title]The execution image is different than the assigned image"></i>
                                                    <%
                                                    }
                                                break;
                                            case 'starting':
                                                %>
                                                    <i class="<%= CLASS_ICON_STATUS_STARTING %>" title="<%= model.get('state') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                                <%
                                                break;
                                            case 'stopping':
                                                %>
                                                    <i class="<%= CLASS_ICON_STATUS_STOPPING %>" title="<%= model.get('state') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                                <%
                                                break;
                                            case 'zombie':
                                                %>
                                                    <i class="<%= CLASS_ICON_STATUS_ZOMBIE %>" data-i18n="[title]Zombie" title="<%= i18n.t('Zombie') %>" data-wsupdate="state" data-id="<%= model.get('id') %>"></i>
                                                <%
                                                break;
                                        }
                                    }
                                    
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
                                var cellClass = 'js-name';
                                var cellAttrs = '';
                                if (Wat.C.checkACL('vm.see-details.')) {
                                    cellClass += ' cell-link';
                                    cellAttrs += 'data-i18n="[title]Click for details"';
                                }
                                
                                cellAttrs += ' class="' + cellClass + '"';
                                
                %>
                                <td <%= cellAttrs %>>
                                    <input type="hidden" class="selenium-field vm-state-<%= model.get('id') %>" value="<%= model.get('state') %>">
                                    <%= Wat.C.ifACL('<a href="#/vm/' + model.get('id') + '"">', 'vm.see-details.') %>
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
                            case 'expiration_soft':
                %>
                                <td class="desktop">
                                    <%
                                        if (model.get('time_until_expiration_soft')) {
                                            var remainingTimeSoft = Wat.U.processRemainingTime(model.get('time_until_expiration_soft'));
                                    %>
                                            <div class="<%= remainingTimeSoft.priorityClass %>" <%= remainingTimeSoft.remainingTimeAttr %> data-countdown data-raw="<%= Wat.U.base64.encodeObj(model.get('time_until_expiration_soft')) %>">
                                                <%= remainingTimeSoft.remainingTime %>
                                            </div>
                                            <div class="second_row">
                                                <%= model.get('expiration_soft') ? model.get('expiration_soft').replace('T',' ') : '' %>
                                            </div>
                                    <%
                                        }
                                    %>
                                </td>
                <%
                                break;
                            case 'expiration_hard':
                %>
                                <td class="desktop">
                                    <%
                                        if (model.get('time_until_expiration_hard')) {
                                            var remainingTimeHard = Wat.U.processRemainingTime(model.get('time_until_expiration_hard'));
                                    %>
                                        <div class="<%= remainingTimeHard.priorityClass %>" <%= remainingTimeHard.remainingTimeAttr %> data-countdown data-raw="<%= Wat.U.base64.encodeObj(model.get('time_until_expiration_hard')) %>">
                                            <%= remainingTimeHard.remainingTime %>
                                        </div>
                                        <div class="second_row">
                                            <%= model.get('expiration_hard') ? model.get('expiration_hard').replace('T',' ') : '' %>
                                        </div>
                                    <%
                                        }
                                    %>
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