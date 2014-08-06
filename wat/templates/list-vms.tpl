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
                            <th class="cacheable sortable desktop" data-i18n="Id">
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
                            <th class="cacheable sortable desktop" data-sortby="node" data-i18n="Node">
                                <%= getCached('Node', cache) %>
                            </th>
            <%
                            break;
                        case 'user':
            %>
                            <th class="cacheable sortable desktop" data-sortby="user" data-i18n="User">
                                <%= getCached('User', cache) %>
                            </th>
            <%
                            break;
                        case 'osf/tag':
            %>
                            <th class="cacheable sortable desktop" data-sortby="osf" data-i18n="OSF / Tag">
                                <%= getCached('OSF / Tag', cache) %>
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
                                        <i class="fa fa-pause icon-pause" title="Stopped Virtual machine"></i>
                                        <i class="fa fa-warning icon-warning"></i>
                                        <i class="fa fa-lock"></i>
                                    <%
                                    }
                                    else {
                                    %>
                                        <i class="fa fa-play icon-play"></i>
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
                                    <a href="#/vm/<%= model.get('id') %>">
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
                                        <%= model.get('di_version') %>
                                    </div>
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