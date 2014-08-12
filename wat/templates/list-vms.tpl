<table class="list">
    <thead>
        <tr>    
            <% 
                _.each(columns, function(col) {
                    if (col.display == false) {
                        return;
                    }
                    
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
                            <th class="cacheable max-3-icons" data-i18n="Info">
                                <%= getCached('Info', cache) %>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="cacheable sortable desktop" data-sortby="id" data-i18n="Id">
                                <%= getCached('Id', cache) %>
                            </th>
            <%
                            break;
                        case 'name':
            %>
                            <th class="cacheable sortable" data-sortby="name" data-i18n="Name">
                                <%= getCached('Name', cache) %>
                            </th>
            <%
                            break;
                        case 'node':
            %>
                            <th class="cacheable sortable desktop" data-sortby="host_id" data-i18n="Node">
                                <%= getCached('Node', cache) %>
                            </th>
            <%
                            break;
                        case 'user':
            %>
                            <th class="cacheable sortable desktop" data-sortby="user_name" data-i18n="User">
                                <%= getCached('User', cache) %>
                            </th>
            <%
                            break;
                        case 'osf/tag':
            %>
                            <th class="cacheable sortable desktop" data-sortby="osf_name" data-i18n="OSF / Tag">
                                <%= getCached('OSF / Tag', cache) %>
                            </th>
            <%
                            break;
                        case 'tag':
            %>
                            <th class="cacheable sortable desktop" data-sortby="di_tag" data-i18n="Tag">
                                <%= getCached('Tag', cache) %>
                            </th>
            <%
                            break;
                        default:
            %>
                            <th class="sortable desktop" data-sortby="<%= col.name %>" data-i18n="<%= col.name %>">
                                <%= col.name %>
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
                <td colspan="<%= columns.length %>">
                    <span class="no-elements cacheable" data-i18n="No elements found">
                        <%= getCached('No elements found', cache) %>
                    </span>
                </td>
            </tr>
        <%
        }
        else {
            // Store string in a hidden div only for cache it
        %>
            <div class="hidden cacheable" data-i18n="No elements found"></div>
        <%
        }
        %>
        
        <% _.each(models, function(model) { %>
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
                                    <input type="checkbox" name="check_<%= model.get('id') %>" class="check-it js-check-it">
                                </td>
                <%
                                break;
                            case 'info':
                %>
                                <td>
                                    <% 
                                    if (model.get('blocked')) {
                                    %>
                                        <i class="fa fa-warning icon-warning"></i>
                                        <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
                                    <%
                                    }
 
                                    if (model.get('state') == 'stopped') {
                                    %>
                                        <i class="fa fa-pause icon-pause" title="Stopped Virtual machine" data-i18n="[title]Stopped"></i>
                                    <%
                                    }
                                    else {
                                    %>
                                        <i class="fa fa-play icon-play" data-i18n="[title]Running"></i>
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
                                <td>
                                    <a href="#/vm/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'node':
                %>
                                <td class="desktop">
                                    <a href="#">
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
                            default:
                %>
                                <td class="desktop">
                                    <%= model.get(col.name) %>
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