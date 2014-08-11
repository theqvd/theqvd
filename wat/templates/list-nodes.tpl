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
                            <th class="cacheable max-2-icons" data-i18n="Info">
                                <%= getCached('Info', cache) %>
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="cacheable sortable desktop max-2-icons" data-sortby="id" data-i18n="Id">
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
                        case 'state':
            %>
                            <th class="cacheable desktop sortable" data-sortby="state" data-i18n="State">
                                <%= getCached('State', cache) %>
                            </th>
            <%
                            break;
                        case 'address':
            %>
                            <th class="cacheable desktop sortable" data-sortby="address" data-i18n="IP address">
                                <%= getCached('IP address', cache) %>
                            </th>
            <%
                            break;
                        case '#vms':
            %>
                            <th class="cacheable desktop sortable" data-sortby="#vms" data-i18n="Running VMs">
                                <%= getCached('Running VMs', cache) %>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = 'data-i18n="' + col.name + '"';
                            if (col.noTranslatable === true) {
                                translationAttr = '';
                            }
                    
            %>
                            <th class="cacheable sortable desktop" data-sortby="<%= col.name %>" <%= translationAttr %>>
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
                                    <a href="#/node/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'state':
                %>
                                <td class="desktop">
                                    <% 
                                        switch(model.get('state')) {
                                            case "running":
                                    %>
                                                <span data-i18n>Running</span>
                                    <%
                                                break;
                                            case "stopped":
                                    %>
                                                <span data-i18n>Stopped</span>
                                    <%
                                                break;
                                        }
                                    %>
                                </td>
                <%
                                break;
                            case 'address':
                %>
                                <td class="desktop">
                                    <%= model.get('address') %>
                                </td>
                <%
                                break;
                            case '#vms':
                %>
                                <td class="desktop">
                                    <%= model.get('#vms') %>
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