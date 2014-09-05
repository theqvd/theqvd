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
                            <th class="max-3-icons">
                                <i class="fa fa-info-circle normal" data-i18n="[title]Info" title="<%= i18n.t('Info') %>"></i>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="sortable desktop col-width-8" data-sortby="id">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="sortable" data-sortby="name">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'host':
            %>
                            <th class="sortable desktop" data-sortby="host_id">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'user':
            %>
                            <th class="sortable desktop" data-sortby="user_name">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'osf/tag':
            %>
                            <th class="sortable desktop" data-sortby="osf_name">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'tag':
            %>
                            <th class="sortable desktop col-width-20" data-sortby="di_tag">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        case 'tenant':
            %>
                            <th class="sortable desktop" data-sortby="tenant">
                                <i class="fa fa-sort sort-icon" data-i18n="<%= col.text %>"><%= col.text %></i>
                            </th>
            <%
                            break;
                        default:
            %>
                            <th class="sortable desktop" data-sortby="<%= name %>">
                                <i class="fa sort-icon"><%= col.text %></i>
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
                                        <i class="fa fa-pause icon-pause" title="Stopped Virtual machine" data-i18n="[title]Stopped"></i>
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
                                    
                                    if (model.get('expiration_soft') || model.get('expiration_hard')) {
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
                                    <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <span class="text"><%= model.get('name') %></span>
                                    </a>
                                </td>
                <%
                                break;
                            case 'host':
                %>
                                <td class="desktop">
                                    <a href="#/host/<%= model.get('host_id') %>">
                                        <%= model.get('host_name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'user':
                %>
                                <td class="desktop">
                                    <a href="#/user/<%= model.get('user_id') %>">
                                        <%= model.get('user_name') %>
                                    </a>
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
                            case 'osf/tag':
                %>
                                <td class="desktop">
                                    <a href="#/osf/<%= model.get('osf_id') %>">
                                        <%= model.get('osf_name') %>
                                    </a>
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
                            default:
                %>
                                <td class="desktop">
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